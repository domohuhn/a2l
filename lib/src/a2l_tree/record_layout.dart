import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/parsing_exception.dart';

/// The description of the memory layout in the ECU.
class BaseLayoutData {
  /// Position of the data values.
  int position=0;
  /// Data type.
  Datatype type = Datatype.uint8;
}

/// The description of the memory layout of function values in the ECU.
class LayoutData extends BaseLayoutData {
  /// How the values are deposited in arrays
  IndexMode mode = IndexMode.ROW_DIR;
  /// What is stored at the location
  AddressType addressType = AddressType.DIRECT;
}

/// Decreasing or increasing indexes with increasing addresses
enum IndexOrder {
  /// Index increases
  INDEX_INCR,
  /// Index decreases
  INDEX_DECR
}

/// Converts input String [s] to the enum.
IndexOrder indexOrderFromString(String s) {
  switch(s) {
    case 'INDEX_INCR' : return IndexOrder.INDEX_INCR;
    case 'INDEX_DECR' : return IndexOrder.INDEX_DECR;
    default: throw ParsingException('Unknown IndexOrder "$s"', '', 0);
  }
}


/// The description of the memory layout of axis points in the ECU.
class AxisLayoutData extends BaseLayoutData {
  /// How the index changes with addresses
  IndexOrder order = IndexOrder.INDEX_INCR;
  /// What is stored at the location
  AddressType addressType = AddressType.DIRECT;
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
}

/// Stores how data is represented in memory.
/// Each individual entry is ordered by its position.
/// Address offsets can be computed using the alignment and datatype/size of all previous elements.
/// Curves may have dynamic sizes, which means that the offsets shift when the size changes.
/// The opposite is the cas if STATIC_RECORD_LAYOUT is true.
class RecordLayout {
  String name='';

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

}








