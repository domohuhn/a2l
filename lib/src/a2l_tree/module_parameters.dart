
import 'package:a2l/src/a2l_tree/base_types.dart';

/// A constant to be used in the system
class SystemConstant {
  String name = '';
  /// value, must either be a number or furmula part
  String value = '';
}

/// Common parameters for the module.
class ModuleParameters {
  // mandatory
  String description = '';

  // optional
  String? version;
  String? cpuType;
  String? customer;
  String? customerNumber;
  /// phone number of the responsible person for the a2l
  String? phoneNumber;
  String? supplier;
  String? user;
  String? controlUnit;
  /// offset to ba added to alle calibration values
  int? calibrationOffset;
  int? numberOfInterfaces;

  String? epromIdentifier;
  List<int> eepromIdentifiers;
  List<SystemConstant> systemConstants;

  // TODO CALIBRATION_METHOD
  // TODO Memory layout
  // TODO memory segment


  ModuleParameters() : eepromIdentifiers = [], systemConstants=[];
}
