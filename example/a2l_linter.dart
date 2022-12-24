// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'dart:io';
import 'package:a2l/a2l.dart';

/// This example loads a file given from the command line, parses it
/// and prints the results to the command line.
/// In case no exception occurs, it is a valid a2l file.

void main(List<String> arguments) {
  if (arguments.length != 1) {
    print('Usage: a2l_linter <path>');
    print(
        'You must pass the <path> to the A2L file to check as first and only argument!');
    exit(-1);
  }
  try {
    var file = parseA2LFileSync(arguments[0]);
    print(file.toString());
    print(file.toFileContents());
    print('\n\n=================================\nValid A2L');
    exit(0);
  } catch (ex) {
    print('Error while processing the file "${arguments[0]}"\n\n$ex');
    exit(-1);
  }
}
