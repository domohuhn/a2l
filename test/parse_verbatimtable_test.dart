// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse verbatim table', () {
    test('Parse mandatory', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_VTAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_VERB',
        '3',
        '1',
        '"A"',
        '2',
        '"BB"',
        '5',
        '"CCC"',
        '/end',
        'COMPU_VTAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 1);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outString, 'A');
      expect(file.project.modules[0].computeTables[0].table[1].outString, 'BB');
      expect(file.project.modules[0].computeTables[0].table[2].outString, 'CCC');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);
    });

    test('Parse mandatory mutiple', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_VTAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_VERB',
        '3',
        '1',
        '"A"',
        '2',
        '"BB"',
        '5',
        '"CCC"',
        '/end',
        'COMPU_VTAB',
        '/begin',
        'COMPU_VTAB',
        'test_ct2',
        '"This is a test ct2"',
        'TAB_VERB',
        '2',
        '6',
        '"X"',
        '7',
        '"Y"',
        '/end',
        'COMPU_VTAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 2);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outString, 'A');
      expect(file.project.modules[0].computeTables[0].table[1].outString, 'BB');
      expect(file.project.modules[0].computeTables[0].table[2].outString, 'CCC');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);

      expect(file.project.modules[0].computeTables[1].name, 'test_ct2');
      expect(file.project.modules[0].computeTables[1].description, 'This is a test ct2');
      expect(file.project.modules[0].computeTables[1].table.length, 2);
      expect(file.project.modules[0].computeTables[1].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeTables[1].table[0].x, 6.0);
      expect(file.project.modules[0].computeTables[1].table[1].x, 7.0);
      expect(file.project.modules[0].computeTables[1].table[0].outString, 'X');
      expect(file.project.modules[0].computeTables[1].table[1].outString, 'Y');
      expect(file.project.modules[0].computeTables[1].fallbackValue, null);
      expect(file.project.modules[0].computeTables[1].fallbackValueNumeric, null);
    });

    test('Parse optional DEFAULT_VALUE', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_VTAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_VERB',
        '3',
        '1',
        '"A"',
        '2',
        '"BB"',
        '5',
        '"CCC"',
        'DEFAULT_VALUE',
        '"N/A"',
        '/end',
        'COMPU_VTAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 1);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outString, 'A');
      expect(file.project.modules[0].computeTables[0].table[1].outString, 'BB');
      expect(file.project.modules[0].computeTables[0].table[2].outString, 'CCC');
      expect(file.project.modules[0].computeTables[0].fallbackValue, 'N/A');
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);
    });
  });
}
