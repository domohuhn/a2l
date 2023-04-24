// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse measurements', () {
    test('Parse mandatory', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].discrete, false);
      expect(meas[0].readWrite, false);
      expect(meas[0].unit, null);
      expect(meas[0].matrixDim, null);
      expect(meas[0].maxRefresh, null);
      expect(meas[0].symbolLink, null);
    });

    test('Parse multiple', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/end',
        'MEASUREMENT',
        '/begin',
        'MEASUREMENT',
        'test_measure2',
        '"This is a test measurement2"',
        'UWORD',
        'CM_moo2',
        '13',
        '2',
        '-32767',
        '32766',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 2);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);

      expect(meas[1].name, 'test_measure2');
      expect(meas[1].description, 'This is a test measurement2');
      expect(meas[1].datatype, Datatype.uint16);
      expect(meas[1].computeMethod, 'CM_moo2');
      expect(meas[1].resolution, 13);
      expect(meas[1].accuracy, 2.0);
      expect(meas[1].lowerLimit, -32767);
      expect(meas[1].upperLimit, 32766);
      expect(meas[1].address, null);
      expect(meas[1].addressExtension, null);
      expect(meas[1].arraySize, null);
      expect(meas[1].bitMask, null);
      expect(meas[1].displayIdentifier, null);
      expect(meas[1].endianess, null);
      expect(meas[1].errorMask, null);
      expect(meas[1].format, null);
      expect(meas[1].layout, null);
      expect(meas[1].memorySegment, null);
      expect(meas[1].unit, null);
    });

    test('Parse optional ECU_ADDRESS', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'ECU_ADDRESS',
        '0x00000042',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, 0x42);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional ECU_ADDRESS_EXTENSION', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'ECU_ADDRESS_EXTENSION',
        '0x00000042',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, 0x42);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional ARRAY_SIZE', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'ARRAY_SIZE',
        '10',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, 10);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional BIT_MASK', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'BIT_MASK',
        '0xFFFFFFFF',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, 0xFFFFFFFF);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional BYTE_ORDER', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'BYTE_ORDER',
        'MSB_LAST',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, ByteOrder.MSB_LAST);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional ERROR_MASK', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'ERROR_MASK',
        '0xFFFFFFFF',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, 0xFFFFFFFF);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional FORMAT', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'FORMAT',
        '"%9.4"',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, '%9.4');
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional LAYOUT', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'LAYOUT',
        'COLUMN_DIR',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, IndexMode.COLUMN_DIR);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
    });

    test('Parse optional PHYS_UNIT', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'PHYS_UNIT',
        '"[m]"',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, '[m]');
    });

    test('Parse optional REF_MEMORY_SEGMENT', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'REF_MEMORY_SEGMENT',
        'Some.Segment',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, 'Some.Segment');
      expect(meas[0].unit, null);
    });

    test('Parse optional ANNOTATION empty', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'ANNOTATION',
        '/end',
        'ANNOTATION',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      final annotations = meas[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, null);
      expect(annotations[0].origin, null);
      expect(annotations[0].text.length, 0);
    });

    test('Parse optional ANNOTATION', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'ANNOTATION',
        '/begin',
        'ANNOTATION_TEXT',
        '"AA\\n"',
        '"BB\\n"',
        '"CC\\n"',
        '/end',
        'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN',
        '"some origin"',
        'ANNOTATION_LABEL',
        '"some label"',
        '/end',
        'ANNOTATION',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      final annotations = meas[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
    });

    test('Parse optional ANNOTATION multiple', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'ANNOTATION',
        '/begin',
        'ANNOTATION_TEXT',
        '"AA\\n"',
        '"BB\\n"',
        '"CC\\n"',
        '/end',
        'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN',
        '"some origin"',
        'ANNOTATION_LABEL',
        '"some label"',
        '/end',
        'ANNOTATION',
        '/begin',
        'ANNOTATION',
        'ANNOTATION_LABEL',
        '"some label2"',
        '/begin',
        'ANNOTATION_TEXT',
        '"AA2\\n"',
        '"BB2\\n"',
        '/end',
        'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN',
        '"some origin2"',
        '/end',
        'ANNOTATION',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      final annotations = meas[0].annotations;
      expect(annotations.length, 2);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');

      expect(annotations[1].label, 'some label2');
      expect(annotations[1].origin, 'some origin2');
      expect(annotations[1].text.length, 2);
      expect(annotations[1].text[0], 'AA2\\n');
      expect(annotations[1].text[1], 'BB2\\n');
    });

    test('Parse optional VIRTUAL', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'VIRTUAL',
        'AAA',
        'BBB',
        'VVV',
        '/end',
        'VIRTUAL',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      expect(meas[0].measurements.length, 3);
      expect(meas[0].measurements[0], 'AAA');
      expect(meas[0].measurements[1], 'BBB');
      expect(meas[0].measurements[2], 'VVV');
    });

    test('Parse optional FUNCTION_LIST', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'FUNCTION_LIST',
        'AAA',
        'BBB',
        'VVV',
        '/end',
        'FUNCTION_LIST',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      expect(meas[0].functions.length, 3);
      expect(meas[0].functions[0], 'AAA');
      expect(meas[0].functions[1], 'BBB');
      expect(meas[0].functions[2], 'VVV');
    });

    test('Parse optional DISCRETE', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'DISCRETE',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      expect(meas[0].discrete, true);
      expect(meas[0].readWrite, false);
      expect(meas[0].functions.length, 0);
    });

    test('Parse optional READ_WRITE', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'READ_WRITE',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      expect(meas[0].discrete, false);
      expect(meas[0].readWrite, true);
      expect(meas[0].functions.length, 0);
    });

    test('Parse optional BIT_OPERATION empty', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'BIT_OPERATION',
        '/end',
        'BIT_OPERATION',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, isNot(equals(null)));
      expect(meas[0].bitOperation!.leftShift, null);
      expect(meas[0].bitOperation!.rightShift, null);
      expect(meas[0].bitOperation!.signExtend, false);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      expect(meas[0].functions.length, 0);
    });

    test('Parse optional BIT_OPERATION', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'BIT_OPERATION',
        'LEFT_SHIFT',
        '4',
        'RIGHT_SHIFT',
        '9',
        'SIGN_EXTEND',
        '/end',
        'BIT_OPERATION',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, isNot(equals(null)));
      expect(meas[0].bitOperation!.leftShift, 4);
      expect(meas[0].bitOperation!.rightShift, 9);
      expect(meas[0].bitOperation!.signExtend, true);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].unit, null);
      expect(meas[0].functions.length, 0);
    });

    test('Parse optional MATRIX_DIM', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'MATRIX_DIM',
        '2',
        '3',
        '4',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].discrete, false);
      expect(meas[0].readWrite, false);
      expect(meas[0].unit, null);
      expect(meas[0].matrixDim, isNot(equals(null)));
      expect(meas[0].matrixDim!.x, 2);
      expect(meas[0].matrixDim!.y, 3);
      expect(meas[0].matrixDim!.z, 4);
      expect(meas[0].maxRefresh, null);
      expect(meas[0].symbolLink, null);
    });

    test('Parse optional MAX_REFRESH', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'MAX_REFRESH',
        '998',
        '2',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].discrete, false);
      expect(meas[0].readWrite, false);
      expect(meas[0].unit, null);
      expect(meas[0].matrixDim, null);
      expect(meas[0].maxRefresh, isNot(equals(null)));
      expect(meas[0].maxRefresh!.scalingUnit, MaxRefreshUnit.event_frame);
      expect(meas[0].maxRefresh!.rate, 2);
      expect(meas[0].symbolLink, null);
    });

    test('Parse optional SYMBOL_LINK', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        'SYMBOL_LINK',
        '"_SYMBOL"',
        '42',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].discrete, false);
      expect(meas[0].readWrite, false);
      expect(meas[0].unit, null);
      expect(meas[0].matrixDim, null);
      expect(meas[0].maxRefresh, null);
      expect(meas[0].symbolLink, isNot(equals(null)));
      expect(meas[0].symbolLink!.name, '_SYMBOL');
      expect(meas[0].symbolLink!.offset, 42);
    });

    test('Parse optional IF_DATA', () {
      prepareTestData(parser, [
        '/begin',
        'MEASUREMENT',
        'test_measure',
        '"This is a test measurement"',
        'SWORD',
        'CM_moo',
        '12',
        '1',
        '-32768',
        '32767',
        '/begin',
        'IF_DATA',
        'taggedstruct',
        '/end',
        'IF_DATA',
        '/end',
        'MEASUREMENT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var meas = file.project.modules[0].measurements;
      expect(meas.length, 1);
      expect(meas[0].name, 'test_measure');
      expect(meas[0].description, 'This is a test measurement');
      expect(meas[0].datatype, Datatype.int16);
      expect(meas[0].computeMethod, 'CM_moo');
      expect(meas[0].resolution, 12);
      expect(meas[0].accuracy, 1.0);
      expect(meas[0].lowerLimit, -32768);
      expect(meas[0].upperLimit, 32767);
      expect(meas[0].address, null);
      expect(meas[0].addressExtension, null);
      expect(meas[0].arraySize, null);
      expect(meas[0].bitMask, null);
      expect(meas[0].bitOperation, null);
      expect(meas[0].displayIdentifier, null);
      expect(meas[0].endianess, null);
      expect(meas[0].errorMask, null);
      expect(meas[0].format, null);
      expect(meas[0].layout, null);
      expect(meas[0].memorySegment, null);
      expect(meas[0].discrete, false);
      expect(meas[0].readWrite, false);
      expect(meas[0].unit, null);
      expect(meas[0].matrixDim, null);
      expect(meas[0].maxRefresh, null);
      expect(meas[0].symbolLink, null);
      expect(meas[0].interfaceData.length, 1);
      expect(meas[0].interfaceData[0], 'taggedstruct');
      expect(meas[0].toFileContents(0).contains('/begin IF_DATA'), true);
    });
  });
}
