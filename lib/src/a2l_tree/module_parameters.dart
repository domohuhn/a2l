import 'package:a2l/src/a2l_tree/calibration_method.dart';
import 'package:a2l/src/a2l_tree/memory_layout.dart';
import 'package:a2l/src/a2l_tree/memory_segment.dart';
import 'package:a2l/src/utility.dart';

/// A constant to be used in the system
class SystemConstant {
  String name = '';

  /// value, must either be a number or furmula part
  String value = '';
}

/// Common parameters for the module.
class ModuleParameters {
  // mandatory
  /// Description for the module parameters
  String description = '';

  // optional
  /// version of the module
  String? version;

  /// CPU on the control unit.
  String? cpuType;

  /// Customer receiving the a2l file
  String? customer;

  /// Customer number
  String? customerNumber;

  /// phone number of the responsible person for the a2l
  String? phoneNumber;

  /// Supplier creating the a2l file
  String? supplier;

  /// the user creating the file
  String? user;

  /// Name of the control unit
  String? controlUnit;

  /// offset to be added to all calibration values
  int? calibrationOffset;

  /// Number of supported interfaces
  int? numberOfInterfaces;

  String? epromIdentifier;
  List<int> eepromIdentifiers;

  /// Constants that are used in formulas
  List<SystemConstant> systemConstants;

  /// Lists the implemented calibration methods
  List<CalibrationMethod> calibrationMethods;

  /// Memory segment description (deprecated)
  List<MemoryLayout> memoryLayouts;

  /// Memory segment description
  List<MemorySegment> memorySegments;

  ModuleParameters()
      : eepromIdentifiers = [],
        systemConstants = [],
        calibrationMethods = [],
        memoryLayouts = [],
        memorySegments = [];

  /// Converts the object to an a2l file.
  String toFileContents(int depth) {
    var rv = indent('/begin MOD_PAR', depth);
    rv += indent('"$description"', depth + 1);
    if (cpuType != null) {
      rv += indent('CPU_TYPE "$cpuType"', depth + 1);
    }
    if (customer != null) {
      rv += indent('CUSTOMER "$customer"', depth + 1);
    }
    if (customerNumber != null) {
      rv += indent('CUSTOMER_NO "$customerNumber"', depth + 1);
    }
    if (controlUnit != null) {
      rv += indent('ECU "$controlUnit"', depth + 1);
    }
    if (calibrationOffset != null) {
      rv += indent('ECU_CALIBRATION_OFFSET 0x${calibrationOffset!.toRadixString(16)}', depth + 1);
    }
    if (epromIdentifier != null) {
      rv += indent('EPK "$epromIdentifier"', depth + 1);
    }
    if (numberOfInterfaces != null) {
      rv += indent('NO_OF_INTERFACES $numberOfInterfaces', depth + 1);
    }
    if (phoneNumber != null) {
      rv += indent('PHONE_NO "$phoneNumber"', depth + 1);
    }
    if (supplier != null) {
      rv += indent('SUPPLIER "$supplier"', depth + 1);
    }
    if (user != null) {
      rv += indent('USER "$user"', depth + 1);
    }
    for (final s in systemConstants) {
      rv += indent('SYSTEM_CONSTANT "${s.name}" "${s.value}"', depth + 1);
    }
    if (version != null) {
      rv += indent('VERSION "$version"', depth + 1);
    }
    for (final m in calibrationMethods) {
      rv += m.toFileContents(depth + 1);
    }
    for (final m in memoryLayouts) {
      rv += m.toFileContents(depth + 1);
    }
    for (final m in memorySegments) {
      rv += m.toFileContents(depth + 1);
    }
    rv += indent('/end MOD_PAR\n\n', depth);
    return rv;
  }
}
