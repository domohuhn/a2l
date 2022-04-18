
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

  /// Converts the object to an a2l file.
  String toFileContents(int depth) {
    var rv = indent('/begin MOD_PAR', depth);
    rv += indent('"$description"', depth+1);
    if (cpuType!=null) {
      rv += indent('CPU_TYPE "$cpuType"', depth+1);
    }
    if (customer!=null) {
      rv += indent('CUSTOMER "$customer"', depth+1);
    }
    if (customerNumber!=null) {
      rv += indent('CUSTOMER_NO "$customerNumber"', depth+1);
    }
    if (controlUnit!=null) {
      rv += indent('ECU "$controlUnit"', depth+1);
    }
    if (calibrationOffset!=null) {
      rv += indent('ECU_CALIBRATION_OFFSET 0x${calibrationOffset!.toRadixString(16)}', depth+1);
    }
    if (epromIdentifier!=null) {
      rv += indent('EPK "$epromIdentifier"', depth+1);
    }
    if (numberOfInterfaces!=null) {
      rv += indent('NO_OF_INTERFACES $numberOfInterfaces', depth+1);
    }
    if (phoneNumber!=null) {
      rv += indent('PHONE_NO "$phoneNumber"', depth+1);
    }
    if (supplier!=null) {
      rv += indent('SUPPLIER "$supplier"', depth+1);
    }
    if (user!=null) {
      rv += indent('USER "$user"', depth+1);
    }
    for(final s in systemConstants) {
      rv += indent('SYSTEM_CONSTANT "${s.name}" "${s.value}"', depth+1);
    }
    if (version!=null) {
      rv += indent('VERSION "$version"', depth+1);
    }
    rv += indent('/end MOD_PAR\n\n', depth);
    return rv;
  }
}
