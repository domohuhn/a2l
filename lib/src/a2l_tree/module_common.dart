

import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/utility.dart';

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

  /// Converts the object to an a2l file.
  String toFileContents(int depth) {
    var rv = indent('/begin MOD_COMMON', depth);
    rv += indent('"$description"', depth+1);
    if (aligmentInt8!=null) {
      rv += indent('ALIGNMENT_BYTE $aligmentInt8', depth+1);
    }
    if (aligmentInt16!=null) {
      rv += indent('ALIGNMENT_WORD $aligmentInt16', depth+1);
    }
    if (aligmentInt32!=null) {
      rv += indent('ALIGNMENT_LONG $aligmentInt32', depth+1);
    }
    if (aligmentInt64!=null) {
      rv += indent('ALIGNMENT_INT64 $aligmentInt64', depth+1);
    }
    if (aligmentFloat32!=null) {
      rv += indent('ALIGNMENT_FLOAT32_IEEE $aligmentFloat32', depth+1);
    }
    if (aligmentFloat64!=null) {
      rv += indent('ALIGNMENT_FLOAT64_IEEE $aligmentFloat64', depth+1);
    }
    if (endianess!=null) {
      rv += indent('BYTE_ORDER ${byteOrderToString(endianess!)}', depth+1);
    }
    if (dataSize!=null) {
      rv += indent('DATA_SIZE $dataSize', depth+1);
    }
    if (standardDeposit!=null) {
      rv += indent('DEPOSIT ${depositToString(standardDeposit!)}', depth+1);
    }
    if (standardRecordLayout!=null && standardRecordLayout!.isNotEmpty) {
      rv += indent('S_REC_LAYOUT $standardRecordLayout', depth+1);
    }

    rv += indent('/end MOD_COMMON\n\n', depth);
    return rv;
  }
}





