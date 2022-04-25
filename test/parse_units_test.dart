import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/unit.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse units', () {
    test('Parse mandatory', () {
      prepareTestData(parser, ['/begin', 'UNIT', 'test_unit', '"This is a test unit"', '"[m]"', 'EXTENDED_SI', '/end', 'UNIT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].units.length, 1);
      expect(file.project.modules[0].units[0].name, 'test_unit');
      expect(file.project.modules[0].units[0].description, 'This is a test unit');
      expect(file.project.modules[0].units[0].display, '[m]');
      expect(file.project.modules[0].units[0].type, UnitType.EXTENDED_SI);
      expect(file.project.modules[0].units[0].referencedUnit, null);
      expect(file.project.modules[0].units[0].conversionLinearOffset, null);
      expect(file.project.modules[0].units[0].conversionLinearSlope, null);
      expect(file.project.modules[0].units[0].exponents, null);
      expect(file.project.modules[0].units[0].isValid(), true);
    });

    test('Parse mandatory, multiple units', () {
      prepareTestData(parser, [
        '/begin',
        'UNIT',
        'test_unit',
        '"This is a test unit"',
        '"[m]"',
        'EXTENDED_SI',
        '/end',
        'UNIT',
        '/begin',
        'UNIT',
        'test_unit2',
        '"This is a test unit2"',
        '"[m]2"',
        'DERIVED',
        '/end',
        'UNIT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].units.length, 2);
      expect(file.project.modules[0].units[0].name, 'test_unit');
      expect(file.project.modules[0].units[0].description, 'This is a test unit');
      expect(file.project.modules[0].units[0].display, '[m]');
      expect(file.project.modules[0].units[0].type, UnitType.EXTENDED_SI);
      expect(file.project.modules[0].units[1].name, 'test_unit2');
      expect(file.project.modules[0].units[1].description, 'This is a test unit2');
      expect(file.project.modules[0].units[1].display, '[m]2');
      expect(file.project.modules[0].units[1].type, UnitType.DERIVED);
    });

    test('Parse optional REF_UNIT', () {
      prepareTestData(
          parser, ['/begin', 'UNIT', 'test_unit', '"This is a test unit"', '"[m]"', 'EXTENDED_SI', 'REF_UNIT', 'otherU', '/end', 'UNIT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].units.length, 1);
      expect(file.project.modules[0].units[0].name, 'test_unit');
      expect(file.project.modules[0].units[0].description, 'This is a test unit');
      expect(file.project.modules[0].units[0].display, '[m]');
      expect(file.project.modules[0].units[0].type, UnitType.EXTENDED_SI);
      expect(file.project.modules[0].units[0].referencedUnit, 'otherU');
      expect(file.project.modules[0].units[0].isValid(), true);
    });
    test('Parse optional UNIT_CONVERSION', () {
      prepareTestData(parser, [
        '/begin',
        'UNIT',
        'test_unit',
        '"This is a test unit"',
        '"[m]"',
        'EXTENDED_SI',
        'UNIT_CONVERSION',
        '1.0',
        '2.0',
        '/end',
        'UNIT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].units.length, 1);
      expect(file.project.modules[0].units[0].name, 'test_unit');
      expect(file.project.modules[0].units[0].description, 'This is a test unit');
      expect(file.project.modules[0].units[0].display, '[m]');
      expect(file.project.modules[0].units[0].type, UnitType.EXTENDED_SI);
      expect(file.project.modules[0].units[0].conversionLinearOffset, 2.0);
      expect(file.project.modules[0].units[0].conversionLinearSlope, 1.0);
      expect(file.project.modules[0].units[0].isValid(), true);
    });
    test('Parse optional SI_EXPONENTS', () {
      prepareTestData(parser, [
        '/begin',
        'UNIT',
        'test_unit',
        '"This is a test unit"',
        '"[m]"',
        'EXTENDED_SI',
        'SI_EXPONENTS',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '/end',
        'UNIT'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].units.length, 1);
      expect(file.project.modules[0].units[0].name, 'test_unit');
      expect(file.project.modules[0].units[0].description, 'This is a test unit');
      expect(file.project.modules[0].units[0].display, '[m]');
      expect(file.project.modules[0].units[0].type, UnitType.EXTENDED_SI);
      expect(file.project.modules[0].units[0].exponents!.length, 1);
      expect(file.project.modules[0].units[0].exponents!.mass, 2);
      expect(file.project.modules[0].units[0].exponents!.time, 3);
      expect(file.project.modules[0].units[0].exponents!.electricCurrent, 4);
      expect(file.project.modules[0].units[0].exponents!.temperature, 5);
      expect(file.project.modules[0].units[0].exponents!.amountOfSubstance, 6);
      expect(file.project.modules[0].units[0].exponents!.luminousIntensity, 7);
      expect(file.project.modules[0].units[0].isValid(), true);
    });
  });

  group('Serialization', () {
    test('complete', () {
      var unit = Unit();
      unit.name = 'U.Test';
      unit.display = 'm';
      unit.description = 'Meter';
      unit.type = UnitType.EXTENDED_SI;
      unit.exponents = SIExponents();
      unit.exponents!.length = 1;
      unit.referencedUnit = 'U.Other';
      unit.conversionLinearSlope = 1.0;
      unit.conversionLinearOffset = 2.0;
      var rv = unit.toFileContents(1);
      final out = '''  /begin UNIT U.Test
    "Meter"
    "m" EXTENDED_SI
    REF_UNIT U.Other
    SI_EXPONENTS 1 0 0 0 0 0 0
    UNIT_CONVERSION 1.0 2.0
  /end UNIT

''';
      expect(rv, out);
    });
  });
}
