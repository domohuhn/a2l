import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse compute methods', () {
    test('Parse mandatory', () {
      prepareTestData(
          parser, ['/begin', 'COMPU_METHOD', 'test_cm', '"This is a test cm"', 'IDENTICAL', '"%8.4"', '"[m]"', '/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.IDENTICAL);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, null);
      expect(file.project.modules[0].computeMethods[0].coefficientB, null);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);
    });

    test('Parse mandatory multiple', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'IDENTICAL',
        '"%8.4"',
        '"[m]"',
        '/end',
        'COMPU_METHOD',
        '/begin',
        'COMPU_METHOD',
        'test_cm2',
        '"This is a test cm2"',
        'LINEAR',
        '"%7.3"',
        '"[s]"',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 2);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.IDENTICAL);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, null);
      expect(file.project.modules[0].computeMethods[0].coefficientB, null);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);

      expect(file.project.modules[0].computeMethods[1].name, 'test_cm2');
      expect(file.project.modules[0].computeMethods[1].description, 'This is a test cm2');
      expect(file.project.modules[0].computeMethods[1].type, ComputeMethodType.LINEAR);
      expect(file.project.modules[0].computeMethods[1].format, '%7.3');
      expect(file.project.modules[0].computeMethods[1].unit, '[s]');
      expect(file.project.modules[0].computeMethods[1].coefficientA, null);
      expect(file.project.modules[0].computeMethods[1].coefficientB, null);
      expect(file.project.modules[0].computeMethods[1].coefficientC, null);
      expect(file.project.modules[0].computeMethods[1].coefficientD, null);
      expect(file.project.modules[0].computeMethods[1].coefficientE, null);
      expect(file.project.modules[0].computeMethods[1].coefficientF, null);
      expect(file.project.modules[0].computeMethods[1].formula, null);
      expect(file.project.modules[0].computeMethods[1].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[1].referencedTable, null);
      expect(file.project.modules[0].computeMethods[1].referencedUnit, null);
    });

    test('Parse optional COEFFS', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'RAT_FUNC',
        '"%8.4"',
        '"[m]"',
        'COEFFS',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.RAT_FUNC);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, 1.0);
      expect(file.project.modules[0].computeMethods[0].coefficientB, 2.0);
      expect(file.project.modules[0].computeMethods[0].coefficientC, 3.0);
      expect(file.project.modules[0].computeMethods[0].coefficientD, 4.0);
      expect(file.project.modules[0].computeMethods[0].coefficientE, 5.0);
      expect(file.project.modules[0].computeMethods[0].coefficientF, 6.0);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);
    });
    test('Parse optional COEFFS_LINEAR', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'LINEAR',
        '"%8.4"',
        '"[m]"',
        'COEFFS_LINEAR',
        '1',
        '2',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.LINEAR);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, 1.0);
      expect(file.project.modules[0].computeMethods[0].coefficientB, 2.0);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);
    });

    test('Parse optional COMPU_TAB_REF', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'TAB_VERB',
        '"%8.4"',
        '"[m]"',
        'COMPU_TAB_REF',
        'tab_ref',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, null);
      expect(file.project.modules[0].computeMethods[0].coefficientB, null);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, 'tab_ref');
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);
    });

    test('Parse optional FORMULA', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'TAB_VERB',
        '"%8.4"',
        '"[m]"',
        '/begin',
        'FORMULA',
        '"3*X1/100 + 22.7"',
        'FORMULA_INV',
        '"5.0-X1"',
        '/end',
        'FORMULA',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, null);
      expect(file.project.modules[0].computeMethods[0].coefficientB, null);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula!.formula, '3*X1/100 + 22.7');
      expect(file.project.modules[0].computeMethods[0].formula!.inverseFormula, '5.0-X1');
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);
    });
    test('Parse optional REF_UNIT', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'TAB_VERB',
        '"%8.4"',
        '"[m]"',
        'REF_UNIT',
        'unit_m',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, null);
      expect(file.project.modules[0].computeMethods[0].coefficientB, null);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, null);
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, 'unit_m');
    });

    test('Parse optional STATUS_STRING_REF', () {
      prepareTestData(parser, [
        '/begin',
        'COMPU_METHOD',
        'test_cm',
        '"This is a test cm"',
        'TAB_VERB',
        '"%8.4"',
        '"[m]"',
        'STATUS_STRING_REF',
        'tab_stat',
        '/end',
        'COMPU_METHOD'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficientA, null);
      expect(file.project.modules[0].computeMethods[0].coefficientB, null);
      expect(file.project.modules[0].computeMethods[0].coefficientC, null);
      expect(file.project.modules[0].computeMethods[0].coefficientD, null);
      expect(file.project.modules[0].computeMethods[0].coefficientE, null);
      expect(file.project.modules[0].computeMethods[0].coefficientF, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referencedStatusString, 'tab_stat');
      expect(file.project.modules[0].computeMethods[0].referencedTable, null);
      expect(file.project.modules[0].computeMethods[0].referencedUnit, null);
    });
  });
}
