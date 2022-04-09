import 'package:a2l/src/parsing_exception.dart';

String removeComments(String text) {
  return text.splitMapJoin(RegExp(r'^/\*.*?\*/\s*\n',multiLine: true,dotAll: true), onMatch: (p0) => '\n', onNonMatch: (n) => n)
      .splitMapJoin(RegExp(r'/\*.*?\*/',multiLine: true,dotAll: true), onMatch: (p0) => '', onNonMatch: (n) => n)
      .splitMapJoin(RegExp(r'^//.*?\n',multiLine: true), onMatch: (p0) => '', onNonMatch: (n) => n)
      .splitMapJoin(RegExp(r'//.*$',multiLine: true), onMatch: (p0) => '', onNonMatch: (n) => n);
}

List<String> splitA2L(String tx) {
  var noComments = removeComments(tx);
  var whiteSpace = RegExp('\\s+');
  var list = <String>[];
  var text = '';
  var isStr = false;
  for(var i=0; i<noComments.length; i++) {
    var char = noComments[i];
    if(!isStr && char=='"') {
      if(text.isNotEmpty) {
        throw ParsingException('Missing whitespace at start of string!', noComments, i);
      }
      text = '';
      isStr = true;
    }
    else if(isStr && char=='"') {
      isStr = false;
      if(i+1<noComments.length && !whiteSpace.hasMatch(noComments[i+1])) {
        throw ParsingException('Missing whitespace after end of string!', tx, i);
      }
    }
    var isWhiteSpace = whiteSpace.hasMatch(char);
    if(isStr) {
      text += char;
    } else if (!isWhiteSpace) {
      text += char;
    } else if (text.isNotEmpty && isWhiteSpace) {
      list.add(text);
      text = '';
    }
  }

  return list;
}













