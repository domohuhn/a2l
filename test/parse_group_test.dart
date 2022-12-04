import 'package:a2l/src/a2l_parser.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse groups', () {
    test('Parse mandatory', () {
      prepareTestData(parser, ['/begin', 'GROUP', 'TEST.GRP', '"This is a test group"', '/end', 'GROUP']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].functions.length, 0);
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].measurements.length, 0);
      expect(grps[0].groups.length, 0);
    });

    test('Parse mandatory multiple', () {
      prepareTestData(parser, [
        '/begin',
        'GROUP',
        'TEST.GRP',
        '"This is a test group"',
        '/end',
        'GROUP',
        '/begin',
        'GROUP',
        'TEST.GRP2',
        '"This is a test group2"',
        '/end',
        'GROUP'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 2);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].functions.length, 0);
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].measurements.length, 0);
      expect(grps[0].groups.length, 0);

      expect(grps[1].name, 'TEST.GRP2');
      expect(grps[1].description, 'This is a test group2');
      expect(grps[1].root, false);
      expect(grps[1].annotations.length, 0);
      expect(grps[1].functions.length, 0);
      expect(grps[1].characteristics.length, 0);
      expect(grps[1].measurements.length, 0);
      expect(grps[1].groups.length, 0);
    });

    test('Parse optional ROOT', () {
      prepareTestData(parser, ['/begin', 'GROUP', 'TEST.GRP', '"This is a test group"', 'ROOT', '/end', 'GROUP']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, true);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].functions.length, 0);
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].measurements.length, 0);
      expect(grps[0].groups.length, 0);
    });

    test('Parse optional ANNOTATION', () {
      prepareTestData(
          parser, ['/begin', 'GROUP', 'TEST.GRP', '"This is a test group"', '/begin', 'ANNOTATION', '/end', 'ANNOTATION', '/end', 'GROUP']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 1);
      expect(grps[0].functions.length, 0);
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].measurements.length, 0);
      expect(grps[0].groups.length, 0);
    });

    test('Parse optional REF_CHARACTERISTIC', () {
      prepareTestData(parser, [
        '/begin',
        'GROUP',
        'TEST.GRP',
        '"This is a test group"',
        '/begin',
        'REF_CHARACTERISTIC',
        'AAA',
        'BBB',
        '/end',
        'REF_CHARACTERISTIC',
        '/end',
        'GROUP'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].functions.length, 0);
      expect(grps[0].characteristics.length, 2);
      expect(grps[0].characteristics[0], 'AAA');
      expect(grps[0].characteristics[1], 'BBB');
      expect(grps[0].measurements.length, 0);
      expect(grps[0].groups.length, 0);
    });

    test('Parse optional REF_MEASUREMENT', () {
      prepareTestData(parser, [
        '/begin',
        'GROUP',
        'TEST.GRP',
        '"This is a test group"',
        '/begin',
        'REF_MEASUREMENT',
        'AAA',
        'BBB',
        '/end',
        'REF_MEASUREMENT',
        '/end',
        'GROUP'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].functions.length, 0);
      expect(grps[0].measurements.length, 2);
      expect(grps[0].measurements[0], 'AAA');
      expect(grps[0].measurements[1], 'BBB');
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].groups.length, 0);
    });

    test('Parse optional SUB_GROUP', () {
      prepareTestData(parser, [
        '/begin',
        'GROUP',
        'TEST.GRP',
        '"This is a test group"',
        '/begin',
        'SUB_GROUP',
        'AAA',
        'BBB',
        '/end',
        'SUB_GROUP',
        '/end',
        'GROUP'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].functions.length, 0);
      expect(grps[0].groups.length, 2);
      expect(grps[0].groups[0], 'AAA');
      expect(grps[0].groups[1], 'BBB');
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].measurements.length, 0);
    });

    test('Parse optional FUNCTION_LIST', () {
      prepareTestData(parser, [
        '/begin',
        'GROUP',
        'TEST.GRP',
        '"This is a test group"',
        '/begin',
        'FUNCTION_LIST',
        'AAA',
        'BBB',
        '/end',
        'FUNCTION_LIST',
        '/end',
        'GROUP'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].name, 'TEST.GRP');
      expect(grps[0].description, 'This is a test group');
      expect(grps[0].root, false);
      expect(grps[0].annotations.length, 0);
      expect(grps[0].groups.length, 0);
      expect(grps[0].functions.length, 2);
      expect(grps[0].functions[0], 'AAA');
      expect(grps[0].functions[1], 'BBB');
      expect(grps[0].characteristics.length, 0);
      expect(grps[0].measurements.length, 0);
    });

    test('Parse optional IF_DATA', () {
      prepareTestData(parser, [
        '/begin',
        'GROUP',
        'TEST.GRP',
        '"This is a test group"',
        '/begin',
        'IF_DATA',
        'AAA',
        '/end',
        'IF_DATA',
        '/end',
        'GROUP'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var grps = file.project.modules[0].groups;
      expect(grps.length, 1);
      expect(grps[0].interfaceData.length, 1);
      expect(grps[0].interfaceData[0], 'AAA');
      expect(grps[0].toFileContents(0).contains('/begin IF_DATA'), true);
    });
  });
}
