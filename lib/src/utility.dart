
String removeQuotes(String text){
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








