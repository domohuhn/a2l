


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


/// Parses the given [text]. All multiline (/* */) and single line (//)
/// comments are removed. Tokens are split on whitespace or every full string.
/// Adjacent strings are not joined together.
List<Token> convertFileContentsToTokens(String text) {
  var splitter = _Preprocessor(text);
  splitter.parse();
  return splitter.tokens;
}

/// This class performs the preprocessing of the inputs.
class _Preprocessor {

  _Preprocessor(this.content) : tokens = [];

  String content;
  int line = 1;
  int column = 1;
  List<Token> tokens;

  /// Parses the given string.
  /// Removes all single line comments and splits the string into tokens.
  void parse() {
    var whiteSpace = RegExp('\\s+');
    var token = Token('', line, column, 0);
    var isStr = false;

    for(var i=0; i<content.length; i++) {
      if(singleLineCommentStarts(i)) {
        i = skipRestOfLine(i);
      }
      if(multiLineCommentStarts(i)) {
        i = skipMultiLineComment(i);
      }
      var char = content[i];
      if(!isStr && char=='"') {
        if(token.text.isNotEmpty) {
          throw PreprocessingError('Missing whitespace at start of string!', line, column);
        }
        token.text = '';
        isStr = true;
      }
      else if(isStr && char=='"') {
        isStr = false;
        if(i+1<content.length && !whiteSpace.hasMatch(content[i+1])) {
          throw PreprocessingError('Missing whitespace after end of string!', line, column);
        }
      }
      var isWhiteSpace = whiteSpace.hasMatch(char);
      if(isStr) {
        token.text += char;
      } else if (!isWhiteSpace) {
        if(token.text.isEmpty) {
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
    if(isStr) {
      throw PreprocessingError('Unterminated string', token.line, token.column);
    }
  }

  /// Checks if a single line comment starts at the given position.
  bool singleLineCommentStarts(int i) {
    var rv = false;
    if(i+1 < content.length) {
      rv = content[i] == '/' &&  content[i+1] == '/';
    }
    return rv;
  }

  
  /// Checks if a multi line comment starts at the given position.
  bool multiLineCommentStarts(int i) {
    var rv = false;
    if(i+1 < content.length) {
      rv = content[i] == '/' &&  content[i+1] == '*';
    }
    return rv;
  }

  /// Advances the current position to the end of the line.
  int skipRestOfLine(int start){
    for(var i = start; i<content.length; ++i) {
      _incrementCounters(content[i]);
      if(content[i] == '\n') {
        return i;
      }
    }
    return content.length;
  }

  /// Advances the current position to the end of the multi line comment.
  int skipMultiLineComment(int start){
    var startLine = line;
    var startCol = column;
    for(var i = start; i+1<content.length; ++i) {
      _incrementCounters(content[i]);
      if(content[i] == '*' && content[i+1] == '/') {
        _incrementCounters(content[i+1]);
        return i+2;
      }
    }
    throw PreprocessingError('Unterminated multiline comment',startLine,startCol);
  }

  /// Increments the line, column and offset counters.
  void _incrementCounters(String c) {
    if (c.length != 1) {
      throw PreprocessingError('Internal error: File must be parsed character by character, got "$c"', line, column);
    }
    column += 1;
    if(c=='\n') {
      line += 1;
      column = 1;
    }
  }

}


