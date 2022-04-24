import 'package:a2l/src/a2l_parser.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse user rights mandatory', () {
    test('one', () {
      prepareTestData(parser, ['/begin', 'USER_RIGHTS', 'TEST.UR', '/end', 'USER_RIGHTS']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var ur = file.project.modules[0].userRights;
      expect(ur.length, 1);
      expect(ur[0].userId, 'TEST.UR');
      expect(ur[0].groups.length, 0);
      expect(ur[0].readOnly, false);
    });

    test('multiple', () {
      prepareTestData(
          parser, ['/begin', 'USER_RIGHTS', 'TEST.UR', '/end', 'USER_RIGHTS', '/begin', 'USER_RIGHTS', 'TEST.UR2', '/end', 'USER_RIGHTS']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var ur = file.project.modules[0].userRights;
      expect(ur.length, 2);
      expect(ur[0].userId, 'TEST.UR');
      expect(ur[0].groups.length, 0);
      expect(ur[0].readOnly, false);

      expect(ur[1].userId, 'TEST.UR2');
      expect(ur[1].groups.length, 0);
      expect(ur[1].readOnly, false);
    });
  });

  group('Parse user rights optional', () {
    test('READ_ONLY', () {
      prepareTestData(parser, ['/begin', 'USER_RIGHTS', 'TEST.UR', 'READ_ONLY', '/end', 'USER_RIGHTS']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var ur = file.project.modules[0].userRights;
      expect(ur.length, 1);
      expect(ur[0].userId, 'TEST.UR');
      expect(ur[0].groups.length, 0);
      expect(ur[0].readOnly, true);
    });

    test('REF_GROUP', () {
      prepareTestData(parser,
          ['/begin', 'USER_RIGHTS', 'TEST.UR', '/begin', 'REF_GROUP', 'AAA', 'BBB', 'CCC', '/end', 'REF_GROUP', '/end', 'USER_RIGHTS']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var ur = file.project.modules[0].userRights;
      expect(ur.length, 1);
      expect(ur[0].userId, 'TEST.UR');
      expect(ur[0].groups.length, 3);
      expect(ur[0].groups[0], 'AAA');
      expect(ur[0].groups[1], 'BBB');
      expect(ur[0].groups[2], 'CCC');
      expect(ur[0].readOnly, false);
    });
  });
}
