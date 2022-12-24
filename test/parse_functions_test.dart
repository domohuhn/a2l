// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_parser.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse functions mandatory', () {
    test('Parse one', () {
      prepareTestData(parser, ['/begin', 'FUNCTION', 'TEST.FUN', '"This is a test fun"', '/end', 'FUNCTION']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      expect(funs[0].name, 'TEST.FUN');
      expect(funs[0].description, 'This is a test fun');
      expect(funs[0].annotations.length, 0);
      expect(funs[0].functions.length, 0);
      expect(funs[0].definedCharacteristics.length, 0);
      expect(funs[0].characteristics.length, 0);
      expect(funs[0].inputMeasurements.length, 0);
      expect(funs[0].measurements.length, 0);
      expect(funs[0].outputMeasurements.length, 0);
      expect(funs[0].groups.length, 0);
    });

    test('Parse multiple', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/end',
        'FUNCTION',
        '/begin',
        'FUNCTION',
        'TEST.FUN2',
        '"This is a test fun2"',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 2);
      expect(funs[0].name, 'TEST.FUN');
      expect(funs[0].description, 'This is a test fun');
      expect(funs[0].annotations.length, 0);
      expect(funs[0].functions.length, 0);
      expect(funs[0].definedCharacteristics.length, 0);
      expect(funs[0].characteristics.length, 0);
      expect(funs[0].inputMeasurements.length, 0);
      expect(funs[0].measurements.length, 0);
      expect(funs[0].outputMeasurements.length, 0);
      expect(funs[0].groups.length, 0);

      expect(funs[1].name, 'TEST.FUN2');
      expect(funs[1].description, 'This is a test fun2');
      expect(funs[1].annotations.length, 0);
      expect(funs[1].functions.length, 0);
      expect(funs[1].definedCharacteristics.length, 0);
      expect(funs[1].characteristics.length, 0);
      expect(funs[1].inputMeasurements.length, 0);
      expect(funs[1].measurements.length, 0);
      expect(funs[1].outputMeasurements.length, 0);
      expect(funs[1].groups.length, 0);
    });
  });

  group('Parse functions optional', () {
    test('FUNCTION_VERSION', () {
      prepareTestData(
          parser, ['/begin', 'FUNCTION', 'TEST.FUN', '"This is a test fun"', 'FUNCTION_VERSION', '"v1.0.0"', '/end', 'FUNCTION']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      expect(funs[0].version, 'v1.0.0');
    });

    test('ANNOTATION', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'ANNOTATION',
        '/begin',
        'ANNOTATION_TEXT',
        '"AA\\n"',
        '"BB\\n"',
        '"CC\\n"',
        '/end',
        'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN',
        '"some origin"',
        'ANNOTATION_LABEL',
        '"some label"',
        '/end',
        'ANNOTATION',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final annotations = funs[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
    });

    test('IF_DATA', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'IF_DATA',
        'somestring',
        '/end',
        'IF_DATA',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      expect(funs[0].interfaceData.length, 1);
      expect(funs[0].interfaceData[0], 'somestring');
      expect(funs[0].toFileContents(0).contains('/begin IF_DATA'), true);
    });

    test('DEF_CHARACTERISTIC', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'DEF_CHARACTERISTIC',
        'AAA',
        'BBB',
        'CCC',
        '/end',
        'DEF_CHARACTERISTIC',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final data = funs[0].definedCharacteristics;
      expect(data.length, 3);
      expect(data[0], 'AAA');
      expect(data[1], 'BBB');
      expect(data[2], 'CCC');
    });

    test('REF_CHARACTERISTIC', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'REF_CHARACTERISTIC',
        'AAA',
        'BBB',
        'CCC',
        '/end',
        'REF_CHARACTERISTIC',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final data = funs[0].characteristics;
      expect(data.length, 3);
      expect(data[0], 'AAA');
      expect(data[1], 'BBB');
      expect(data[2], 'CCC');
    });

    test('IN_MEASUREMENT', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'IN_MEASUREMENT',
        'AAA',
        'BBB',
        'CCC',
        '/end',
        'IN_MEASUREMENT',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final data = funs[0].inputMeasurements;
      expect(data.length, 3);
      expect(data[0], 'AAA');
      expect(data[1], 'BBB');
      expect(data[2], 'CCC');
    });

    test('LOC_MEASUREMENT', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'LOC_MEASUREMENT',
        'AAA',
        'BBB',
        'CCC',
        '/end',
        'LOC_MEASUREMENT',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final data = funs[0].measurements;
      expect(data.length, 3);
      expect(data[0], 'AAA');
      expect(data[1], 'BBB');
      expect(data[2], 'CCC');
    });

    test('OUT_MEASUREMENT', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'OUT_MEASUREMENT',
        'AAA',
        'BBB',
        'CCC',
        '/end',
        'OUT_MEASUREMENT',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final data = funs[0].outputMeasurements;
      expect(data.length, 3);
      expect(data[0], 'AAA');
      expect(data[1], 'BBB');
      expect(data[2], 'CCC');
    });

    test('SUB_FUNCTION', () {
      prepareTestData(parser, [
        '/begin',
        'FUNCTION',
        'TEST.FUN',
        '"This is a test fun"',
        '/begin',
        'SUB_FUNCTION',
        'AAA',
        'BBB',
        'CCC',
        '/end',
        'SUB_FUNCTION',
        '/end',
        'FUNCTION'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var funs = file.project.modules[0].functions;
      expect(funs.length, 1);
      final data = funs[0].functions;
      expect(data.length, 3);
      expect(data[0], 'AAA');
      expect(data[1], 'BBB');
      expect(data[2], 'CCC');
    });
  });
}
