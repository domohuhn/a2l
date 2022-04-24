import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse verbatim table range', () {
    test('Parse mandatory', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_VTAB_RANGE',
        'test_ct',
        '"This is a test ct"',
        '3',
        '1',
        '1',
        '"A"',
        '2',
        '5.0',
        '"BB"',
        '5',
        '1000',
        '"CCC"',
        '/end',
        'COMPU_VTAB_RANGE'
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
      expect(file.project.modules[0].computeTables[0].table[0].xUp, 1.0);
      expect(file.project.modules[0].computeTables[0].table[0].isFloat, false);
      expect(file.project.modules[0].computeTables[0].table[1].xUp, 5.0);
      expect(file.project.modules[0].computeTables[0].table[1].isFloat, true);
      expect(file.project.modules[0].computeTables[0].table[2].xUp, 1000.0);
      expect(file.project.modules[0].computeTables[0].table[2].isFloat, false);
      expect(file.project.modules[0].computeTables[0].table[0].outString, 'A');
      expect(file.project.modules[0].computeTables[0].table[1].outString, 'BB');
      expect(file.project.modules[0].computeTables[0].table[2].outString, 'CCC');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);
    });

    test('Parse mandatory mutiple', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_VTAB_RANGE',
        'test_ct',
        '"This is a test ct"',
        '3',
        '1',
        '1',
        '"A"',
        '2',
        '5.0',
        '"BB"',
        '5',
        '1000',
        '"CCC"',
        '/end',
        'COMPU_VTAB_RANGE',
        '/begin',
        'COMPU_VTAB_RANGE',
        'test_ct2',
        '"This is a test ct2"',
        '2',
        '1.0',
        '5.0',
        '"X"',
        '5.0',
        '9.0',
        '"YY"',
        '/end',
        'COMPU_VTAB_RANGE'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeTables[0].name, 'test_ct');
      expect(file.project.modules[0].computeTables[0].description, 'This is a test ct');
      expect(file.project.modules[0].computeTables[0].table.length, 3);
      expect(file.project.modules[0].computeTables[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeTables[0].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[0].table[1].x, 2.0);
      expect(file.project.modules[0].computeTables[0].table[2].x, 5.0);
      expect(file.project.modules[0].computeTables[0].table[0].xUp, 1.0);
      expect(file.project.modules[0].computeTables[0].table[0].isFloat, false);
      expect(file.project.modules[0].computeTables[0].table[1].xUp, 5.0);
      expect(file.project.modules[0].computeTables[0].table[1].isFloat, true);
      expect(file.project.modules[0].computeTables[0].table[2].xUp, 1000.0);
      expect(file.project.modules[0].computeTables[0].table[2].isFloat, false);
      expect(file.project.modules[0].computeTables[0].table[0].outString, 'A');
      expect(file.project.modules[0].computeTables[0].table[1].outString, 'BB');
      expect(file.project.modules[0].computeTables[0].table[2].outString, 'CCC');
      expect(file.project.modules[0].computeTables[0].fallbackValue, null);
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);

      expect(file.project.modules[0].computeTables[1].name, 'test_ct2');
      expect(file.project.modules[0].computeTables[1].description, 'This is a test ct2');
      expect(file.project.modules[0].computeTables[1].table.length, 2);
      expect(file.project.modules[0].computeTables[1].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeTables[1].table[0].x, 1.0);
      expect(file.project.modules[0].computeTables[1].table[0].xUp, 5.0);
      expect(file.project.modules[0].computeTables[1].table[0].isFloat, true);
      expect(file.project.modules[0].computeTables[1].table[0].outString, 'X');
      expect(file.project.modules[0].computeTables[1].table[1].x, 5.0);
      expect(file.project.modules[0].computeTables[1].table[1].xUp, 9.0);
      expect(file.project.modules[0].computeTables[1].table[1].isFloat, true);
      expect(file.project.modules[0].computeTables[1].table[1].outString, 'YY');
      expect(file.project.modules[0].computeTables[1].fallbackValue, null);
      expect(file.project.modules[0].computeTables[1].fallbackValueNumeric, null);
    });

    test('Parse optional DEFAULT_VALUE', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_VTAB_RANGE',
        'test_ct',
        '"This is a test ct"',
        '3',
        '1',
        '1',
        '"A"',
        '2',
        '5.0',
        '"BB"',
        '5',
        '1000',
        '"CCC"',
        'DEFAULT_VALUE',
        '"N/A"',
        '/end',
        'COMPU_VTAB_RANGE'
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
      expect(file.project.modules[0].computeTables[0].table[0].xUp, 1.0);
      expect(file.project.modules[0].computeTables[0].table[0].isFloat, false);
      expect(file.project.modules[0].computeTables[0].table[1].xUp, 5.0);
      expect(file.project.modules[0].computeTables[0].table[1].isFloat, true);
      expect(file.project.modules[0].computeTables[0].table[2].xUp, 1000.0);
      expect(file.project.modules[0].computeTables[0].table[2].isFloat, false);
      expect(file.project.modules[0].computeTables[0].table[0].outString, 'A');
      expect(file.project.modules[0].computeTables[0].table[1].outString, 'BB');
      expect(file.project.modules[0].computeTables[0].table[2].outString, 'CCC');
      expect(file.project.modules[0].computeTables[0].fallbackValue, 'N/A');
      expect(file.project.modules[0].computeTables[0].fallbackValueNumeric, null);
    });
  });
}
