import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse compute table', () {
    test('Parse mandatory', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_TAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_NOINTP',
        '3',
        '1',
        '4.25',
        '2',
        '8.5',
        '5',
        '11',
        '/end',
        'COMPU_TAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 1);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_NOINTP);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outNumeric, 4.25);
      expect(file.project.modules[0].computeTables[0].table[1].outNumeric, 8.5);
      expect(file.project.modules[0].computeTables[0].table[2].outNumeric, 11);
      expect(file.project.modules[0].computeTables[0].table[0].outString, '4.25');
      expect(file.project.modules[0].computeTables[0].table[1].outString, '8.5');
      expect(file.project.modules[0].computeTables[0].table[2].outString, '11');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);
    });

    test('Parse mandatory multiple', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_TAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_NOINTP',
        '3',
        '1',
        '4.25',
        '2',
        '8.5',
        '5',
        '11',
        '/end',
        'COMPU_TAB',
        '/begin',
        'COMPU_TAB',
        'test_ct2',
        '"This is a test ct2"',
        'TAB_INTP',
        '2',
        '3',
        '5.0',
        '4',
        '9.0',
        '/end',
        'COMPU_TAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 2);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_NOINTP);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outNumeric, 4.25);
      expect(file.project.modules[0].computeTables[0].table[1].outNumeric, 8.5);
      expect(file.project.modules[0].computeTables[0].table[2].outNumeric, 11);
      expect(file.project.modules[0].computeTables[0].table[0].outString, '4.25');
      expect(file.project.modules[0].computeTables[0].table[1].outString, '8.5');
      expect(file.project.modules[0].computeTables[0].table[2].outString, '11');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);

      expect(file.project.modules[0].computeTables[1].name, 'test_ct2');
      expect(file.project.modules[0].computeTables[1].description, 'This is a test ct2');
      expect(file.project.modules[0].computeTables[1].table.length, 2);
      expect(file.project.modules[0].computeTables[1].type, ComputeMethodType.TAB_INTP);
      expect(file.project.modules[0].computeTables[1].table[0].x, 3.0);
      expect(file.project.modules[0].computeTables[1].table[1].x, 4.0);
      expect(file.project.modules[0].computeTables[1].table[0].outNumeric, 5.0);
      expect(file.project.modules[0].computeTables[1].table[1].outNumeric, 9.0);
      expect(file.project.modules[0].computeTables[1].table[0].outString, '5.0');
      expect(file.project.modules[0].computeTables[1].table[1].outString, '9.0');
      expect(file.project.modules[0].computeTables[1].fallbackValue, null);
      expect(file.project.modules[0].computeTables[1].fallbackValueNumeric, null);
    });

    test('Parse optional DEFAULT_VALUE', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_TAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_NOINTP',
        '3',
        '1',
        '4.25',
        '2',
        '8.5',
        '5',
        '11',
        'DEFAULT_VALUE',
        '"Moo"',
        '/end',
        'COMPU_TAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 1);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_NOINTP);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outNumeric, 4.25);
      expect(file.project.modules[0].computeTables[0].table[1].outNumeric, 8.5);
      expect(file.project.modules[0].computeTables[0].table[2].outNumeric, 11);
      expect(file.project.modules[0].computeTables[0].table[0].outString, '4.25');
      expect(file.project.modules[0].computeTables[0].table[1].outString, '8.5');
      expect(file.project.modules[0].computeTables[0].table[2].outString, '11');
      expect(file.project.modules[0].computeTables[0].fallbackValue, 'Moo');
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);
    });

    test('Parse optional DEFAULT_VALUE_NUMERIC', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_TAB',
        'test_ct',
        '"This is a test ct"',
        'TAB_NOINTP',
        '3',
        '1',
        '4.25',
        '2',
        '8.5',
        '5',
        '11',
        'DEFAULT_VALUE_NUMERIC',
        '42.0',
        '/end',
        'COMPU_TAB'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables.length, 1);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_NOINTP);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].outNumeric, 4.25);
      expect(file.project.modules[0].computeTables[0].table[1].outNumeric, 8.5);
      expect(file.project.modules[0].computeTables[0].table[2].outNumeric, 11);
      expect(file.project.modules[0].computeTables[0].table[0].outString, '4.25');
      expect(file.project.modules[0].computeTables[0].table[1].outString, '8.5');
      expect(file.project.modules[0].computeTables[0].table[2].outString, '11');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, 42.0);
    });
  });
}
