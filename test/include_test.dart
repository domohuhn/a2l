// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/file_loader.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/preprocessor.dart';
import 'package:test/test.dart';

class CallSequence {
  int method;
  String path;
  CallSequence(this.method, this.path);
}

class TestLoader extends FileLoader {
  TestLoader() : calls = [];

  List<CallSequence> calls;

  @override
  String read(String path) {
    calls.add(CallSequence(1, path));
    if (calls.length > 25) {
      throw ValidationError('Too many calls "$path"');
    }
    if (path == 'file1.a2l') {
      return file1;
    }
    if (path == 'other dir/file2.a2l') {
      return file2;
    }
    if (path == 'other dir/file3.a2l') {
      return file3;
    }
    if (path == 'other dir/file4.a2l') {
      return file4;
    }
    if (path == 'file5.a2l') {
      return file5;
    }
    throw ValidationError('Unknown path $path');
  }

  /// Returns the stack of loaded files.
  @override
  String stack() {
    calls.add(CallSequence(2, ''));
    return 'stack';
  }

  /// pops a file from the stack.
  @override
  void pop() {
    calls.add(CallSequence(3, ''));
  }
}

void main() {
  group('Parse file includes', () {
    test('simple', () {
      TestLoader loader = TestLoader();
      final text = processIncludes(file4, loader);
      expect(text, file5);
      expect(loader.calls.length, 2);
      expect(loader.calls[0].method, 1);
      expect(loader.calls[0].path, 'file5.a2l');
      expect(loader.calls[1].method, 3);
      expect(loader.calls[1].path, '');
    });

    test('nested', () {
      TestLoader loader = TestLoader();
      final text = processIncludes(file1, loader);
      expect(loader.calls.length, 4);
      expect(loader.calls[0].method, 1);
      expect(loader.calls[0].path, 'other dir/file4.a2l');
      expect(loader.calls[1].method, 1);
      expect(loader.calls[1].path, 'file5.a2l');
      expect(loader.calls[2].method, 3);
      expect(loader.calls[2].path, '');
      expect(loader.calls[3].method, 3);
      expect(loader.calls[3].path, '');
      expect(text, processedFile1);
    });

    test('multiple in one file', () {
      TestLoader loader = TestLoader();
      final text = processIncludes(mainFile, loader);
      expect(loader.calls.length, 10);
      expect(loader.calls[0].method, 1);
      expect(loader.calls[0].path, 'file1.a2l');
      expect(loader.calls[1].method, 1);
      expect(loader.calls[1].path, 'other dir/file4.a2l');
      expect(loader.calls[2].method, 1);
      expect(loader.calls[2].path, 'file5.a2l');
      expect(loader.calls[3].method, 3);
      expect(loader.calls[3].path, '');
      expect(loader.calls[4].method, 3);
      expect(loader.calls[4].path, '');
      expect(loader.calls[5].method, 3);
      expect(loader.calls[5].path, '');

      expect(loader.calls[6].method, 1);
      expect(loader.calls[6].path, 'other dir/file2.a2l');
      expect(loader.calls[7].method, 3);
      expect(loader.calls[7].path, '');

      expect(loader.calls[8].method, 1);
      expect(loader.calls[8].path, 'other dir/file3.a2l');
      expect(loader.calls[9].method, 3);
      expect(loader.calls[9].path, '');

      expect(text, processedMainFile);
    });
  });
}

final mainFile = '''
ASAP2_VERSION 1 61
A2ML_VERSION 1 60

/begin PROJECT DH.XCP.SIMPLE
"text"

/include file1.a2l
/include "other dir/file2.a2l"
/include "other dir/file3.a2l"

/end PROJECT
''';

final file1 = '''
/begin MODULE
/include "other dir/file4.a2l"
/end MODULE
''';

final file2 = '''
/begin CHARACTERISTIC file2
some random text
/end CHARACTERISTIC
''';

final file3 = '''
/begin CHARACTERISTIC file3
some random text
/end CHARACTERISTIC
''';

final file4 = '''
/include "file5.a2l"
''';

final file5 = '''
/begin CHARACTERISTIC file5
some random text
/end CHARACTERISTIC
''';

final processedFile1 = '/begin MODULE\n'
    '/begin CHARACTERISTIC file5\n'
    'some random text\n'
    '/end CHARACTERISTIC\n'
    '\n'
    '/end MODULE\n';

final processedMainFile = 'ASAP2_VERSION 1 61\n'
    'A2ML_VERSION 1 60\n'
    '\n'
    '/begin PROJECT DH.XCP.SIMPLE\n'
    '"text"\n'
    '\n'
    '/begin MODULE\n'
    '/begin CHARACTERISTIC file5\n'
    'some random text\n'
    '/end CHARACTERISTIC\n'
    '\n'
    '/end MODULE\n'
    '\n'
    '/begin CHARACTERISTIC file2\n'
    'some random text\n'
    '/end CHARACTERISTIC\n'
    '\n'
    '/begin CHARACTERISTIC file3\n'
    'some random text\n'
    '/end CHARACTERISTIC\n'
    '\n'
    '/end PROJECT\n';
