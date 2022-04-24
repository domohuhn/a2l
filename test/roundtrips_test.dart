import 'package:a2l/a2l.dart';
import 'package:test/test.dart';

void main() {
  group('Roundtrip tests', () {
    test('simple.a2l', () {
      var file = parseA2L(simpleText);
      var out = file.toFileContents();
      expect(out, simpleText);
    });
  });
}

final simpleText = '''
/* This a2l file was generated with the dart a2l package */
/* Version 1.0.0 */

ASAP2_VERSION 1 61

/begin PROJECT DH.XCP.SIMPLE
  "Simple Project to test the parser"

  /begin HEADER
    "Project header"
    VERSION "DH 1.0.0"
    PROJECT_NO DH2022S
  /end HEADER

  /begin MODULE DH.XCP.SIM
    "XCP Simulation module"

    /begin MOD_COMMON
      "Common values"
      ALIGNMENT_BYTE 1
      ALIGNMENT_WORD 2
      ALIGNMENT_LONG 4
      ALIGNMENT_INT64 8
      ALIGNMENT_FLOAT32_IEEE 4
      ALIGNMENT_FLOAT64_IEEE 8
      BYTE_ORDER MSB_LAST
      DEPOSIT ABSOLUTE
    /end MOD_COMMON

    /begin MOD_PAR
      "Parameter values"
      CPU_TYPE "AMD Ryzen"
      CUSTOMER "No one"
      CUSTOMER_NO "12345"
      ECU "No ecu"
      ECU_CALIBRATION_OFFSET 0x0
      NO_OF_INTERFACES 1
      VERSION "v1.0.0"
    /end MOD_PAR

    /begin RECORD_LAYOUT VALUE_UINT8
      FNC_VALUES 1 UBYTE ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_UINT16
      FNC_VALUES 1 UWORD ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_UINT32
      FNC_VALUES 1 ULONG ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_UINT64
      FNC_VALUES 1 A_UINT64 ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_INT8
      FNC_VALUES 1 SBYTE ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_INT16
      FNC_VALUES 1 SWORD ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_INT32
      FNC_VALUES 1 SLONG ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_INT64
      FNC_VALUES 1 A_INT64 ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_FLOAT
      FNC_VALUES 1 FLOAT32_IEEE ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin RECORD_LAYOUT VALUE_DOUBLE
      FNC_VALUES 1 FLOAT64_IEEE ROW_DIR DIRECT
    /end RECORD_LAYOUT

    /begin COMPU_METHOD CONVERSION_IDENTICAL
      "Example for a conversion method"
      IDENTICAL "%9.5" "no unit"
    /end COMPU_METHOD

    /begin COMPU_METHOD CONVERSION_TABLE
      "Example for a conversion method using a table"
      TAB_VERB "%9.5" "no unit"
      COMPU_TAB_REF TABLE_COND
    /end COMPU_METHOD

    /begin COMPU_VTAB TABLE_COND
      "Example for a conversion table"
      TAB_VERB 2
      1.0 "TRUE"
      0.0 "FALSE"
    /end COMPU_VTAB

    /begin CHARACTERISTIC CHAR_DOUBLE
      "characteristic double\nAdding more lines of description\nTo test this."
      VALUE 0x00000000 VALUE_DOUBLE 100.0 CONVERSION_IDENTICAL -100.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_INT64
      "characteristic int64."
      VALUE 0x00000008 VALUE_INT64 100.0 CONVERSION_IDENTICAL -100.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_UINT64
      "characteristic uint64."
      VALUE 0x00000010 VALUE_UINT64 100.0 CONVERSION_IDENTICAL 0.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_FLOAT
      "characteristic float."
      VALUE 0x00000018 VALUE_FLOAT 100.0 CONVERSION_IDENTICAL -100.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_INT32
      "characteristic int32."
      VALUE 0x0000001c VALUE_INT32 100.0 CONVERSION_IDENTICAL -100.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_UINT32
      "characteristic uint32."
      VALUE 0x00000020 VALUE_UINT32 100.0 CONVERSION_IDENTICAL 0.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_INT16
      "characteristic int16."
      VALUE 0x00000024 VALUE_INT16 100.0 CONVERSION_IDENTICAL -100.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_UINT16
      "characteristic uint16."
      VALUE 0x00000026 VALUE_UINT16 100.0 CONVERSION_IDENTICAL 0.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_INT8
      "characteristic int8."
      VALUE 0x00000028 VALUE_INT8 100.0 CONVERSION_IDENTICAL -100.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_UINT8
      "characteristic uint8."
      VALUE 0x00000029 VALUE_UINT8 100.0 CONVERSION_IDENTICAL 0.0 100.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_BOOL
      "characteristic bool."
      VALUE 0x0000002a VALUE_UINT8 100.0 CONVERSION_TABLE 0.0 1.0
    /end CHARACTERISTIC

    /begin CHARACTERISTIC CHAR_TEXT
      "characteristic ascii. serves as padding as well."
      ASCII 0x0000002b VALUE_UINT8 0.0 NO_COMPU_METHOD 0.0 255.0
      NUMBER 21
    /end CHARACTERISTIC

    /begin GROUP GRP_INTEGERS
      "Integer values"
      /begin REF_CHARACTERISTIC
        CHAR_INT64
        CHAR_INT32
        CHAR_INT16
        CHAR_INT8
        CHAR_UINT64
        CHAR_UINT32
        CHAR_UINT16
        CHAR_UINT8
      /end REF_CHARACTERISTIC
    /end GROUP

    /begin GROUP GRP_FLOATS
      "floating values"
      /begin REF_CHARACTERISTIC
        CHAR_DOUBLE
        CHAR_FLOAT
      /end REF_CHARACTERISTIC
    /end GROUP

    /begin GROUP GRP_REST
      "rest of values"
      /begin REF_CHARACTERISTIC
        CHAR_BOOL
      /end REF_CHARACTERISTIC
    /end GROUP

  /end MODULE

/end PROJECT

''';
