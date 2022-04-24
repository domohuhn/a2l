import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/memory_layout.dart';
import 'package:a2l/src/a2l_tree/memory_segment.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse mandatory calibration method', (){
    test('Parse one', (){
      prepareTestData(parser, ['/begin','MOD_PAR', '"Description of pars module pars"',
      '/begin', 'CALIBRATION_METHOD', '"SERAM"', '1', '/end', 'CALIBRATION_METHOD',
      '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.calibrationMethods.length, 1);
      var data = pars.calibrationMethods;
      expect(data[0].method,'SERAM');
      expect(data[0].version, 1);
      expect(data[0].handleText, null);
      expect(data[0].handles.length, 0);
    });

    test('Parse multiple', (){
      prepareTestData(parser, ['/begin','MOD_PAR', '"Description of pars module pars"',
      '/begin', 'CALIBRATION_METHOD', '"InCircuit"', '1', '/end', 'CALIBRATION_METHOD',
      '/begin', 'CALIBRATION_METHOD', '"DSERAP"', '2', '/end', 'CALIBRATION_METHOD',
      '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.calibrationMethods.length, 2);
      var data = pars.calibrationMethods;
      expect(data[0].method,'InCircuit');
      expect(data[0].version, 1);
      expect(data[0].handleText, null);
      expect(data[0].handles.length, 0);
      
      expect(data[1].method,'DSERAP');
      expect(data[1].version, 2);
      expect(data[1].handleText, null);
      expect(data[1].handles.length, 0);
    });
  });

  
  group('Parse optional memory segment', (){
    test('CALIBRATION_HANDLE', (){
      prepareTestData(parser, ['/begin','MOD_PAR', '"Description of pars module pars"',
      '/begin', 'CALIBRATION_METHOD', '"BSERAP"', '1', '/begin', 'CALIBRATION_HANDLE', '1', '2', '3', 'CALIBRATION_HANDLE_TEXT', '"TEXT"', '/end', 'CALIBRATION_HANDLE', '/end', 'CALIBRATION_METHOD',
      '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.calibrationMethods.length, 1);
      var data = pars.calibrationMethods;
      expect(data[0].method,'BSERAP');
      expect(data[0].version, 1);
      expect(data[0].handleText, 'TEXT');
      expect(data[0].handles.length, 3);
      expect(data[0].handles[0], 1);
      expect(data[0].handles[1], 2);
      expect(data[0].handles[2], 3);
    });
  });

}


