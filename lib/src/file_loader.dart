
import 'dart:io';
import 'package:path/path.dart' as p;


/// Provides an interface to inject a FileLoader.
/// This allows us to test the library.
class FileLoader {
  final List<String> _files;
  final List<String> _basePaths;

  String last;

  FileLoader() : _files = [], _basePaths=[], last = '';

  /// Loads a file contained in path and returns its contents.
  /// Should throw an exception on error.
  /// If a relative path is given, it will be loaded relative to the last file. 
  String read(String path) {
    last = path.trim();
    if(p.isAbsolute(path)) {
      _basePaths.add(p.dirname(path.trim()));
      return _readFile(path);
    }
    else {
      var prepended = path.trim();
      if(_basePaths.isNotEmpty && _basePaths.last != '.') {
        prepended = _basePaths.last + '/' + prepended;
        _basePaths.add(p.dirname(prepended));
      } else {
        _basePaths.add(p.dirname(prepended));
      }
      return _readFile(prepended);
    }
  }

  String _readFile(String path) {
    final text = File(path.trim()).readAsStringSync();
    _files.add(p.canonicalize(path.trim()));
    return text;
  }

  /// Returns the stack of loaded files.
  String stack() {
    var rv = 'In file "${_files.last}"\n';
    for(int i = _files.length-1; i > 0; i--) {
      rv += '    included from "${_files[i-1]}"\n';
    }
    return rv;
  }

  /// pops a file from the stack.
  void pop() {
    _files.removeLast();
    _basePaths.removeLast();
  }

  /// Max recursion depth
  int maxRecursion = 5;
}
