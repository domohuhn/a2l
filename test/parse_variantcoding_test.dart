// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/variant_coding.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse variant mandatory', () {
    test('one', () {
      prepareTestData(
          parser, ['/begin', 'VARIANT_CODING', '/end', 'VARIANT_CODING']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var mod = file.project.modules[0];
      // default values
      expect(mod.coding!.separator, '.');
      expect(mod.coding!.namingScheme, VariantNaming.NUMERIC);
      expect(mod.coding!.enumerations.length, 0);
      expect(mod.coding!.characteristics.length, 0);
      expect(mod.coding!.forbidden.length, 0);
    });

    test('multiple', () {
      prepareTestData(parser, [
        '/begin',
        'VARIANT_CODING',
        '/end',
        'VARIANT_CODING',
        '/begin',
        'VARIANT_CODING',
        '/end',
        'VARIANT_CODING'
      ]);
      expect(() => parser.parse(), throwsException);
    });
  });

  group('Parse variant optional', () {
    test('VAR_SEPARATOR', () {
      prepareTestData(parser, [
        '/begin',
        'VARIANT_CODING',
        'VAR_SEPARATOR',
        '"_"',
        '/end',
        'VARIANT_CODING'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var mod = file.project.modules[0];
      expect(mod.coding!.separator, '_');
      expect(mod.coding!.namingScheme, VariantNaming.NUMERIC);
    });

    test('VAR_NAMING', () {
      prepareTestData(parser, [
        '/begin',
        'VARIANT_CODING',
        'VAR_NAMING',
        'ALPHA',
        '/end',
        'VARIANT_CODING'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var mod = file.project.modules[0];
      expect(mod.coding!.separator, '.');
      expect(mod.coding!.namingScheme, VariantNaming.ALPHA);
    });

    test('VAR_CRITERION', () {
      prepareTestData(parser, [
        '/begin',
        'VARIANT_CODING',
        '/begin',
        'VAR_CRITERION',
        'Gear',
        '"Type of transmission"',
        'stick',
        'auto',
        'VAR_MEASUREMENT',
        'AAA',
        'VAR_SELECTION_CHARACTERISTIC',
        'BBB',
        '/end',
        'VAR_CRITERION',
        '/end',
        'VARIANT_CODING'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var mod = file.project.modules[0];
      expect(mod.coding!.separator, '.');
      expect(mod.coding!.namingScheme, VariantNaming.NUMERIC);
      expect(mod.coding!.enumerations.length, 1);
      expect(mod.coding!.enumerations[0].name, 'Gear');
      expect(mod.coding!.enumerations[0].description, 'Type of transmission');
      expect(mod.coding!.enumerations[0].values.length, 2);
      expect(mod.coding!.enumerations[0].values[0], 'stick');
      expect(mod.coding!.enumerations[0].values[1], 'auto');
      expect(mod.coding!.enumerations[0].measurement, 'AAA');
      expect(mod.coding!.enumerations[0].characteristic, 'BBB');
    });

    test('VAR_FORBIDDEN_COMB', () {
      prepareTestData(parser, [
        '/begin',
        'VARIANT_CODING',
        '/begin',
        'VAR_FORBIDDEN_COMB',
        'Gear',
        'stick',
        'Engine',
        'electric',
        '/end',
        'VAR_FORBIDDEN_COMB',
        '/end',
        'VARIANT_CODING'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var mod = file.project.modules[0];
      expect(mod.coding!.separator, '.');
      expect(mod.coding!.namingScheme, VariantNaming.NUMERIC);
      expect(mod.coding!.forbidden.length, 1);
      expect(mod.coding!.forbidden[0].comibination[0].name, 'Gear');
      expect(mod.coding!.forbidden[0].comibination[1].name, 'Engine');
      expect(mod.coding!.forbidden[0].comibination[0].value, 'stick');
      expect(mod.coding!.forbidden[0].comibination[1].value, 'electric');
    });

    test('VAR_CHARACTERISTIC', () {
      prepareTestData(parser, [
        '/begin',
        'VARIANT_CODING',
        '/begin',
        'VAR_CHARACTERISTIC',
        'Moo',
        'Gear',
        '/begin',
        'VAR_ADDRESS',
        '0x1234',
        '0x5678',
        '/end',
        'VAR_ADDRESS',
        '/end',
        'VAR_CHARACTERISTIC',
        '/end',
        'VARIANT_CODING'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var mod = file.project.modules[0];
      expect(mod.coding!.separator, '.');
      expect(mod.coding!.namingScheme, VariantNaming.NUMERIC);
      expect(mod.coding!.characteristics.length, 1);
      expect(mod.coding!.characteristics[0].name, 'Moo');
      expect(mod.coding!.characteristics[0].enumerations.length, 1);
      expect(mod.coding!.characteristics[0].enumerations[0], 'Gear');
      expect(mod.coding!.characteristics[0].address.length, 2);
      expect(mod.coding!.characteristics[0].address[0], 0x1234);
      expect(mod.coding!.characteristics[0].address[1], 0x5678);
    });
  });
}
