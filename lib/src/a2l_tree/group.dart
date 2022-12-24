// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/passthrough_blocks.dart';
import 'package:a2l/src/utility.dart';

/// Describes a group of measurements and characteristics.
/// This can be used to allow users of the MCD system an easier way to
/// find certain objects.
class Group extends DataContainer {
  bool root = false;

  Group() : interfaceData = [];

  /// The interface description (if present). The library will not process these strings in any way.  (a2l key: IFDATA)
  List<String> interfaceData;

  /// Converts the group to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin GROUP $name', depth);
    rv += indent('"$description"', depth + 1);
    if (characteristics.isNotEmpty) {
      rv += indent('/begin REF_CHARACTERISTIC', depth + 1);
      for (final char in characteristics) {
        rv += indent(char, depth + 2);
      }
      rv += indent('/end REF_CHARACTERISTIC', depth + 1);
    }
    if (measurements.isNotEmpty) {
      rv += indent('/begin REF_MEASUREMENT', depth + 1);
      for (final measure in measurements) {
        rv += indent(measure, depth + 2);
      }
      rv += indent('/end REF_MEASUREMENT', depth + 1);
    }
    if (groups.isNotEmpty) {
      rv += indent('/begin SUB_GROUP', depth + 1);
      for (final data in groups) {
        rv += indent(data, depth + 2);
      }
      rv += indent('/end SUB_GROUP', depth + 1);
    }

    if (functions.isNotEmpty) {
      rv += indent('/begin FUNCTION_LIST', depth + 1);
      for (final data in functions) {
        rv += indent(data, depth + 2);
      }
      rv += indent('/end FUNCTION_LIST', depth + 1);
    }

    if (root) {
      rv += indent('ROOT', depth + 1);
    }
    rv += writeListOfBlocks(depth + 1, 'IF_DATA', interfaceData);
    rv += annotationsToFileContents(depth + 1);
    rv += indent('/end GROUP\n\n', depth);
    return rv;
  }
}
