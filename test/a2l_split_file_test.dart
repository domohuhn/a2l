import 'package:a2l/src/a2l_split_file.dart';
import 'package:test/test.dart';

void main() {
  group('Remove Comments', () {
    test('No comments', () {
      expect(removeComments(textNoComments), textNoComments);
    });

    test('Line comments', () {
      expect(removeComments(textLineComments), textNoComments);
    });

    test('Block comments', () {
      expect(removeComments(textBlockComments), textNoComments);
    });

    test('mixed comments', () {
      expect(removeComments(textMixedComments), textNoComments);
    });
  });

  group('Split file', (){

    test('No comments', () {
      expect(splitA2L(textNoComments), expectedSplit);
    });
    
    test('Line comments', () {
      expect(splitA2L(textLineComments), expectedSplit);
    });
    
    test('Block comments', () {
      expect(splitA2L(textBlockComments), expectedSplit);
    });
    
    test('mixed comments', () {
      expect(splitA2L(textMixedComments), expectedSplit);
    });
    test('Exception1', () {
      expect(() => splitA2L(textEx1), throwsException);
    });

    test('Exception2', () {
      expect(() => splitA2L(textEx2), throwsException);
    });

  });
}

List<String> expectedSplit = [
'THIS',
'IS',
'A',
'LONG','TEXT',
'IT',
'HAS',
'NO',
'COMMENTS',
'but', '123',
'numbers', '23.345',
'Text.Joined',
'/begin', 'DATA', '"some strings"',
'/end'
];

var textNoComments = '''
THIS IS A LONG TEXT
IT
HAS
NO
COMMENTS
but 123
numbers 23.345
Text.Joined
/begin DATA "some strings"
/end
''';

var textEx1 = '''
THIS IS A LONG TEXT
IT
HAS
NO
COMMENTS
but 123
numbers 23.345
Text.Joined
/begin DATA a"some strings"
/end
''';

var textEx2 = '''
THIS IS A LONG TEXT
IT
HAS
NO
COMMENTS
but 123
numbers 23.345
Text.Joined
/begin DATA "some strings"a
/end
''';

var textLineComments = '''
THIS IS A LONG TEXT
IT// this is a comment
HAS
NO
// this is another comment
COMMENTS
but 123
numbers 23.345
Text.Joined
/begin DATA "some strings"
/end
''';

var textBlockComments = '''
THIS IS A LONG TEXT
IT/* this is a comment
this is another comment */
HAS
NO
COMMENTS
but 123
numbers 23.345
Text.Joined
/begin DATA "some strings"
/end
''';

var textMixedComments = '''
THIS IS A LONG TEXT
IT/* this is a comment
// mixed comment block
this is another comment */
HAS// single line comm
//other comment
NO
/* aaaa */COMMENTS
but 123
numbers 23.345
Text.Joined
/begin DATA "some strings"
/end
''';