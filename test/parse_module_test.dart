import 'package:a2l/src/a2l_parser.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  parser.currentIndex = 0;
  final startList =
      convertStringsToTokens(['ASAP2_VERSION', '1', '63', 'A2ML_VERSION', '2', '20', '/begin', 'PROJECT', 'Moo', '"MooProject"']);
  final module1 = convertStringsToTokens(['/begin', 'MODULE', 'Test.Module', '"This is a test module"', '/end', 'MODULE']);
  final module2 = convertStringsToTokens(['/begin', 'MODULE', 'Test.Module2', '"This is a test module2"', '/end', 'MODULE']);
  final endList = convertStringsToTokens(['/end', 'PROJECT']);
  group('Parse project', () {
    test('Parse Versions', () {
      parser.currentIndex = 0;
      parser.tokens = [];
      parser.tokens.addAll(startList);
      parser.tokens.addAll(module1);
      parser.tokens.addAll(endList);
      var file = parser.parse();
      expect(file.a2lMajorVersion, 1);
      expect(file.a2lMinorVersion, 63);
      expect(file.a2mlMajorVersion, 2);
      expect(file.a2mlMinorVersion, 20);
    });

    test('No module', () {
      parser.currentIndex = 0;
      parser.tokens = [];
      parser.tokens.addAll(startList);
      parser.tokens.addAll(endList);
      expect(() => parser.parse(), throwsException);
    });
    test('Parse Versions - mandatory missing', () {
      parser.tokens = convertStringsToTokens([
        'somestuff',
        'A2ML_VERSION',
        '1',
        '63',
        '/begin',
        'PROJECT',
        'Moo',
        '/begin',
        'MODULE',
        'Test.Module',
        '"This is a test module"',
        '/end',
        'MODULE',
        '/end',
        'PROJECT',
        'asaasd'
      ]);
      parser.currentIndex = 0;
      expect(() => parser.parse(), throwsException);
    });

    test('Parse Project', () {
      parser.tokens = convertStringsToTokens([
        'ASAP2_VERSION',
        '1',
        '63',
        'A2ML_VERSION',
        '2',
        '20',
        '/begin',
        'PROJECT',
        'Moo',
        '"MooProject"',
        '/begin',
        'MODULE',
        'Test.Module',
        '"This is a test module"',
        '/end',
        'MODULE',
        '/end',
        'PROJECT'
      ]);
      parser.currentIndex = 0;
      var file = parser.parse();
      expect(file.project.name, 'Moo');
      expect(file.project.description, 'MooProject');
    });
    test('Parse Header', () {
      parser.tokens = convertStringsToTokens([
        'ASAP2_VERSION',
        '1',
        '63',
        'A2ML_VERSION',
        '2',
        '20',
        '/begin',
        'PROJECT',
        'Moo',
        '"MooProject"',
        '/begin',
        'HEADER',
        '"Commemt"',
        'VERSION',
        '"versio"',
        'PROJECT_NO',
        'XCP123',
        '/end',
        'HEADER',
        '/begin',
        'MODULE',
        'Test.Module',
        '"This is a test module"',
        '/end',
        'MODULE',
        '/end',
        'PROJECT'
      ]);
      parser.currentIndex = 0;
      var file = parser.parse();
      expect(file.project.header!.description, 'Commemt');
      expect(file.project.header!.version, 'versio');
      expect(file.project.header!.number, 'XCP123');
    });
  });
  group('Parse module', () {
    test('No module', () {
      parser.currentIndex = 0;
      parser.tokens = [];
      parser.tokens.addAll(startList);
      parser.tokens.addAll(endList);
      expect(() => parser.parse(), throwsException);
    });

    test('Parse empty module', () {
      parser.currentIndex = 0;
      parser.tokens = [];
      parser.tokens.addAll(startList);
      parser.tokens.addAll(module1);
      parser.tokens.addAll(endList);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].name, 'Test.Module');
      expect(file.project.modules[0].description, 'This is a test module');
    });

    test('Parse two empty modules', () {
      parser.currentIndex = 0;
      parser.tokens = [];
      parser.tokens.addAll(startList);
      parser.tokens.addAll(module1);
      parser.tokens.addAll(module2);
      parser.tokens.addAll(endList);
      var file = parser.parse();
      expect(file.project.modules.length, 2);
      expect(file.project.modules[0].name, 'Test.Module');
      expect(file.project.modules[0].description, 'This is a test module');
      expect(file.project.modules[1].name, 'Test.Module2');
      expect(file.project.modules[1].description, 'This is a test module2');
    });
  });
}
