import 'package:a2l/src/a2l_tree/base_types.dart';

/// The description of the memory layout in the ECU.
class LayoutData {
  /// Position of the data values.
  int position=0;
  /// Data type.
  Datatype type = Datatype.uint8;
  /// How the values are deposited in arrays
  IndexMode mode = IndexMode.ROW_DIR;
  /// What is stored at the location
  AddressType addressType = AddressType.DIRECT;
}

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

  // TODO many stuff is missing
}








