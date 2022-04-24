/// SPDX-License-Identifier: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'dart:io';
import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/a2l_file.dart';
import 'package:a2l/src/preprocessor.dart';


/// Loads the file located in [path] and returns the 
/// parsed file. The method will read the file from the
/// file system in a synchronous manner using the dart:io library.
/// 
/// May throw exceptions on error.
/// See also [parseA2L()],
A2LFile parseA2LFileSync(String path) {
  final source = File(path).readAsStringSync();
  // Todo : load includes.
  return parseA2L(source);
}

/// Parses the given [text] as A2L file and converts it to the [A2LFile]
/// data structure.
/// 
/// Throws exceptions if the there are snytax errors or dangling references.  
A2LFile parseA2L(String text) {
  var parser = TokenParser();
  parser.tokens = convertFileContentsToTokens(text);
  parser.currentIndex = 0;
  return parser.parse();
}
