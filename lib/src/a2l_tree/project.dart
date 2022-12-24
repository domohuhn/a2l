// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

import 'package:a2l/src/a2l_tree/module.dart';
import 'package:a2l/src/utility.dart';

/// Representation of a Calibration project from the A2L file.
/// Corresponds to a2l key PROJECT
class Project {
  /// Name of the Project. Mandatory.
  String name = '';

  /// Description of the Project. Mandatory.
  String description = '';

  // optional values
  /// The HEADER element with additional information.
  Header? header;

  /// The list of modules. Each valid Project must have at least one module!
  List<Module> modules;

  /// Constructor.
  Project() : modules = [];

  /// Creates a simple string representation of the project.
  @override
  String toString() {
    var rv = 'Project "$name"\n$description\n\n';
    if (header != null) {
      rv += 'Comment: "${header!.description}"\n';
    }
    if (header != null && header!.hasVersion) {
      rv += 'Version: "${header!.version}"\n';
    }
    if (header != null && header!.hasNumber) {
      rv += 'Number: "${header!.number}"\n';
    }
    rv += 'Modules: "${modules.length}"\n\n';

    for (final mod in modules) {
      rv += '$mod\n';
    }
    return rv;
  }

  /// Converts the project to an a2l file.
  String toFileContents() {
    var rv = '/begin PROJECT $name\n  "$description"\n\n';
    if (header != null) {
      rv += header!.toFileContents(1);
    }
    for (final m in modules) {
      rv += m.toFileContents(1);
    }
    rv += '/end PROJECT\n\n';
    return rv;
  }
}

/// Represents the project header structure.
class Header {
  /// Description of the Header/Project.
  String description = '';

  // optional
  /// Version read from the HEADER element.
  String? version;

  /// Project number from the HEADER element.
  String? number;

  bool get hasVersion => version != null;
  bool get hasNumber =>
      number != null && number!.isNotEmpty && !number!.contains(' ');

  /// Converts the object to an a2l file.
  String toFileContents(int depth) {
    var rv = indent('/begin HEADER\n', depth);
    rv += indent('"$description"\n', depth + 1);
    if (hasVersion) {
      rv += indent('VERSION "$version"', depth + 1);
    }
    if (hasNumber) {
      rv += indent('PROJECT_NO $number', depth + 1);
    }
    rv += indent('/end HEADER\n\n', depth);
    return rv;
  }
}
