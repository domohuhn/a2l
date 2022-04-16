

import 'package:a2l/src/a2l_tree/base_types.dart';

/// Common data for the module.
class ModuleCommon {
  // mandatory
  String description = '';
  
  // optional
  /// alignment for 8 bit wide values (int and uint)
  int? aligmentInt8;
  /// alignment for 16 bit wide values (int and uint)
  int? aligmentInt16;
  /// alignment for 32 bit wide values (int and uint)
  int? aligmentInt32;
  /// alignment for 64 bit wide values (int and uint)
  int? aligmentInt64;
  /// alignment for 32 bit wide floats
  int? aligmentFloat32;
  /// alignment for 64 bit wide floats
  int? aligmentFloat64;
  /// endianess of the ecu
  ByteOrder? endianess;
  int? dataSize;

  Deposit? standardDeposit;
  String? standardRecordLayout;
}





