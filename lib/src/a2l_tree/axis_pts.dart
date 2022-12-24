// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'package:a2l/src/a2l_tree/passthrough_blocks.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Represents the description for an axis stored at another memory location compared to its characteristic.
/// (a2l key: AXIS_PTS)
class AxisPoints extends DataContainer {
  AxisPoints() : interfaceData = [];
  // mandatory values
  /// memory address of the first axis value
  int address = 0;

  /// reference to the input value (MEASUREMENT id)
  String inputQuantity = '';

  /// reference to the data layout (RECORD_LAYOUT id)
  String recordLayout = '';

  /// max difference from specified table values at the conversion method
  double maxDifferenceFromTable = 0.0;

  /// reference to the conversion method (COMPU_METHOD id)
  String conversionMethod = '';

  /// maximum number of axis points
  int maxAxisPoints = 1;

  /// lowest plausible value for axis points
  double lowerLimit = 1.0;

  /// highest plausible value for axis points
  double upperLimit = 1.0;

  // optional values
  // annotation is in base
  /// byte order of the values
  ByteOrder? endianess;

  /// how the values can be accessed
  CalibrationAccess? calibrationAccess;

  /// whether the values are absolute values or a difference to the previous value
  Deposit? depositMode;

  /// How the value is displayed. Must not be unique.
  String? displayIdentifier;

  /// address extension for XCP packages
  int? addressExtension;

  /// Extended limits for values
  ExtendedLimits? extendedLimits;

  /// Display format string. overrides compu method.
  String? format;
  // functions are in base
  /// if the first and last point of the axis can be modified
  bool guardRails = false;

  /// The interface description (if present). The library will not process these strings in any way.  (a2l key: IFDATA)
  List<String> interfaceData;

  /// Can be used to override the unit at the conversion method
  String? unit;

  /// if the value is read write
  bool readWrite = true;

  /// the memory segment
  String? memorySegment;

  /// monotony of the axis
  Monotony? monotony;

  /// the step size in the mcd system
  double? stepSize;

  /// reference to a symbol in an object file
  SymbolLink? symbolLink;

  /// Converts the object to the a2l file contents.
  /// Entries are indented to [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin AXIS_PTS $name', depth);
    rv += indent('"$description"', depth + 1);
    rv += indent('0x${address.toRadixString(16).padLeft(8, "0")} $inputQuantity $recordLayout', depth + 1);
    rv += indent('$maxDifferenceFromTable $conversionMethod $maxAxisPoints $lowerLimit $upperLimit', depth + 1);

    if (!readWrite) {
      rv += indent('READ_ONLY', depth + 1);
    }
    if (guardRails) {
      rv += indent('GUARD_RAILS', depth + 1);
    }
    if (monotony != null) {
      rv += indent('MONOTONY ${monotonyToString(monotony!)}', depth + 1);
    }
    if (endianess != null) {
      rv += indent('BYTE_ORDER ${byteOrderToString(endianess!)}', depth + 1);
    }
    if (displayIdentifier != null) {
      rv += indent('DISPLAY_IDENTIFIER $displayIdentifier', depth + 1);
    }
    if (addressExtension != null) {
      rv += indent('ECU_ADDRESS_EXTENSION $addressExtension', depth + 1);
    }
    if (format != null && format!.isNotEmpty) {
      rv += indent('FORMAT "$format"', depth + 1);
    }
    if (unit != null) {
      rv += indent('PHYS_UNIT "$unit"', depth + 1);
    }
    if (memorySegment != null) {
      rv += indent('REF_MEMORY_SEGMENT $memorySegment', depth + 1);
    }
    if (functions.isNotEmpty) {
      rv += indent('/begin FUNCTION_LIST', depth + 1);
      for (final data in functions) {
        rv += indent(data, depth + 2);
      }
      rv += indent('/end FUNCTION_LIST', depth + 1);
    }
    if (stepSize != null) {
      rv += indent('STEP_SIZE $stepSize', depth + 1);
    }
    if (calibrationAccess != null) {
      rv += indent('CALIBRATION_ACCESS ${calibrationAccessToString(calibrationAccess!)}', depth + 1);
    }
    if (depositMode != null) {
      rv += indent('DEPOSIT ${depositToString(depositMode!)}', depth + 1);
    }
    if (extendedLimits != null) {
      rv += extendedLimits!.toFileContents(depth + 1);
    }
    if (symbolLink != null) {
      rv += symbolLink!.toFileContents(depth + 1);
    }
    rv += writeListOfBlocks( depth + 1, 'IF_DATA', interfaceData);
    rv += annotationsToFileContents(depth + 1);
    rv += indent('/end AXIS_PTS\n\n', depth);

    return rv;
  }
}

/// Describes the monoty requirements for an axis.
enum Monotony {
  /// subsequent values are decreasing or equal to the previous one
  decreasing,

  /// subsequent values are increasing or equal to the previous one
  increasing,

  /// subsequent values are decreasing
  strictly_decreasing,

  /// subsequent values are increasing
  strictly_increasing,

  /// axis is either decreasing or increasing
  monotonous,

  /// axis is either strictly decreasing or strictly increasing
  strictly_monotonous,

  /// axis is not monotonous
  not_monotonous,
}

/// Converts a token [t] to the enum
Monotony monotonyFromString(Token t) {
  switch (t.text) {
    case 'MON_DECREASE':
      return Monotony.decreasing;
    case 'MON_INCREASE':
      return Monotony.increasing;
    case 'STRICT_DECREASE':
      return Monotony.strictly_decreasing;
    case 'STRICT_INCREASE':
      return Monotony.strictly_increasing;
    case 'MONOTONOUS':
      return Monotony.monotonous;
    case 'STRICT_MON':
      return Monotony.strictly_monotonous;
    case 'NOT_MON':
      return Monotony.not_monotonous;
    default:
      throw ParsingException('Unknown monotony for axis', t);
  }
}

/// Converts a Monotony [t] to its a2l string representation
String monotonyToString(Monotony t) {
  switch (t) {
    case Monotony.decreasing:
      return 'MON_DECREASE';
    case Monotony.increasing:
      return 'MON_INCREASE';
    case Monotony.strictly_decreasing:
      return 'STRICT_DECREASE';
    case Monotony.strictly_increasing:
      return 'STRICT_INCREASE';
    case Monotony.monotonous:
      return 'MONOTONOUS';
    case Monotony.strictly_monotonous:
      return 'STRICT_MON';
    case Monotony.not_monotonous:
      return 'NOT_MON';
    default:
      throw ValidationError('Unknown monotony for axis $t');
  }
}
