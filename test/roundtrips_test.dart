// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/a2l.dart';
import 'package:test/test.dart';

void main() {
  group('Roundtrip tests', () {
    test('simple.a2l', () {
      var file = parseA2L(simpleText);
      var out = file.toFileContents();
      expect(out, simpleText);
    });

    test('simple.a2l - toString', () {
      var file = parseA2L(simpleText);
      var out = file.toString();
      expect(out, '''A2L File
Version: 1.61
A2ML Version: 1.60

Project "DH.XCP.SIMPLE"
Simple Project to test the parser

Comment: "Project header"
Version: "DH 1.0.0"
Number: "DH2022S"
Modules: "1"

Module "DH.XCP.SIM"
XCP Simulation module

Measurements: 1
Characteristics: 13
Units: 1
Compute Methods: 2
Compute Tables: 3
Groups: 3
Record layouts: 10
Frames: 1
User rights: 1
Functions: 1

''');
    });
  });
}

final simpleText = '''
/* This a2l file was generated with the dart a2l package */
/* Version 0.5.0 */

ASAP2_VERSION 1 61
A2ML_VERSION 1 60

/begin PROJECT DH.XCP.SIMPLE
  "Simple Project to test the parser"

  /begin HEADER
    "Project header"
    VERSION "DH 1.0.0"
    PROJECT_NO DH2022S
  /end HEADER

  /begin MODULE DH.XCP.SIM
    "XCP Simulation module"

    /begin A2ML
      /* Some A2ML comment */
      taggedstruct moo {
        this
        is
        some
        fake
        a2ml text;
      };
    /end A2ML

    /begin IF_DATA
      moo {
        0x01
        0x02
        aaaa
      };
    /end IF_DATA

    /begin MOD_COMMON
      "Common values"
      ALIGNMENT_BYTE 1
      ALIGNMENT_WORD 2
      ALIGNMENT_LONG 4
      ALIGNMENT_INT64 8
      ALIGNMENT_FLOAT32_IEEE 4
      ALIGNMENT_FLOAT64_IEEE 8
      BYTE_ORDER MSB_LAST
      DATA_SIZE 64
      DEPOSIT ABSOLUTE
      S_REC_LAYOUT stdlay
    /end MOD_COMMON

    /begin MOD_PAR
      "Parameter values"
      CPU_TYPE "AMD Ryzen"
      CUSTOMER "No one"
      CUSTOMER_NO "12345"
      ECU "No ecu"
      ECU_CALIBRATION_OFFSET 0x0
      EPK "sda"
      NO_OF_INTERFACES 1
      PHONE_NO "1234567890"
      SUPPLIER "fake inc"
      USER "person"
      SYSTEM_CONSTANT "pi" "3.141"
      SYSTEM_CONSTANT "moo" "4"
      VERSION "v1.0.0"
      /begin CALIBRATION_METHOD
        "SERAM"
        1
        /begin CALIBRATION_HANDLE
          0x1
          0x2
          0x3
          CALIBRATION_HANDLE_TEXT "handle"
        /end CALIBRATION_HANDLE
      /end CALIBRATION_METHOD

      /begin MEMORY_LAYOUT
        PRG_CODE
        0x10101010 0x00001000
        -1
        -1
        -1
        -1
        -1
      /end MEMORY_LAYOUT

      /begin MEMORY_SEGMENT SEG1
        "description"
        DATA FLASH INTERN
        0x20101010 0x00001000
        -1
        -1
        -1
        -1
        -1
      /end MEMORY_SEGMENT

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

    /begin COMPU_VTAB_RANGE TABLE_COND2
      "Example for a conversion table"
      2
      1.0 10.0 "TRUE"
      0 1 "FALSE"
      DEFAULT_VALUE "N/A"
    /end COMPU_VTAB_RANGE

    /begin COMPU_TAB TABLE_COND3
      "Example for a conversion table"
      TAB_INTP 2
      5.0 42.0
      0.0 10.0
      DEFAULT_VALUE "N/A"
    /end COMPU_TAB

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

    /begin CHARACTERISTIC TEST_MAP
      "Test characteristic map"
      MAP 0x00001234 MAP_DEPOS 100.0 CONVERSION_IDENTICAL 0.0 7000.0
      /begin FUNCTION_LIST
        FNC1
        FNC2
      /end FUNCTION_LIST
      /begin AXIS_DESCR
        STD_AXIS N AXIS_CONV 12 0.0 1350.0
        MONOTONY STRICT_INCREASE
        MAX_GRAD 12.0
        BYTE_ORDER MSB_LAST
        FORMAT "%9.4"
        PHYS_UNIT "V"
        STEP_SIZE 1.0
        DEPOSIT ABSOLUTE
      /end AXIS_DESCR

    /end CHARACTERISTIC

    /begin MEASUREMENT MEAS_ONE
      "lorem ispum"
      SWORD CONVERSION_IDENTICAL 1 1.0 0.0 255.0
      ECU_ADDRESS 0x00001000
      ERROR_MASK 0xffffffff
      READ_WRITE
      /begin ANNOTATION
        ANNOTATION_LABEL "some label2"
        ANNOTATION_ORIGIN "some origin2"
        /begin ANNOTATION_TEXT
          "AA2"
          "BB2"
        /end ANNOTATION_TEXT
      /end ANNOTATION
    /end MEASUREMENT

    /begin UNIT U.Test
      "Meter"
      "m" EXTENDED_SI
      REF_UNIT U.Other
      SI_EXPONENTS 1 0 0 0 0 0 0
      UNIT_CONVERSION 1.0 2.0
    /end UNIT

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

    /begin FUNCTION FUN.1
      "text for fun1"
      FUNCTION_VERSION "v1"
      /begin DEF_CHARACTERISTIC
        CH.1
        CH.2
      /end DEF_CHARACTERISTIC
      /begin IN_MEASUREMENT
        M.1
      /end IN_MEASUREMENT
      /begin LOC_MEASUREMENT
        M.2
      /end LOC_MEASUREMENT
      /begin OUT_MEASUREMENT
        M.3
      /end OUT_MEASUREMENT
      /begin REF_CHARACTERISTIC
        CH.3
      /end REF_CHARACTERISTIC
      /begin SUB_FUNCTION
        FUN.2
      /end SUB_FUNCTION
    /end FUNCTION

    /begin FRAME frame.1
      "some text" 3 3
      FRAME_MEASUREMENT Measure1 measure2
    /end FRAME

    /begin USER_RIGHTS someId
      READ_ONLY
      /begin REF_GROUP
        GRP_INTEGERS
        GRP_FLOATS
      /end REF_GROUP
    /end USER_RIGHTS

    /begin VARIANT_CODING
      VAR_NAMING NUMERIC
      VAR_SEPARATOR "."
      /begin VAR_CRITERION gear
        "gearbox"
        automatic
        manual
        VAR_MEASUREMENT codeMeasure
        VAR_SELECTION_CHARACTERISTIC codeChar
      /end VAR_CRITERION
      /begin VAR_CRITERION engine
        "engine"
        gas
        electric
        VAR_MEASUREMENT codeMeasure2
        VAR_SELECTION_CHARACTERISTIC codeChar2
      /end VAR_CRITERION
      /begin VAR_FORBIDDEN_COMB
        gear manual
        engine electric
      /end VAR_FORBIDDEN_COMB
      /begin VAR_CHARACTERISTIC depChar1
        engine
        gear
        /begin VAR_ADDRESS
          0x01020304
          0x01020308
          0x0102031c
        /end VAR_ADDRESS
      /end VAR_CHARACTERISTIC
    /end VARIANT_CODING

  /end MODULE

/end PROJECT

''';
