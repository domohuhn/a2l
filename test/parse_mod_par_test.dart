import 'package:a2l/src/a2l_parser.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse mandatory', (){
    test('Parse one', (){
      prepareTestData(parser, ['/begin','MOD_PAR', '"Description of pars module pars"', '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.description, 'Description of pars module pars');
      expect(pars.calibrationOffset, null);
      expect(pars.controlUnit, null);
      expect(pars.cpuType, null);
      expect(pars.customer, null);
      expect(pars.customerNumber, null);
      expect(pars.eepromIdentifiers.length, 0);
      expect(pars.epromIdentifier, null);
      expect(pars.numberOfInterfaces, null);
      expect(pars.phoneNumber, null);
      expect(pars.supplier, null);
      expect(pars.systemConstants.length, 0);
      expect(pars.user, null);
      expect(pars.version, null);
    });

    test('Parse multiple', (){
      prepareTestData(parser, ['/begin','MOD_PAR', '"Description of pars module data"', '/end', 'MOD_PAR', '/begin','MOD_PAR', '"Description of pars module data"', '/end', 'MOD_PAR']);
      expect(() => parser.parse(), throwsException);
    });
  });

  
  group('Parse optional', (){
    test('ADDR_EPK', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'ADDR_EPK', '0x12345',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.eepromIdentifiers.length, 1);
      expect(pars.eepromIdentifiers[0], 0x12345);
    });

    test('CPU_TYPE', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'CPU_TYPE', '"ARMv8"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.cpuType, 'ARMv8');
    });

    test('CUSTOMER', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'CUSTOMER', '"Moo"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.customer, 'Moo');
    });

    test('CUSTOMER_NO', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'CUSTOMER_NO', '"123456"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.customerNumber, '123456');
    });

    test('ECU', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'ECU', '"ECUNAME"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.controlUnit, 'ECUNAME');
    });

    test('ECU_CALIBRATION_OFFSET', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'ECU_CALIBRATION_OFFSET', '0x1000',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.calibrationOffset, 0x1000);
    });

    test('EPK', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'EPK', '"Some ID"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.epromIdentifier, 'Some ID');
    });

    test('NO_OF_INTERFACES', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'NO_OF_INTERFACES', '5',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.numberOfInterfaces, 5);
    });

    test('PHONE_NO', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'PHONE_NO', '"555-12345"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.phoneNumber, '555-12345');
    });
    
    test('SUPPLIER', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'SUPPLIER', '"XCP Ltd"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.supplier, 'XCP Ltd');
    });

    test('SYSTEM_CONSTANT', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'SYSTEM_CONSTANT', '"Pi"', '"3.141"',
       'SYSTEM_CONSTANT', '"E"', '"2.718"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.systemConstants.length, 2);
      expect(pars.systemConstants[0].name, 'Pi');
      expect(pars.systemConstants[0].value, '3.141');
      expect(pars.systemConstants[1].name, 'E');
      expect(pars.systemConstants[1].value, '2.718');
    });

    test('USER', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'USER', '"Person"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.user, 'Person');
    });

    test('VERSION', (){
      prepareTestData(parser, ['/begin','MOD_PAR','"Description of pars module data"',
       'VERSION', '"v1.0.0"',
       '/end', 'MOD_PAR']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.version, 'v1.0.0');
    });
    
    
    
    

  });
}


