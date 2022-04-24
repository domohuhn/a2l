
import 'package:a2l/src/a2l_tree/memory_layout.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Describes the segment types.
enum SegmentType
{
  /// Values in the ECU that are not changed during calibration
  CALIBRATION_VARIABLES,
  /// Program code
  CODE,
  /// data used in the online calibration
  DATA,
  /// values in the ecu not in binary files for flashing
  EXCLUDE_FROM_FLASH,
  /// data the is not allowed to be changed by online claibration
  OFFLINE_DATA,
  /// reserved
  RESERVED,
  /// serial emulation data
  SERAM,
  // variables
  VARIABLES
}

/// Converts the token [t] to the corresponding enum or throws an exception.
SegmentType segmentTypeFromString(Token t) {
  switch(t.text) {
    case 'CALIBRATION_VARIABLES'    : return SegmentType.CALIBRATION_VARIABLES;
    case 'CODE'                     : return SegmentType.CODE              ;
    case 'DATA'                     : return SegmentType.DATA              ;
    case 'EXCLUDE_FROM_FLASH'       : return SegmentType.EXCLUDE_FROM_FLASH;
    case 'OFFLINE_DATA'             : return SegmentType.OFFLINE_DATA      ;
    case 'RESERVED'                 : return SegmentType.RESERVED          ;
    case 'SERAM'                    : return SegmentType.SERAM             ;
    case 'VARIABLES'                : return SegmentType.VARIABLES         ;
    default: throw ParsingException('Unknown program type', t);
  }
}

/// Converts the enum [e] to the corresponding a2l element or throws an exception.
String segmentTypeToString(SegmentType e) {
  switch(e) {
    case SegmentType.CALIBRATION_VARIABLES: return 'CALIBRATION_VARIABLES'    ;
    case SegmentType.CODE                 : return 'CODE'                     ;
    case SegmentType.DATA                 : return 'DATA'                     ;
    case SegmentType.EXCLUDE_FROM_FLASH   : return 'EXCLUDE_FROM_FLASH'       ;
    case SegmentType.OFFLINE_DATA         : return 'OFFLINE_DATA'             ;
    case SegmentType.RESERVED             : return 'RESERVED'                 ;
    case SegmentType.SERAM                : return 'SERAM'                    ;
    case SegmentType.VARIABLES            : return 'VARIABLES'                ;
    default: throw ValidationError('Unknown program type $e');
  }
}

/// Describes the hardware type of the memory segment.
enum MemoryType {
  EEPROM,
  EPROM,
  FLASH,
  RAM,
  ROM,
  REGISTER
}


/// Converts the token [t] to the corresponding enum or throws an exception.
MemoryType memoryTypeFromString(Token t) {
  switch(t.text) {
    case 'EEPROM'  : return MemoryType.EEPROM  ;
    case 'EPROM'   : return MemoryType.EPROM   ;
    case 'FLASH'   : return MemoryType.FLASH   ;
    case 'RAM'     : return MemoryType.RAM     ;
    case 'ROM'     : return MemoryType.ROM     ;
    case 'REGISTER': return MemoryType.REGISTER;
    default: throw ParsingException('Unknown memory type', t);
  }
}

/// Converts the enum [e] to the corresponding a2l element or throws an exception.
String memoryTypeToString(MemoryType e) {
  switch(e) {
    case MemoryType.EEPROM  : return 'EEPROM'  ;
    case MemoryType.EPROM   : return 'EPROM'   ;
    case MemoryType.FLASH   : return 'FLASH'   ;
    case MemoryType.RAM     : return 'RAM'     ;
    case MemoryType.ROM     : return 'ROM'     ;
    case MemoryType.REGISTER: return 'REGISTER';
    default: throw ValidationError('Unknown memory type $e');
  }
}

/// Attributes of the segment.
enum SegmentAttribute {
  /// internal memory segment
  INTERN,
  /// external memory segment
  EXTERN
}


/// Converts the token [t] to the corresponding enum or throws an exception.
SegmentAttribute segmentAttributeFromString(Token t) {
  switch(t.text) {
    case 'INTERN'  : return SegmentAttribute.INTERN  ;
    case 'EXTERN'   : return SegmentAttribute.EXTERN   ;
    default: throw ParsingException('Unknown SegmentAttribute', t);
  }
}

/// Converts the enum [e] to the corresponding a2l element or throws an exception.
String segmentAttributeToString(SegmentAttribute e) {
  switch(e) {
    case SegmentAttribute.INTERN: return 'INTERN';
    case SegmentAttribute.EXTERN: return 'EXTERN';
    default: throw ValidationError('Unknown SegmentAttribute type $e');
  }
}

/// This object describes a memory segment. It should be used in instead of memory layout.
/// This structure has a name and can therefore be referenced in other types of the file.
/// Additionally, it provides more detailed fields to describe the layout (e.g. isExtern)
/// 
/// | Combination                    | Description                                    |
/// |-------------                   |:----------------------------------------------:|
/// | CODE/FLASH                     |   Executable code which has to be preserved    |
/// | DATA/FLASH or DATA/EEPROM      |   Calibration data for online modification     |
/// | RESERVED/FLASH                 | ECU specific code not for download             |
/// | DATA/RAM                       | data to be modified                            |
/// | OFFLINE_DATA/FLASH             | offline data                                   |
/// | VARIABLES/RAM                  | Variables stored in RAM                        |
/// | REGISTER/RAM                   | Variables stored in RAM                        |
/// | SERAM/RAM                      | serial calibration. See [CalibrationMethod]    |
class MemorySegment extends SegmentData {
  /// Name of the segment.
  String name = '';
  /// Description of the segment.
  String description = '';
  /// Type of the segment.
  SegmentType type = SegmentType.DATA;
  /// Hardware where the segment is located.
  MemoryType memoryType = MemoryType.FLASH;
  /// Attribues of the segment.
  SegmentAttribute attribute = SegmentAttribute.INTERN;

  /// Converts the object to a part of an a2l file with indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin MEMORY_SEGMENT $name', depth);
    rv += indent('"$description"', depth+1);
    rv += indent('${segmentTypeToString(type)} ${memoryTypeToString(memoryType)} ${segmentAttributeToString(attribute)}', depth+1);
    rv += sharedDataToFileContents(depth+1);
    rv += indent('/end MEMORY_SEGMENT\n\n', depth);
    return rv;
  }
}
