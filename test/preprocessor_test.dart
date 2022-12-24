// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/a2l.dart';
import 'package:test/test.dart';

void main() {
  group('Split file', () {
    test('No comments', () {
      var tokens = convertFileContentsToTokens(textNoComments);
      expect(tokens.length, expectedSplit.length);
      for (var i = 0; i < tokens.length; ++i) {
        expect(tokens[i].text, expectedSplit[i]);
      }
    });

    test('Line comments', () {
      var tokens = convertFileContentsToTokens(textLineComments);
      expect(tokens.length, expectedSplit.length);
      for (var i = 0; i < tokens.length; ++i) {
        expect(tokens[i].text, expectedSplit[i]);
      }
    });

    test('Block comments', () {
      var tokens = convertFileContentsToTokens(textBlockComments);
      expect(tokens.length, expectedSplit.length);
      for (var i = 0; i < tokens.length; ++i) {
        expect(tokens[i].text, expectedSplit[i]);
      }
    });

    test('mixed comments', () {
      var tokens = convertFileContentsToTokens(textMixedComments);
      expect(tokens.length, expectedSplit.length);
      for (var i = 0; i < tokens.length; ++i) {
        expect(tokens[i].text, expectedSplit[i]);
      }
    });

    test('Passthrough blocks', () {
      var tokens = convertFileContentsToTokens(textPassthrough);
      expect(tokens.length, expectedSplitPassThrough.length);
      for (var i = 0; i < tokens.length; ++i) {
        print('$i : "${tokens[i].text}"');
        expect(tokens[i].text, expectedSplitPassThrough[i]);
      }
    });

    test('Exception1', () {
      expect(() => convertFileContentsToTokens(textEx1), throwsException);
    });

    test('Exception2', () {
      expect(() => convertFileContentsToTokens(textEx2), throwsException);
    });
  });
}

List<String> expectedSplit = [
  'THIS',
  'IS',
  'A',
  'LONG',
  'TEXT',
  'IT',
  'HAS',
  'NO',
  'COMMENTS',
  'but',
  '123',
  'numbers',
  '23.345',
  'Text.Joined',
  '/begin',
  'DATA',
  '"some strings"',
  '/end'
];


List<String> expectedSplitPassThrough = [
  'THIS',
  'IS',
  'A',
  'LONG',
  'TEXT',
  'IT',
  'HAS',
  'NO',
  'COMMENTS',
  'but',
  '123',
  'numbers',
  '23.345',
  'Text.Joined',
  '/begin', 'IF_DATA',
  ''' "some strings"
   This text should be 
      unmodified\n''',
  '/end', 'IF_DATA',
  '/begin', 'A2ML',
  ''' "some strings"
   This text should be 
      unmodified\n''',
  '/end', 'A2ML'
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

var textPassthrough = '''
THIS IS A LONG TEXT
IT
HAS
NO
COMMENTS
but 123
numbers 23.345
Text.Joined
/begin IF_DATA "some strings"
   This text should be 
      unmodified
/end IF_DATA
/begin A2ML "some strings"
   This text should be 
      unmodified
/end A2ML
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
