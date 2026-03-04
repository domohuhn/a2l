// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse mandatory', () {
    test('Parse one', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.description, 'Description of common module data');
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, null);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, null);
      expect(common.endianness, null);
      expect(common.dataSize, null);
      expect(common.standardDeposit, null);
      expect(common.standardRecordLayout, null);
    });

    test('Parse multiple', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        '/end',
        'MOD_COMMON',
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        '/end',
        'MOD_COMMON'
      ]);
      expect(() => parser.parse(), throwsException);
    });
  });

  group('Parse optional', () {
    test('ALIGNMENT_BYTE', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_BYTE',
        '11',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, null);
      expect(common.alignmentInt8, 11);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, null);
    });

    test('ALIGNMENT_LONG', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_LONG',
        '11',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, null);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, 11);
      expect(common.alignmentInt64, null);
    });

    test('ALIGNMENT_WORD', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_WORD',
        '11',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, null);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, 11);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, null);
    });

    test('ALIGNMENT_INT64', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_INT64',
        '13',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, null);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, 13);
    });

    test('ALIGNMENT_FLOAT32_IEEE', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_FLOAT32_IEEE',
        '5',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, 5);
      expect(common.alignmentFloat64, null);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, null);
    });

    test('ALIGNMENT_FLOAT64_IEEE', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_FLOAT64_IEEE',
        '8',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, 8);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, null);
    });

    test('ALIGNMENT_INT64', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'ALIGNMENT_FLOAT64_IEEE',
        '7',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.alignmentFloat32, null);
      expect(common.alignmentFloat64, 7);
      expect(common.alignmentInt8, null);
      expect(common.alignmentInt16, null);
      expect(common.alignmentInt32, null);
      expect(common.alignmentInt64, null);
      expect(common.endianness, null);
    });

    test('BYTE_ORDER', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'BYTE_ORDER',
        'MSB_FIRST',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.endianness, ByteOrder.MSB_FIRST);
    });

    test('DATA_SIZE', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'DATA_SIZE',
        '42',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.dataSize, 42);
    });

    test('DEPOSIT', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'DEPOSIT',
        'DIFFERENCE',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.standardDeposit, Deposit.DIFFERENCE);
    });

    test('S_REC_LAYOUT', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_COMMON',
        '"Description of common module data"',
        'S_REC_LAYOUT',
        'S.Lay',
        '/end',
        'MOD_COMMON'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var common = file.project.modules[0].common!;
      expect(common.standardRecordLayout, 'S.Lay');
    });
  });
}
