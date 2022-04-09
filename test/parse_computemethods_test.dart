import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse compute methods', (){
    test('Parse mandatory', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'IDENTICAL', '"%8.4"', '"[m]"', '/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.IDENTICAL);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
    });

    test('Parse mandatory multiple', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'IDENTICAL', '"%8.4"', '"[m]"', '/end', 'COMPU_METHOD',
      '/begin','COMPU_METHOD','test_cm2', '"This is a test cm2"', 'LINEAR', '"%7.3"', '"[s]"', '/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 2);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.IDENTICAL);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
      
      expect(file.project.modules[0].computeMethods[1].name, 'test_cm2');
      expect(file.project.modules[0].computeMethods[1].description, 'This is a test cm2');
      expect(file.project.modules[0].computeMethods[1].type, ComputeMethodType.LINEAR);
      expect(file.project.modules[0].computeMethods[1].format, '%7.3');
      expect(file.project.modules[0].computeMethods[1].unit, '[s]');
      expect(file.project.modules[0].computeMethods[1].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[1].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[1].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[1].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[1].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[1].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[1].formula, null);
      expect(file.project.modules[0].computeMethods[1].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[1].referenced_table, null);
      expect(file.project.modules[0].computeMethods[1].referenced_unit, null);
    });

    test('Parse optional COEFFS', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'RAT_FUNC', '"%8.4"', '"[m]"',
       'COEFFS', '1', '2', '3', '4', '5', '6','/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.RAT_FUNC);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, 1.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, 2.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, 3.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, 4.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, 5.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, 6.0);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
    });
    test('Parse optional COEFFS_LINEAR', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'LINEAR', '"%8.4"', '"[m]"',
       'COEFFS_LINEAR', '1', '2','/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.LINEAR);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, 1.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, 2.0);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
    });

    test('Parse optional COMPU_TAB_REF', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'TAB_VERB', '"%8.4"', '"[m]"',
       'COMPU_TAB_REF', 'tab_ref','/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, 'tab_ref');
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
    });

    test('Parse optional FORMULA', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'TAB_VERB', '"%8.4"', '"[m]"',
       'FORMULA', '"3*X1/100 + 22.7"','/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, '3*X1/100 + 22.7');
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
    });
    test('Parse optional REF_UNIT', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'TAB_VERB', '"%8.4"', '"[m]"',
       'REF_UNIT', 'unit_m','/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, null);
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, 'unit_m');
    });

    test('Parse optional STATUS_STRING_REF', (){
      prepareTestData(parser, ['/begin','COMPU_METHOD','test_cm', '"This is a test cm"', 'TAB_VERB', '"%8.4"', '"[m]"',
       'STATUS_STRING_REF', 'tab_stat','/end', 'COMPU_METHOD']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].computeMethods.length, 1);
      expect(file.project.modules[0].computeMethods[0].name, 'test_cm');
      expect(file.project.modules[0].computeMethods[0].description, 'This is a test cm');
      expect(file.project.modules[0].computeMethods[0].type, ComputeMethodType.TAB_VERB);
      expect(file.project.modules[0].computeMethods[0].format, '%8.4');
      expect(file.project.modules[0].computeMethods[0].unit, '[m]');
      expect(file.project.modules[0].computeMethods[0].coefficient_a, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_b, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_c, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_d, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_e, null);
      expect(file.project.modules[0].computeMethods[0].coefficient_f, null);
      expect(file.project.modules[0].computeMethods[0].formula, null);
      expect(file.project.modules[0].computeMethods[0].referenced_statusString, 'tab_stat');
      expect(file.project.modules[0].computeMethods[0].referenced_table, null);
      expect(file.project.modules[0].computeMethods[0].referenced_unit, null);
    });
  });
}