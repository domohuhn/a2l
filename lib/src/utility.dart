
/// Removes quotation marks " around [text] if present and returns a new string. 
String removeQuotes(String text) {
  var start = 0;
  var end = text.length;
  if(text.startsWith('"')) {
    start = 1;
  }
  if(text.endsWith('"')) {
    end -= 1;
  }
  return text.substring(start,end);
}

/// Indents the [text] to [depth].
String indent(String text, int depth) {
  var len = text.length + depth * 2;
  return text.padLeft(len);
}





