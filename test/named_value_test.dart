import 'package:a2l/src/a2l_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Parse values', () {
    var parser = TokenParser();
    parser.currentIndex = 0;
    final list = ['somestuff', 'ASAP2_VERSION', '1', '63', '/begin', 'PROJECT', 'Moo', '"MooProject"', '/end', 'PROJECT', 'xxx', 'sdf', 'asaasd', 'A2ML_VERSION', '2', '20'];
    parser.tokens = [];
    parser.tokens.addAll(list);
    var major = 0;
    var minor = 0;
    var values = <Value>[
        Value('Major a2l version', ValueType.integer, (ValueType t, String s) {
          major = int.parse(s);
        }),
        Value('Minor a2l version', ValueType.integer, (ValueType t, String s) {
          minor = int.parse(s);
        })
      ];

    test('Parse two values', () {
      parser.currentIndex = 2;
      parser.parseRequiredOrderedElements(values, parser.currentIndex+2);
      expect(major, 1);
      expect(minor, 63);
    });

    test('Parse two values exception on error', () {
      parser.currentIndex = 3;
      expect(() => parser.parseRequiredOrderedElements(values, parser.currentIndex+2), throwsException);
    });

    test('find matching end', (){
      parser.currentIndex = 4;
      expect(parser.findMatchingEndToken(), 8);
    });
    
    test('find matching end - no begin token', (){
      parser.currentIndex = 5;
      expect(parser.findMatchingEndToken(), 5);
    });
    
    test('find matching end - no end token', (){
      parser.currentIndex = 10;
      parser.tokens[10] = '/begin';
      expect(() => parser.findMatchingEndToken(), throwsException);
    });

  });

}