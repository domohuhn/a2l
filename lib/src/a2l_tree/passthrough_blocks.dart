// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/utility.dart';

/// Writes a List of strings into a2l blocks.
/// [depth] is the indentation depth
/// [key] is the a2l key
/// [contents] is the list of string wrapped in the blocks
String writeListOfBlocks(int depth, String key, List<String> contents) {
  var rv = '';
  for (final txt in contents) {
    if (txt.isEmpty) {
      continue;
    }
    rv += indent('/begin $key', depth, addNewline: false);
    print('txt: "$txt" -> ${!txt.startsWith(RegExp(r'/s*?\n'))}');
    if (!txt.startsWith(RegExp(r'[\s]*?\n'))) {
      rv += '\n';
    }
    rv += txt;
    if (!rv.endsWith('\n')) {
      rv += '\n';
    }
    rv += indent('/end $key\n\n', depth);
  }
  return rv;
}
