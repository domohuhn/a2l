/// SPDX-License-Identifier: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:a2l/a2l.dart';
import 'dart:io';

/// This example loads a file given from the command line, parses it
/// and prints the results to the command line.
/// In case no exception occurs, it is a valid a2l file.

void main(List<String> arguments) {
  final source = File(arguments[0]).readAsStringSync();
  var parser = TokenParser();
  parser.tokens = convertFileContentsToTokens(source);
  parser.currentIndex = 0;
  var file = parser.parse();
  print(file.toString());
  print('\n\nValid A2L');
}
