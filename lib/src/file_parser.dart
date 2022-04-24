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
A2LFile parseA2lFileSync(String path) {
  final source = File(path).readAsStringSync();
  var parser = TokenParser();
  parser.tokens = convertFileContentsToTokens(source);
  parser.currentIndex = 0;
  return parser.parse();
}

