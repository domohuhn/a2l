// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'dart:math';
import 'package:a2l/src/a2l_tree/annotation.dart';
import 'package:a2l/src/a2l_tree/axis_pts.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Represents the description for an axis of a characteristic.
/// (a2l key: AXIS_DESCR)
class AxisDescription extends AnnotationContainer {
  AxisDescription() : ecuAxisPoints = [];
  // mandatory values
  /// attribute / axis type
  AxisType type = AxisType.standard;

  /// reference to the input value (MEASUREMENT id)
  String inputQuantity = '';

  /// reference to the conversion method (COMPU_METHOD id)
  String conversionMethod = '';

  /// maximum number of axis points
  int maxAxisPoints = 1;

  /// lowest plausible value for axis points
  double lowerLimit = 1.0;

  /// highest plausible value for axis points
  double upperLimit = 1.0;

  // optional values
  // annotation is in base (a2l key: ANNOTATION)
  /// reference to an AXIS_PTS description if data is stored elsewhere. (a2l key: AXIS_PTS_REF)
  String? axisPoints;

  /// byte order of the values (a2l key: BYTE_ORDER)
  ByteOrder? endianess;

  /// reference to an AXIS_PTS description if type is CURVE_AXIS. (a2l key: CURVE_AXIS_REF)
  String? rescaleAxisPoints;

  /// whether the values are absolute values or a difference to the previous value (a2l key: EXTENDED_LIMITS)
  Deposit? depositMode;

  /// Extended limits for values (a2l key: DEPOSIT)
  ExtendedLimits? extendedLimits;

  /// (a2l key: FIX_AXIS_PAR)
  FixedAxisPoints? fixedAxisPoints1;

  /// (a2l key: FIX_AXIS_PAR_DIST)
  FixedAxisPoints? fixedAxisPoints2;

  /// (a2l key: FIX_AXIS_PAR_LIST)
  List<double> ecuAxisPoints;

  /// Display format string. overrides compu method. (a2l key: FORMAT)
  String? format;

  /// the maximum gradient of the axis (a2l key: MAX_GRAD)
  double? maxGradient;

  /// monotony of the axis (a2l key: MONOTONY)
  Monotony? monotony;

  /// Can be used to override the unit at the conversion method (a2l key: PHYS_UNIT)
  String? unit;

  /// if the object is read/write (a2l key: READ_ONLY)
  bool readWrite = true;

  /// the step size in the mcd system (a2l key: STEP_SIZE)
  double? stepSize;

  /// Converts the object to the a2l file contents.
  /// Entries are indented to [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin AXIS_DESCR', depth);
    rv += indent('${axisTypeToString(type)} $inputQuantity $conversionMethod $maxAxisPoints $lowerLimit $upperLimit', depth + 1);
    if (axisPoints != null) {
      rv += indent('AXIS_PTS_REF $axisPoints', depth + 1);
    }
    if (rescaleAxisPoints != null) {
      rv += indent('CURVE_AXIS_REF $rescaleAxisPoints', depth + 1);
    }
    if (!readWrite) {
      rv += indent('READ_ONLY', depth + 1);
    }
    if (monotony != null) {
      rv += indent('MONOTONY ${monotonyToString(monotony!)}', depth + 1);
    }
    if (maxGradient != null) {
      rv += indent('MAX_GRAD $maxGradient', depth + 1);
    }
    if (endianess != null) {
      rv += indent('BYTE_ORDER ${byteOrderToString(endianess!)}', depth + 1);
    }
    if (format != null && format!.isNotEmpty) {
      rv += indent('FORMAT "$format"', depth + 1);
    }
    if (unit != null) {
      rv += indent('PHYS_UNIT "$unit"', depth + 1);
    }

    if (fixedAxisPoints1 != null) {
      rv += fixedAxisPoints1!.toFixAxisPar(depth + 1);
    }
    if (fixedAxisPoints2 != null) {
      rv += fixedAxisPoints2!.toFixAxisParDist(depth + 1);
    }
    if (ecuAxisPoints.isNotEmpty) {
      rv += indent('/begin FIX_AXIS_PAR_LIST', depth + 1);
      for (final l in ecuAxisPoints) {
        rv += indent('$l', depth + 2);
      }
      rv += indent('/end FIX_AXIS_PAR_LIST', depth + 1);
    }

    if (stepSize != null) {
      rv += indent('STEP_SIZE $stepSize', depth + 1);
    }
    if (depositMode != null) {
      rv += indent('DEPOSIT ${depositToString(depositMode!)}', depth + 1);
    }
    if (extendedLimits != null) {
      rv += extendedLimits!.toFileContents(depth + 1);
    }
    rv += annotationsToFileContents(depth + 1);
    rv += indent('/end AXIS_DESCR\n\n', depth);

    return rv;
  }
}

/// Describes fixed axis points. (a2l key: FIX_AXIS_PAR and FIX_AXIS_PAR_DIST)
///
/// Axis points are computed in the following way for FIX_AXIS_PAR:
///
///     for(i=0;i<max;i++)
///       x_i = p0 + i*2**p1
///
/// Axis points are computed in the following way for FIX_AXIS_PAR_DIST:
///
///     for(i=0;i<max;i++)
///       x_i = p0 + i*p1
///
/// For simplicity, values are read in and converted to the formula FIX_AXIS_PAR_DIST.
class FixedAxisPoints {
  /// Serves as offset in the linear function.
  int p0 = 0;

  /// Serves as distance between points. De-/Serialiazed differently for the different keys.
  int p1 = 0;

  /// The number of points on the axis.
  int max = 0;

  /// creates the axis values
  List<int> createAxis() {
    var rv = <int>[];
    for (var i = 0; i < max; ++i) {
      rv.add(p0 + i * p1);
    }
    return rv;
  }

  /// Converts the class to FIX_AXIS_PAR a2l element.
  String toFixAxisPar(int depth) {
    return indent('FIX_AXIS_PAR $p0 ${log(p1) / ln2} $max', depth);
  }

  /// Converts the class to FIX_AXIS_PAR_DIST a2l element.
  String toFixAxisParDist(int depth) {
    return indent('FIX_AXIS_PAR_DIST $p0 $p1 $max', depth);
  }
}

/// Enum describing the axis type
enum AxisType {
  /// This axis type uses a separate curve to get the index values (referenced by CURVE_AXIS_REF)
  curve,

  /// axis values are stored elsewhere (referenced by AXIS_PTS_REF)
  comAxis,

  /// a virtual axis that does not exists in memory. (uses FIX_AXIS_PAR, FIX_AXIS_PAR_DIST, FIX_AXIS_PAR_LIST)
  fixed,

  /// a rescale axis (referenced by AXIS_PTS_REF)
  rescale,

  /// a standard axis
  standard
}

/// Converts token [t] to the axis type enum.
AxisType axisTypeFromString(Token t) {
  switch (t.text) {
    case 'CURVE_AXIS':
      return AxisType.curve;
    case 'COM_AXIS':
      return AxisType.comAxis;
    case 'FIX_AXIS':
      return AxisType.fixed;
    case 'RES_AXIS':
      return AxisType.rescale;
    case 'STD_AXIS':
      return AxisType.standard;
    default:
      throw ParsingException('Unknown axis type', t);
  }
}

/// Converts axis type enum [t] to the a2l string.
String axisTypeToString(AxisType t) {
  switch (t) {
    case AxisType.curve:
      return 'CURVE_AXIS';
    case AxisType.comAxis:
      return 'COM_AXIS';
    case AxisType.fixed:
      return 'FIX_AXIS';
    case AxisType.rescale:
      return 'RES_AXIS';
    case AxisType.standard:
      return 'STD_AXIS';
    default:
      throw ValidationError('Unknown axis type $t');
  }
}
