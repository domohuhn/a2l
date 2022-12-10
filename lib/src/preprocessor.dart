import 'package:a2l/src/file_loader.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';

/// Error during preprocessing
class PreprocessingError implements Exception {
  String cause;
  int line;
  int column;
  PreprocessingError(this.cause, this.line, this.column);

  @override
  String toString() {
    return '$cause in line $line at character $column';
  }
}

String processIncludes(String text, FileLoader loader, {int recursion = 0}) {
  if(recursion>loader.maxRecursion) {
    throw ValidationError('Maximum file inclusion depth exceeded (current: $recursion > max: ${loader.maxRecursion})');
  }
  if(!text.contains('/include')) {
    return text;
  }
  final pattern = RegExp(r'/include\s*"?([^\n"]*)"?\s*$', multiLine: true);
  var m = pattern.firstMatch(text);
  while(m!=null) {
    final file = m.group(1);
    if(file==null) {
      throw ValidationError('Internal logic error: the match should always have a group! "$m"');
    }
    try {
      var replace = loader.read(file);
      if(replace.contains('/include')) {
        replace = processIncludes(replace,loader, recursion: recursion+1);
      } else {
        loader.pop();
      }
      text = text.replaceRange(m.start, m.end, replace);
    }
    catch(e) {
      if(recursion == 0) {
        throw PreprocessingError('${loader.stack()}\nFailed to open "${loader.last}" :\n\n$e',findLineOrColumn(text,m.start),findLineOrColumn(text,m.start, getColumn: true));
      } else {
        rethrow;
      }
    }
    m = pattern.firstMatch(text);
  }
  if(recursion>0) {
    loader.pop();
  }
  return text;
}

/// Counts the number of lines in [text] in the first [len] characters.
int findLineOrColumn(String text, int len, {bool getColumn = false}) {
  int lines = 0;
  int col = 0;
  int limit = text.length > len ? len : text.length;
  for(int i=0;i<limit; ++i) {
    col += 1;
    if(text[i]=='\n') {
      lines += 1;
      col = 0;
    }
  }
  return !getColumn ? lines : col;
}

/// Parses the given [text]. All multiline (/* */) and single line (//)
/// comments are removed. Tokens are split on whitespace or every full string.
/// Adjacent strings are not joined together.
List<Token> convertFileContentsToTokens(String text) {
  var splitter = _Preprocessor(text);
  splitter.parse();
  return splitter.tokens;
}

class UnprocessedSection {
  RegExp begin;
  RegExp end;
  UnprocessedSection(this.begin, this.end);
}

/// This class performs the preprocessing of the inputs.
class _Preprocessor {
  _Preprocessor(this.content) : tokens = [];

  String content;
  int line = 1;
  int column = 1;
  List<Token> tokens;

  /// This a a list of start and stop tokens for a passthrough block (e.g. A2ML). Anything between the begin and end match will be but in a single token and not processed.
  List<UnprocessedSection> unprocessedSections = [
    UnprocessedSection(RegExp(r'/begin\s*IF_DATA'), RegExp(r'[\t\f\v ]*/end[\s]*IF_DATA',multiLine: true)),
    UnprocessedSection(RegExp(r'/begin\s*A2ML'), RegExp(r'[\t\f\v ]*/end[\s]*A2ML',multiLine: true))
  ];

  UnprocessedSection? _currentUnprocessedSection;

  /// Finds the begin of a section that should not be processed by the preprocessor.
  int _findBeginOfNextUnprocessedSection(int start) {
    final searchstring = content.substring(start);
    int matchStart = -1;
    _currentUnprocessedSection = null;
    for (final secs in unprocessedSections) {
      RegExpMatch? match = secs.begin.firstMatch(searchstring);
      if(match!=null && (match.start < matchStart || matchStart==-1)) {
        matchStart = match.end;
        _currentUnprocessedSection = secs;
      }
    }
    return start + matchStart;
  }
  
  /// Finds the end of the section that is currently not processed by the preprocessor.
  int _findEndOfCurrentUnprocessedSection(int start, int line, int column) {
    if(_currentUnprocessedSection==null){
      throw ValidationError('Internal logic error: current section was not set!');
    }
    final searchstring = content.substring(start);
    RegExpMatch? match = _currentUnprocessedSection!.end.firstMatch(searchstring);
    if(match==null) {
      throw PreprocessingError('Unterminated section started via "${_currentUnprocessedSection!.begin.toString()}"', line, column);
    }
    return start + match.start;
  }

  /// Parses the given string.
  /// Removes all single line comments and splits the string into tokens.
  void parse() {
    var whiteSpace = RegExp('\\s+');
    var token = Token('', line, column, 0);
    var isStr = false;
    var startPassThrough = _findBeginOfNextUnprocessedSection(0);

    for (var i = 0; i < content.length; i++) {
      if (startPassThrough == i) {
        final endPassThrough = _findEndOfCurrentUnprocessedSection(i, line, column);
        if(startPassThrough<endPassThrough && endPassThrough<content.length) {
          if(token.text.isNotEmpty) {
            tokens.add(token);
            token = Token('', line, column, i);
          }
          tokens.add(Token(content.substring(startPassThrough,endPassThrough), line, column, i));
          for (var k = i; k < endPassThrough; k++) {
            _incrementCounters(content[k]);
          }
          i = endPassThrough - 1;
          startPassThrough = _findBeginOfNextUnprocessedSection(i);
          continue;
        } else {
          throw PreprocessingError('Size of unprocessed block is negative! Invariant start<end ($startPassThrough < $endPassThrough) or end<filesize ($endPassThrough < ${content.length}) does not hold!', line, column);
        }
      }
      if (singleLineCommentStarts(i)) {
        i = skipRestOfLine(i);
      }
      if (multiLineCommentStarts(i)) {
        i = skipMultiLineComment(i);
      }
      var char = content[i];
      if (!isStr && char == '"') {
        if (token.text.isNotEmpty) {
          throw PreprocessingError('Missing whitespace at start of string!', line, column);
        }
        token.text = '';
        isStr = true;
      } else if (isStr && char == '"') {
        isStr = false;
        if (i + 1 < content.length && !whiteSpace.hasMatch(content[i + 1])) {
          throw PreprocessingError('Missing whitespace after end of string!', line, column);
        }
      }
      var isWhiteSpace = whiteSpace.hasMatch(char);
      if (isStr) {
        token.text += char;
      } else if (!isWhiteSpace) {
        if (token.text.isEmpty) {
          token = Token(char, line, column, i);
        } else {
          token.text += char;
        }
      } else if (token.text.isNotEmpty && isWhiteSpace) {
        tokens.add(token);
        token = Token('', line, column, i);
      }
      _incrementCounters(char);
    }
    if (isStr) {
      throw PreprocessingError('Unterminated string', token.line, token.column);
    }
  }

  /// Checks if a single line comment starts at the given position.
  bool singleLineCommentStarts(int i) {
    var rv = false;
    if (i + 1 < content.length) {
      rv = content[i] == '/' && content[i + 1] == '/';
    }
    return rv;
  }

  /// Checks if a multi line comment starts at the given position.
  bool multiLineCommentStarts(int i) {
    var rv = false;
    if (i + 1 < content.length) {
      rv = content[i] == '/' && content[i + 1] == '*';
    }
    return rv;
  }

  /// Advances the current position to the end of the line.
  int skipRestOfLine(int start) {
    for (var i = start; i < content.length; ++i) {
      _incrementCounters(content[i]);
      if (content[i] == '\n') {
        return i;
      }
    }
    return content.length;
  }

  /// Advances the current position to the end of the multi line comment.
  int skipMultiLineComment(int start) {
    var startLine = line;
    var startCol = column;
    for (var i = start; i + 1 < content.length; ++i) {
      _incrementCounters(content[i]);
      if (content[i] == '*' && content[i + 1] == '/') {
        _incrementCounters(content[i + 1]);
        return i + 2;
      }
    }
    throw PreprocessingError('Unterminated multiline comment', startLine, startCol);
  }

  /// Increments the line, column and offset counters.
  void _incrementCounters(String c) {
    if (c.length != 1) {
      throw PreprocessingError('Internal error: File must be parsed character by character, got "$c"', line, column);
    }
    column += 1;
    if (c == '\n') {
      line += 1;
      column = 1;
    }
  }
}
