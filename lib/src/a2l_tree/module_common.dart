// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/utility.dart';

/// Common data for the module.
class ModuleCommon {
  // mandatory
  String description = '';

  // optional
  /// alignment for 8 bit wide values (int and uint)
  int? alignmentInt8;

  /// alignment for 16 bit wide values (int and uint)
  int? alignmentInt16;

  /// alignment for 32 bit wide values (int and uint)
  int? alignmentInt32;

  /// alignment for 64 bit wide values (int and uint)
  int? alignmentInt64;

  /// alignment for 32 bit wide floats
  int? alignmentFloat32;

  /// alignment for 64 bit wide floats
  int? alignmentFloat64;

  /// endianness of the ecu
  ByteOrder? endianness;
  int? dataSize;

  Deposit? standardDeposit;
  String? standardRecordLayout;

  /// Converts the object to an a2l file.
  String toFileContents(int depth) {
    var rv = indent('/begin MOD_COMMON', depth);
    rv += indent('"$description"', depth + 1);
    if (alignmentInt8 != null) {
      rv += indent('ALIGNMENT_BYTE $alignmentInt8', depth + 1);
    }
    if (alignmentInt16 != null) {
      rv += indent('ALIGNMENT_WORD $alignmentInt16', depth + 1);
    }
    if (alignmentInt32 != null) {
      rv += indent('ALIGNMENT_LONG $alignmentInt32', depth + 1);
    }
    if (alignmentInt64 != null) {
      rv += indent('ALIGNMENT_INT64 $alignmentInt64', depth + 1);
    }
    if (alignmentFloat32 != null) {
      rv += indent('ALIGNMENT_FLOAT32_IEEE $alignmentFloat32', depth + 1);
    }
    if (alignmentFloat64 != null) {
      rv += indent('ALIGNMENT_FLOAT64_IEEE $alignmentFloat64', depth + 1);
    }
    if (endianness != null) {
      rv += indent('BYTE_ORDER ${byteOrderToString(endianness!)}', depth + 1);
    }
    if (dataSize != null) {
      rv += indent('DATA_SIZE $dataSize', depth + 1);
    }
    if (standardDeposit != null) {
      rv += indent('DEPOSIT ${depositToString(standardDeposit!)}', depth + 1);
    }
    if (standardRecordLayout != null && standardRecordLayout!.isNotEmpty) {
      rv += indent('S_REC_LAYOUT $standardRecordLayout', depth + 1);
    }

    rv += indent('/end MOD_COMMON\n\n', depth);
    return rv;
  }
}
