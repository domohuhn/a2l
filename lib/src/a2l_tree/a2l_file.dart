import 'package:a2l/src/a2l_tree/project.dart';
import 'package:a2l/src/version.dart';

/// The representation of an A2L file as data structure in code.
/// A file must contain an ASAP2 version and a single Project.
class A2LFile {
  /// Major ASAP2 version. Required. The code supports only version 1.60.
  int a2lMajorVersion = 1;

  /// Minor ASAP2 version. Required. The code supports only version 1.60.
  int a2lMinorVersion = 60;

  /// Major A2ML version. Optional.
  int? a2mlMajorVersion;

  /// Minor A2ML version. Optional.
  int? a2mlMinorVersion;

  /// The project element inside the file.
  Project project = Project();

  /// Gets a simple string representation of the a2l file.
  @override
  String toString() {
    var rv = 'A2L File\nVersion: $a2lMajorVersion.$a2lMinorVersion\n';
    if (a2mlMajorVersion != null && a2mlMinorVersion != null) {
      rv += 'A2ML Version: $a2mlMajorVersion.$a2mlMinorVersion\n';
    }
    rv += '\n$project';
    return rv;
  }

  /// Converts the data structure to valid a2l file.
  String toFileContents() {
    var rv = '/* This a2l file was generated with the dart a2l package */\n';
    rv += '/* Version $libraryVersion */\n\n';
    rv += 'ASAP2_VERSION $a2lMajorVersion $a2lMinorVersion\n';
    if (a2mlMajorVersion != null && a2mlMinorVersion != null) {
      rv += 'A2ML_VERSION $a2mlMajorVersion $a2mlMinorVersion\n';
    }
    rv += '\n';
    rv += project.toFileContents();
    return rv;
  }
}
