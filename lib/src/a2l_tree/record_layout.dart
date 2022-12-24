// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// The description of the memory layout in the ECU.
class BaseLayoutData {
  /// Position of the data values.
  int position = 0;

  /// Data type.
  Datatype type = Datatype.uint8;

  /// converts the layout to an a2l string
  String toFileContents() {
    return '$position ${dataTypeToString(type)}';
  }
}

/// The description of the memory layout of function values in the ECU.
class LayoutData extends BaseLayoutData {
  /// How the values are deposited in arrays
  IndexMode mode = IndexMode.ROW_DIR;

  /// What is stored at the location
  AddressType addressType = AddressType.DIRECT;

  /// converts the layout to an a2l string
  @override
  String toFileContents() {
    return '${super.toFileContents()} ${indexModeToString(mode)} ${addressTypeToString(addressType)}';
  }
}

/// Decreasing or increasing indexes with increasing addresses
enum IndexOrder {
  /// Index increases
  INDEX_INCR,

  /// Index decreases
  INDEX_DECR
}

/// Converts input String [s] to the enum.
IndexOrder indexOrderFromString(Token s) {
  switch (s.text) {
    case 'INDEX_INCR':
      return IndexOrder.INDEX_INCR;
    case 'INDEX_DECR':
      return IndexOrder.INDEX_DECR;
    default:
      throw ParsingException('Unknown IndexOrder', s);
  }
}

/// Converts input enum [s] to the a2l string.
String indexOrderToString(IndexOrder s) {
  switch (s) {
    case IndexOrder.INDEX_INCR:
      return 'INDEX_INCR';
    case IndexOrder.INDEX_DECR:
      return 'INDEX_DECR';
    default:
      throw ValidationError('Unknown IndexOrder');
  }
}

/// The description of the memory layout of axis points in the ECU.
class AxisLayoutData extends BaseLayoutData {
  /// How the index changes with addresses
  IndexOrder order = IndexOrder.INDEX_INCR;

  /// What is stored at the location
  AddressType addressType = AddressType.DIRECT;

  /// converts the layout to an a2l string
  @override
  String toFileContents() {
    return '${super.toFileContents()} ${indexOrderToString(order)} ${addressTypeToString(addressType)}';
  }
}

/// The description of the memory layout of axis rescale pairs in the ECU.
/// The axis is rescaled linearly between the tuples (x,y) stored in this structure.
class AxisRescaleData extends BaseLayoutData {
  /// Max. Number of rescale pairs
  int maxNumberOfPairs = 1;

  /// How the index changes with addresses
  IndexOrder order = IndexOrder.INDEX_INCR;

  /// What is stored at the location
  AddressType addressType = AddressType.DIRECT;

  /// converts the layout to an a2l string
  @override
  String toFileContents() {
    return '${super.toFileContents()} $maxNumberOfPairs ${indexOrderToString(order)} ${addressTypeToString(addressType)}';
  }
}

/// Stores how data is represented in memory.
/// Each individual entry is ordered by its position.
/// Address offsets can be computed using the alignment and datatype/size of all previous elements.
/// Curves may have dynamic sizes, which means that the offsets shift when the size changes.
/// The opposite is the cas if STATIC_RECORD_LAYOUT is true.
class RecordLayout {
  String name = '';

  // optional
  int? aligmentInt8;
  int? aligmentInt16;
  int? aligmentInt32;
  int? aligmentInt64;
  int? aligmentFloat32;
  int? aligmentFloat64;
  LayoutData? values;

  // AXIS_PTS_X/Y/Z/4/5
  AxisLayoutData? axisPointsX;
  AxisLayoutData? axisPointsY;
  AxisLayoutData? axisPointsZ;
  AxisLayoutData? axisPoints4;
  AxisLayoutData? axisPoints5;

  // AXIS_RESCALE_X/Y/Z/4/5
  AxisRescaleData? axisRescaleX;
  AxisRescaleData? axisRescaleY;
  AxisRescaleData? axisRescaleZ;
  AxisRescaleData? axisRescale4;
  AxisRescaleData? axisRescale5;
  // DIST_OP_X/Y/Z/4/5
  // distance in bytes between the entries of the axis is stored her on the ecu
  // computation of axis positions as offset+i*distance
  BaseLayoutData? distanceX;
  BaseLayoutData? distanceY;
  BaseLayoutData? distanceZ;
  BaseLayoutData? distance4;
  BaseLayoutData? distance5;

  // FIX_NO_AXIS_PTS_X/Y/Z/4/5
  int? fixedNumberOfAxisPointsX;
  int? fixedNumberOfAxisPointsY;
  int? fixedNumberOfAxisPointsZ;
  int? fixedNumberOfAxisPoints4;
  int? fixedNumberOfAxisPoints5;

  // IDENTIFICATION
  BaseLayoutData? identification;

  // NO_AXIS_PTS_X/Y/Z/4/5
  // number of points in the axis
  BaseLayoutData? numberOfAxisPointsX;
  BaseLayoutData? numberOfAxisPointsY;
  BaseLayoutData? numberOfAxisPointsZ;
  BaseLayoutData? numberOfAxisPoints4;
  BaseLayoutData? numberOfAxisPoints5;
  // NO_RESCALE_X/Y/Z/4/5
  // actual number of pairs in the axis rescale structure
  BaseLayoutData? numberOfRescalePointsX;
  BaseLayoutData? numberOfRescalePointsY;
  BaseLayoutData? numberOfRescalePointsZ;
  BaseLayoutData? numberOfRescalePoints4;
  BaseLayoutData? numberOfRescalePoints5;
  // OFFSET_X/Y/Z/4/5
  // computation of axis positions as offset+i*2**shift or offset+i*distance??
  BaseLayoutData? offsetX;
  BaseLayoutData? offsetY;
  BaseLayoutData? offsetZ;
  BaseLayoutData? offset4;
  BaseLayoutData? offset5;
  // RESERVED*
  List<BaseLayoutData> reserved;
  // RIP_ADDR_W/_X/Y/Z/4/5
  // intermediate result of interpolations of the axis of curves
  BaseLayoutData? output;
  BaseLayoutData? intermediateX;
  BaseLayoutData? intermediateY;
  BaseLayoutData? intermediateZ;
  BaseLayoutData? intermediate4;
  BaseLayoutData? intermediate5;
  // SRC_ADDR_X/Y/Z/4/5
  // input address for the curves
  BaseLayoutData? inputX;
  BaseLayoutData? inputY;
  BaseLayoutData? inputZ;
  BaseLayoutData? input4;
  BaseLayoutData? input5;
  // SHIFT_OP_X/Y/Z/4/5
  // computation of axis positions as offset+i*2**shift
  BaseLayoutData? shiftX;
  BaseLayoutData? shiftY;
  BaseLayoutData? shiftZ;
  BaseLayoutData? shift4;
  BaseLayoutData? shift5;
  // STATIC_RECORD_LAYOUT
  bool staticRecordLayout = false;

  RecordLayout() : reserved = [];

  String toFileContents(int depth) {
    var rv = indent('/begin RECORD_LAYOUT $name', depth);
    if (aligmentInt8 != null) {
      rv += indent('ALIGNMENT_BYTE $aligmentInt8', depth + 1);
    }
    if (aligmentInt16 != null) {
      rv += indent('ALIGNMENT_WORD $aligmentInt16', depth + 1);
    }
    if (aligmentInt32 != null) {
      rv += indent('ALIGNMENT_LONG $aligmentInt32', depth + 1);
    }
    if (aligmentInt64 != null) {
      rv += indent('ALIGNMENT_INT64 $aligmentInt64', depth + 1);
    }
    if (aligmentFloat32 != null) {
      rv += indent('ALIGNMENT_FLOAT32_IEEE $aligmentFloat32', depth + 1);
    }
    if (aligmentFloat64 != null) {
      rv += indent('ALIGNMENT_FLOAT64_IEEE $aligmentFloat64', depth + 1);
    }
    if (values != null) {
      rv += indent('FNC_VALUES ${values!.toFileContents()}', depth + 1);
    }
    // AXIS_PTS_X/Y/Z/4/5
    if (axisPointsX != null) {
      rv += indent('AXIS_PTS_X ${axisPointsX!.toFileContents()}', depth + 1);
    }
    if (axisPointsY != null) {
      rv += indent('AXIS_PTS_Y ${axisPointsY!.toFileContents()}', depth + 1);
    }
    if (axisPointsZ != null) {
      rv += indent('AXIS_PTS_Z ${axisPointsZ!.toFileContents()}', depth + 1);
    }
    if (axisPoints4 != null) {
      rv += indent('AXIS_PTS_4 ${axisPoints4!.toFileContents()}', depth + 1);
    }
    if (axisPoints5 != null) {
      rv += indent('AXIS_PTS_5 ${axisPoints5!.toFileContents()}', depth + 1);
    }

    // AXIS_RESCALE_X/Y/Z/4/5
    if (axisRescaleX != null) {
      rv +=
          indent('AXIS_RESCALE_X ${axisRescaleX!.toFileContents()}', depth + 1);
    }
    if (axisRescaleY != null) {
      rv +=
          indent('AXIS_RESCALE_Y ${axisRescaleY!.toFileContents()}', depth + 1);
    }
    if (axisRescaleZ != null) {
      rv +=
          indent('AXIS_RESCALE_Z ${axisRescaleZ!.toFileContents()}', depth + 1);
    }
    if (axisRescale4 != null) {
      rv +=
          indent('AXIS_RESCALE_4 ${axisRescale4!.toFileContents()}', depth + 1);
    }
    if (axisRescale5 != null) {
      rv +=
          indent('AXIS_RESCALE_5 ${axisRescale5!.toFileContents()}', depth + 1);
    }
    // DIST_OP_X/Y/Z/4/5
    if (distanceX != null) {
      rv += indent('DIST_OP_X ${distanceX!.toFileContents()}', depth + 1);
    }
    if (distanceY != null) {
      rv += indent('DIST_OP_Y ${distanceY!.toFileContents()}', depth + 1);
    }
    if (distanceZ != null) {
      rv += indent('DIST_OP_Z ${distanceZ!.toFileContents()}', depth + 1);
    }
    if (distance4 != null) {
      rv += indent('DIST_OP_4 ${distance4!.toFileContents()}', depth + 1);
    }
    if (distance5 != null) {
      rv += indent('DIST_OP_5 ${distance5!.toFileContents()}', depth + 1);
    }
    // FIX_NO_AXIS_PTS_X/Y/Z/4/5
    if (fixedNumberOfAxisPointsX != null) {
      rv += indent('FIX_NO_AXIS_PTS_X $fixedNumberOfAxisPointsX', depth + 1);
    }
    if (fixedNumberOfAxisPointsY != null) {
      rv += indent('FIX_NO_AXIS_PTS_Y $fixedNumberOfAxisPointsY', depth + 1);
    }
    if (fixedNumberOfAxisPointsZ != null) {
      rv += indent('FIX_NO_AXIS_PTS_Z $fixedNumberOfAxisPointsZ', depth + 1);
    }
    if (fixedNumberOfAxisPoints4 != null) {
      rv += indent('FIX_NO_AXIS_PTS_4 $fixedNumberOfAxisPoints4', depth + 1);
    }
    if (fixedNumberOfAxisPoints5 != null) {
      rv += indent('FIX_NO_AXIS_PTS_5 $fixedNumberOfAxisPoints5', depth + 1);
    }
    // IDENTIFICATION
    if (identification != null) {
      rv += indent(
          'IDENTIFICATION ${identification!.toFileContents()}', depth + 1);
    }

    // NO_AXIS_PTS_X/Y/Z/4/5
    if (numberOfAxisPointsX != null) {
      rv += indent(
          'NO_AXIS_PTS_X ${numberOfAxisPointsX!.toFileContents()}', depth + 1);
    }
    if (numberOfAxisPointsY != null) {
      rv += indent(
          'NO_AXIS_PTS_Y ${numberOfAxisPointsY!.toFileContents()}', depth + 1);
    }
    if (numberOfAxisPointsZ != null) {
      rv += indent(
          'NO_AXIS_PTS_Z ${numberOfAxisPointsZ!.toFileContents()}', depth + 1);
    }
    if (numberOfAxisPoints4 != null) {
      rv += indent(
          'NO_AXIS_PTS_4 ${numberOfAxisPoints4!.toFileContents()}', depth + 1);
    }
    if (numberOfAxisPoints5 != null) {
      rv += indent(
          'NO_AXIS_PTS_5 ${numberOfAxisPoints5!.toFileContents()}', depth + 1);
    }

    // NO_RESCALE_X/Y/Z/4/5
    if (numberOfRescalePointsX != null) {
      rv += indent('NO_RESCALE_X ${numberOfRescalePointsX!.toFileContents()}',
          depth + 1);
    }
    if (numberOfRescalePointsY != null) {
      rv += indent('NO_RESCALE_Y ${numberOfRescalePointsY!.toFileContents()}',
          depth + 1);
    }
    if (numberOfRescalePointsZ != null) {
      rv += indent('NO_RESCALE_Z ${numberOfRescalePointsZ!.toFileContents()}',
          depth + 1);
    }
    if (numberOfRescalePoints4 != null) {
      rv += indent('NO_RESCALE_4 ${numberOfRescalePoints4!.toFileContents()}',
          depth + 1);
    }
    if (numberOfRescalePoints5 != null) {
      rv += indent('NO_RESCALE_5 ${numberOfRescalePoints5!.toFileContents()}',
          depth + 1);
    }

    // OFFSET_X/Y/Z/4/5
    if (offsetX != null) {
      rv += indent('OFFSET_X ${offsetX!.toFileContents()}', depth + 1);
    }
    if (offsetY != null) {
      rv += indent('OFFSET_Y ${offsetY!.toFileContents()}', depth + 1);
    }
    if (offsetZ != null) {
      rv += indent('OFFSET_Z ${offsetZ!.toFileContents()}', depth + 1);
    }
    if (offset4 != null) {
      rv += indent('OFFSET_4 ${offset4!.toFileContents()}', depth + 1);
    }
    if (offset5 != null) {
      rv += indent('OFFSET_5 ${offset5!.toFileContents()}', depth + 1);
    }
    // RESERVED*
    if (reserved.isNotEmpty) {
      for (final r in reserved) {
        rv += indent('RESERVED ${r.toFileContents()}', depth + 1);
      }
    }
    // RIP_ADDR_W/_X/Y/Z/4/5
    if (output != null) {
      rv += indent('RIP_ADDR_W ${output!.toFileContents()}', depth + 1);
    }
    if (intermediateX != null) {
      rv += indent('RIP_ADDR_X ${intermediateX!.toFileContents()}', depth + 1);
    }
    if (intermediateY != null) {
      rv += indent('RIP_ADDR_Y ${intermediateY!.toFileContents()}', depth + 1);
    }
    if (intermediateZ != null) {
      rv += indent('RIP_ADDR_Z ${intermediateZ!.toFileContents()}', depth + 1);
    }
    if (intermediate4 != null) {
      rv += indent('RIP_ADDR_4 ${intermediate4!.toFileContents()}', depth + 1);
    }
    if (intermediate5 != null) {
      rv += indent('RIP_ADDR_5 ${intermediate5!.toFileContents()}', depth + 1);
    }
    // SRC_ADDR_X/Y/Z/4/5
    if (inputX != null) {
      rv += indent('SRC_ADDR_X ${inputX!.toFileContents()}', depth + 1);
    }
    if (inputY != null) {
      rv += indent('SRC_ADDR_Y ${inputY!.toFileContents()}', depth + 1);
    }
    if (inputZ != null) {
      rv += indent('SRC_ADDR_Z ${inputZ!.toFileContents()}', depth + 1);
    }
    if (input4 != null) {
      rv += indent('SRC_ADDR_4 ${input4!.toFileContents()}', depth + 1);
    }
    if (input5 != null) {
      rv += indent('SRC_ADDR_5 ${input5!.toFileContents()}', depth + 1);
    }
    // SHIFT_OP_X/Y/Z/4/5
    if (shiftX != null) {
      rv += indent('SHIFT_OP_X ${shiftX!.toFileContents()}', depth + 1);
    }
    if (shiftY != null) {
      rv += indent('SHIFT_OP_Y ${shiftY!.toFileContents()}', depth + 1);
    }
    if (shiftZ != null) {
      rv += indent('SHIFT_OP_Z ${shiftZ!.toFileContents()}', depth + 1);
    }
    if (shift4 != null) {
      rv += indent('SHIFT_OP_4 ${shift4!.toFileContents()}', depth + 1);
    }
    if (shift5 != null) {
      rv += indent('SHIFT_OP_5 ${shift5!.toFileContents()}', depth + 1);
    }
    // STATIC_RECORD_LAYOUT
    if (staticRecordLayout) {
      rv += indent('STATIC_RECORD_LAYOUT', depth + 1);
    }

    rv += indent('/end RECORD_LAYOUT\n\n', depth);
    return rv;
  }
}
