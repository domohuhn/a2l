

import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';


/// Describes the type of a unit
enum UnitType {
  /// It is a derived unit
  DERIVED,
  /// It is a base unit
  EXTENDED_SI
}

/// Converts [s] to the unit type enum.
UnitType unitTypeFromString(Token s) {
  switch(s.text) {
    case 'DERIVED': return UnitType.DERIVED;
    case 'EXTENDED_SI': return UnitType.EXTENDED_SI;
    default: throw ParsingException('Unkown unit type', s);
  }
}

/// Converts [t] to the string in the a2l file.
String unitTypeToFileContents(UnitType t) {
  switch(t) {
    case UnitType.DERIVED: return 'DERIVED';
    case UnitType.EXTENDED_SI: return 'EXTENDED_SI';
  }
}

/// Representation of the SI exponents of the units.
class SIExponents {
  /// Unit exponent
  int length = 0;
  /// Unit exponent
  int mass = 0;
  /// Unit exponent
  int time = 0;
  /// Unit exponent
  int electricCurrent = 0;
  /// Unit exponent
  int temperature = 0;
  /// Unit exponent
  int amountOfSubstance = 0;
  /// Unit exponent
  int luminousIntensity = 0;

  /// Converts the object to an a2l file entry.
  /// The token is indented up to [depth]
  String toFileContents(int depth) {
    var rv = 'SI_EXPONENTS $length $mass $time $electricCurrent $temperature $amountOfSubstance $luminousIntensity\n';
    return indent(rv,depth);
  }
}

/// Code representation of a physical unit.
class Unit {
  /// Name of the object. Cannot be empty and must be unique in the file.
  String name = '';
  /// Description of the unit
  String description = '';
  /// Display string for the unit
  String display = '';
  /// Type of the unit
  UnitType type = UnitType.EXTENDED_SI;

  // optional
  /// Reference to another unit
  String? referencedUnit;
  /// Si exponents of the unit
  SIExponents? exponents;
  /// Conversion function from the referenced unit: slope*other + offset
  double? conversionLinear_slope;
  /// Conversion function from the referenced unit: slope*other + offset
  double? conversionLinear_offset;

  /// Checks if this object has all mandatory values set and no illegal combination of optional values.
  bool isValid() {
    var rv = name.isNotEmpty && !name.contains(' ');
    if(referencedUnit!=null) {
      rv = rv && referencedUnit!.isNotEmpty && !referencedUnit!.contains(' ');
    }
    var conv = (conversionLinear_slope==null && conversionLinear_offset==null ) || (conversionLinear_slope!=null && conversionLinear_offset!=null );
    return rv && conv;
  }

  /// Converts the object to an a2l file entry.
  /// The token is indented up to [depth]
  String toFileContents(int depth) {
    var rv = indent('/begin UNIT $name\n',depth);
    rv += indent('"$description"\n',depth+1);
    rv += indent('"$display" ${unitTypeToFileContents(type)}\n',depth+1);
    if(referencedUnit != null && referencedUnit!.isNotEmpty) {
      rv += indent('REF_UNIT $referencedUnit\n', depth+1);
    }
    if(exponents != null) {
      rv += exponents!.toFileContents(depth+1);
    }
    if(conversionLinear_slope != null && conversionLinear_offset != null) {
      rv += indent('UNIT_CONVERSION $conversionLinear_slope $conversionLinear_offset\n', depth+1);
    }
    
    rv += indent('/end UNIT\n\n',depth);
    return rv;
  }
}
