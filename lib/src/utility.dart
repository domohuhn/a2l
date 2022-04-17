
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
/// Also adds a new line to the end if not present.
String indent(String text, int depth) {
  if(!text.endsWith('\n')) {
    text += '\n';
  }
  var len = text.length + depth * 2;
  return text.padLeft(len);
}





