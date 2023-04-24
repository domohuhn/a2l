// SPDX-License-Identifier: BSD-3-Clause
// See LICENSE for the full text of the license

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

  /// Validates the file.
  /// Checks that all referenced axis, compute methods, measurments etc exist.
  /// Also verifies that required invariants of elements hold true.
  ///
  /// Returns a list of found problems. If the list is empty, everything is ok.
  List<Problem> validate() {
    List<Problem> problems = [];
    problems.addAll(_validateProject());
    if (project.modules.isEmpty) {
      return problems;
    }
    problems.addAll(_validateCharacteristics());
    problems.addAll(_validateMeasurements());
    problems.addAll(_validateGroups());
    problems.addAll(_validateFunctions());
    problems.addAll(_validateComputeMethods());
    problems.addAll(_validateAxisPts());
    return problems;
  }

  List<Problem> _validateProject() {
    if (project.modules.isEmpty) {
      return [Problem(project, 'Every project must have at least one module!')];
    }
    return [];
  }

  /// Verifies that all compute methods, record layouts,
  /// axis descriptions, comparision quantities,
  /// (virtual) dependent characteristics and memory segments exist
  /// and that the identifiers are unique.
  List<Problem> _validateCharacteristics() {
    List<Problem> problems = [];
    for (final module in project.modules) {
      for (final characteristic in module.characteristics) {
        if (count(module.characteristics, characteristic.name) > 1 ||
            count(module.axisPoints, characteristic.name) > 1 ||
            count(module.measurements, characteristic.name) > 1) {
          problems.add(Problem(characteristic,
              'Identifiers of characteristics must be unique within a module!'));
        }
        if (characteristic.computeMethod != 'NO_COMPU_METHOD' &&
            module.findComputeMethod(characteristic.computeMethod) == null) {
          problems.add(Problem(characteristic,
              'The referenced compute method "${characteristic.computeMethod}" does not exist!'));
        }
        if (characteristic.comparisionQuantity != null &&
            module.findMeasurement(characteristic.comparisionQuantity!) ==
                null) {
          problems.add(Problem(characteristic,
              'The referenced comparison quantity "${characteristic.comparisionQuantity}" does not exist!'));
        }
        if (characteristic.dependentCharacteristics != null) {
          for (final dep
              in characteristic.dependentCharacteristics!.characteristics) {
            if (module.findCharacteristic(dep) == null) {
              problems.add(Problem(characteristic,
                  'The referenced dependent characteristic "$dep" does not exist!'));
            }
          }
        }
        if (characteristic.virtualCharacteristics != null) {
          for (final dep
              in characteristic.virtualCharacteristics!.characteristics) {
            if (module.findCharacteristic(dep) == null) {
              problems.add(Problem(characteristic,
                  'The referenced characteristic "$dep" does not exist!'));
            }
          }
        }
        for (final func in characteristic.functions) {
          if (module.findFunction(func) == null) {
            problems.add(Problem(characteristic,
                'The referenced function "$func" does not exist!'));
          }
        }
        if (characteristic.memorySegment != null &&
            module.findMemorySegment(characteristic.memorySegment!) == null) {
          problems.add(Problem(characteristic,
              'The referenced memory segement "${characteristic.memorySegment}" does not exist!'));
        }
        final dimension = characteristic.validateDimensions();
        if (dimension != null) {
          problems.add(Problem(characteristic, dimension));
        }
      }
    }
    return problems;
  }

  List<Problem> _validateGroups() {
    List<Problem> problems = [];
    for (final module in project.modules) {
      for (final group in module.groups) {
        for (final char in group.characteristics) {
          if (module.findCharacteristic(char) == null) {
            problems.add(Problem(group,
                'The referenced characteristic "$char" does not exist!'));
          }
        }
        for (final m in group.measurements) {
          if (module.findMeasurement(m) == null) {
            problems.add(Problem(
                group, 'The referenced measurement "$m" does not exist!'));
          }
        }
        for (final f in group.functions) {
          if (module.findFunction(f) == null) {
            problems.add(
                Problem(group, 'The referenced function "$f" does not exist!'));
          }
        }
        for (final g in group.groups) {
          if (module.findGroup(g) == null) {
            problems.add(
                Problem(group, 'The referenced group "$g" does not exist!'));
          }
        }
      }
    }
    return problems;
  }

  List<Problem> _validateFunctions() {
    List<Problem> problems = [];
    for (final module in project.modules) {
      for (final f in module.functions) {
        if (count(module.functions, f.name) > 1) {
          problems.add(Problem(
              f, 'Identifiers of objects must be unique within a module!'));
        }
        for (final c in f.characteristics) {
          if (module.findCharacteristic(c) == null) {
            problems.add(Problem(
                f, 'The referenced characteristic "$c" does not exist!'));
          }
        }
        for (final c in f.definedCharacteristics) {
          if (module.findCharacteristic(c) == null) {
            problems.add(Problem(
                f, 'The referenced characteristic "$c" does not exist!'));
          }
        }
        for (final m in f.inputMeasurements) {
          if (module.findMeasurement(m) == null) {
            problems.add(
                Problem(f, 'The referenced measurement "$m" does not exist!'));
          }
        }
        for (final m in f.measurements) {
          if (module.findMeasurement(m) == null) {
            problems.add(
                Problem(f, 'The referenced measurement "$m" does not exist!'));
          }
        }
        for (final m in f.outputMeasurements) {
          if (module.findMeasurement(m) == null) {
            problems.add(
                Problem(f, 'The referenced measurement "$m" does not exist!'));
          }
        }
        for (final sub in f.functions) {
          if (module.findFunction(sub) == null) {
            problems.add(
                Problem(f, 'The referenced function "$sub" does not exist!'));
          }
        }
      }
    }
    return problems;
  }

  List<Problem> _validateAxisPts() {
    List<Problem> problems = [];
    for (final module in project.modules) {
      for (final ap in module.axisPoints) {
        if (count(module.characteristics, ap.name) > 1 ||
            count(module.axisPoints, ap.name) > 1 ||
            count(module.measurements, ap.name) > 1) {
          problems.add(Problem(ap,
              'Identifiers of objects must be unique within a module! "${ap.name}" is duplicated!'));
        }
        if (ap.computeMethod != 'NO_COMPU_METHOD' &&
            module.findComputeMethod(ap.computeMethod) == null) {
          problems.add(Problem(ap,
              'The referenced compute method "${ap.computeMethod}" does not exist!'));
        }
        for (final func in ap.functions) {
          if (module.findFunction(func) == null) {
            problems.add(
                Problem(ap, 'The referenced function "$func" does not exist!'));
          }
        }
        if (ap.memorySegment != null &&
            module.findMemorySegment(ap.memorySegment!) == null) {
          problems.add(Problem(ap,
              'The referenced memory segment "${ap.memorySegment}" does not exist!'));
        }
        if (module.findMeasurement(ap.inputQuantity) == null) {
          problems.add(Problem(ap,
              'The referenced input quantity "${ap.inputQuantity}" does not exist!'));
        }
      }
    }
    return problems;
  }

  List<Problem> _validateMeasurements() {
    List<Problem> problems = [];
    for (final module in project.modules) {
      for (final m in module.measurements) {
        if (count(module.characteristics, m.name) > 1 ||
            count(module.axisPoints, m.name) > 1 ||
            count(module.measurements, m.name) > 1) {
          problems.add(Problem(
              m, 'Identifiers of objects must be unique within a module!'));
        }
        if (m.computeMethod != 'NO_COMPU_METHOD' &&
            module.findComputeMethod(m.computeMethod) == null) {
          problems.add(Problem(m,
              'The referenced compute method "${m.computeMethod}" does not exist!'));
        }
        for (final func in m.functions) {
          if (module.findFunction(func) == null) {
            problems.add(
                Problem(m, 'The referenced function "$func" does not exist!'));
          }
        }
        if (m.memorySegment != null &&
            module.findMemorySegment(m.memorySegment!) == null) {
          problems.add(Problem(m,
              'The referenced memory segement "${m.memorySegment}" does not exist!'));
        }
        final dim = m.validateMatrixDimensions();
        if (dim != null) {
          problems.add(Problem(m, dim));
        }
      }
    }
    return problems;
  }

  List<Problem> _validateComputeMethods() {
    List<Problem> problems = [];
    for (final module in project.modules) {
      for (final cm in module.computeMethods) {
        if (count(module.computeMethods, cm.name) > 1) {
          problems.add(Problem(cm,
              'Identifiers of compute methods must be unique within a module! ${cm.name} is duplicated!'));
        }
        if (cm.referencedTable != null &&
            module.findTable(cm.referencedTable!) == null) {
          problems.add(Problem(cm,
              'The referenced table "${cm.referencedTable}" does not exist!'));
        }
        if (cm.referencedUnit != null &&
            module.findUnit(cm.referencedUnit!) == null) {
          problems.add(Problem(cm,
              'The referenced unit "${cm.referencedUnit}" does not exist!'));
        }
      }
    }
    return problems;
  }
}

class Problem {
  dynamic source;
  String problem;

  Problem(this.source, this.problem);

  @override
  String toString() {
    return "Error in a2l: '$problem' in\n\n${source.toFileContents(0)}";
  }
}

int count(List<dynamic> data, String key) {
  int count = 0;
  for (final val in data) {
    if (val.name == key) {
      count += 1;
    }
  }
  return count;
}
