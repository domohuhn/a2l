// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/axis_pts.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse axis_pts mandatory', () {
    test('Parse one', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].name, 'TEST.AXISPTS');
      expect(axis[0].description, 'This is a test AXISPTS');
      expect(axis[0].address, 0x42);
      expect(axis[0].inputQuantity, 'InputQty');
      expect(axis[0].recordLayout, 'RL.axis');
      expect(axis[0].maxDifferenceFromTable, 99.0);
      expect(axis[0].conversionMethod, 'CM.axis');
      expect(axis[0].maxAxisPoints, 25);
      expect(axis[0].lowerLimit, -110.0);
      expect(axis[0].upperLimit, 200.0);
      expect(axis[0].addressExtension, null);
      expect(axis[0].calibrationAccess, null);
      expect(axis[0].depositMode, null);
      expect(axis[0].displayIdentifier, null);
      expect(axis[0].endianess, null);
      expect(axis[0].extendedLimits, null);
      expect(axis[0].format, null);
      expect(axis[0].guardRails, false);
      expect(axis[0].memorySegment, null);
      expect(axis[0].readWrite, true);
      expect(axis[0].stepSize, null);
      expect(axis[0].symbolLink, null);
      expect(axis[0].unit, null);
      expect(axis[0].annotations.length, 0);
      expect(axis[0].functions.length, 0);
      expect(axis[0].characteristics.length, 0);
      expect(axis[0].measurements.length, 0);
      expect(axis[0].groups.length, 0);
    });

    test('Parse multiple', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        '/end',
        'AXIS_PTS',
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS2',
        '"This is a test AXISPTS2"',
        '0x43',
        'InputQty2',
        'RL.axis2',
        '100.0',
        'CM.axis2',
        '26',
        '-109.0',
        '201.0',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 2);
      expect(axis[0].name, 'TEST.AXISPTS');
      expect(axis[0].description, 'This is a test AXISPTS');
      expect(axis[0].address, 0x42);
      expect(axis[0].inputQuantity, 'InputQty');
      expect(axis[0].recordLayout, 'RL.axis');
      expect(axis[0].maxDifferenceFromTable, 99.0);
      expect(axis[0].conversionMethod, 'CM.axis');
      expect(axis[0].maxAxisPoints, 25);
      expect(axis[0].lowerLimit, -110.0);
      expect(axis[0].upperLimit, 200.0);
      expect(axis[0].addressExtension, null);
      expect(axis[0].calibrationAccess, null);
      expect(axis[0].depositMode, null);
      expect(axis[0].displayIdentifier, null);
      expect(axis[0].endianess, null);
      expect(axis[0].extendedLimits, null);
      expect(axis[0].format, null);
      expect(axis[0].guardRails, false);
      expect(axis[0].memorySegment, null);
      expect(axis[0].readWrite, true);
      expect(axis[0].stepSize, null);
      expect(axis[0].symbolLink, null);
      expect(axis[0].unit, null);
      expect(axis[0].annotations.length, 0);
      expect(axis[0].functions.length, 0);
      expect(axis[0].characteristics.length, 0);
      expect(axis[0].measurements.length, 0);
      expect(axis[0].groups.length, 0);

      expect(axis[1].name, 'TEST.AXISPTS2');
      expect(axis[1].description, 'This is a test AXISPTS2');
      expect(axis[1].address, 0x43);
      expect(axis[1].inputQuantity, 'InputQty2');
      expect(axis[1].recordLayout, 'RL.axis2');
      expect(axis[1].maxDifferenceFromTable, 100.0);
      expect(axis[1].conversionMethod, 'CM.axis2');
      expect(axis[1].maxAxisPoints, 26);
      expect(axis[1].lowerLimit, -109.0);
      expect(axis[1].upperLimit, 201.0);
      expect(axis[1].addressExtension, null);
      expect(axis[1].calibrationAccess, null);
      expect(axis[1].depositMode, null);
      expect(axis[1].displayIdentifier, null);
      expect(axis[1].endianess, null);
      expect(axis[1].extendedLimits, null);
      expect(axis[1].format, null);
      expect(axis[1].guardRails, false);
      expect(axis[1].memorySegment, null);
      expect(axis[1].readWrite, true);
      expect(axis[1].stepSize, null);
      expect(axis[1].symbolLink, null);
      expect(axis[1].unit, null);
      expect(axis[1].annotations.length, 0);
      expect(axis[1].functions.length, 0);
      expect(axis[1].characteristics.length, 0);
      expect(axis[1].measurements.length, 0);
      expect(axis[1].groups.length, 0);
    });
  });

  group('Parse axis_pts optional', () {
    test('ANNOTATION', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
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
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      final annotations = axis[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
    });

    test('BYTE_ORDER', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'BYTE_ORDER',
        'MSB_FIRST',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].endianess, ByteOrder.MSB_FIRST);
    });

    test('CALIBRATION_ACCESS', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'CALIBRATION_ACCESS',
        'NOT_IN_MCD_SYSTEM',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].calibrationAccess, CalibrationAccess.NOT_IN_MCD_SYSTEM);
    });

    test('DEPOSIT', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'DEPOSIT',
        'DIFFERENCE',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].depositMode, Deposit.DIFFERENCE);
    });

    test('DISPLAY_IDENTIFIER', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'DISPLAY_IDENTIFIER',
        'axis_id',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].displayIdentifier, 'axis_id');
    });

    test('ECU_ADDRESS_EXTENSION', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'ECU_ADDRESS_EXTENSION',
        '5',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].addressExtension, 5);
    });

    test('EXTENDED_LIMITS', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'EXTENDED_LIMITS',
        '-500.0',
        '500.0',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].extendedLimits!.lowerLimit, -500.0);
      expect(axis[0].extendedLimits!.upperLimit, 500.0);
    });

    test('FORMAT', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'FORMAT',
        '"%9.4"',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].format, '%9.4');
    });

    test('FUNCTION_LIST', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        '/begin',
        'FUNCTION_LIST',
        'AAA',
        'BBB',
        'VVV',
        '/end',
        'FUNCTION_LIST',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].functions.length, 3);
      expect(axis[0].functions[0], 'AAA');
      expect(axis[0].functions[1], 'BBB');
      expect(axis[0].functions[2], 'VVV');
    });

    test('GUARD_RAILS', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'GUARD_RAILS',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].guardRails, true);
    });

    test('MONOTONY', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'MONOTONY',
        'STRICT_INCREASE',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].monotony, Monotony.strictly_increasing);
    });

    test('PHYS_UNIT', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'PHYS_UNIT',
        '"[m]"',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].unit, '[m]');
    });

    test('READ_ONLY', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'READ_ONLY',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].readWrite, false);
    });

    test('REF_MEMORY_SEGMENT', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'REF_MEMORY_SEGMENT',
        'some_seg',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].memorySegment, 'some_seg');
    });

    test('STEP_SIZE', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'STEP_SIZE',
        '1.5',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].stepSize, 1.5);
    });

    test('SYMBOL_LINK', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        'SYMBOL_LINK',
        '"_SYMBOL"',
        '42',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].symbolLink, isNot(equals(null)));
      expect(axis[0].symbolLink!.name, '_SYMBOL');
      expect(axis[0].symbolLink!.offset, 42);
    });

    test('IF_DATA', () {
      prepareTestData(parser, [
        '/begin',
        'AXIS_PTS',
        'TEST.AXISPTS',
        '"This is a test AXISPTS"',
        '0x42',
        'InputQty',
        'RL.axis',
        '99.0',
        'CM.axis',
        '25',
        '-110.0',
        '200.0',
        '/begin', 'IF_DATA',
        'somestring',
        '/end', 'IF_DATA',
        '/end',
        'AXIS_PTS'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var axis = file.project.modules[0].axisPoints;
      expect(axis.length, 1);
      expect(axis[0].interfaceData.length, 1);
      expect(axis[0].interfaceData[0], 'somestring');
      expect(axis[0].toFileContents(0).contains('/begin IF_DATA'),true);
    });
  });
}
