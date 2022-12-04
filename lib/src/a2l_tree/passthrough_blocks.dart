

import 'package:a2l/src/utility.dart';

/// Writes a List of strings into a2l blocks.
/// [depth] is the indentation depth
/// [key] is the a2l key
/// [contents] is the list of string wrapped in the blocks
String writeListOfBlocks(int depth, String key, List<String> contents) {
  var rv = '';
  for(final txt in contents) {
      if(txt.isEmpty) {
        continue;
      }
      rv += indent('/begin $key\n', depth);
      rv += txt;
      if(!rv.endsWith('\n')) {
        rv += '\n';
      }
      rv += indent('/end $key\n\n', depth);
  }
  return rv;
}




