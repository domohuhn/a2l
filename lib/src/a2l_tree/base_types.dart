
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// This is a base container for various other a2l elements that hold the same data.
class DataContainer extends AnnotationContainer {
  String name='';
  String description='';
  List<String> functions;
  List<String> characteristics;
  List<String> measurements;
  List<String> groups;

  DataContainer() : 
    functions = [],
    characteristics = [],
    measurements = [],
    groups = []
  ;
}

/// Fixed width data types
enum Datatype {
  uint8,
  uint16,
  uint32,
  uint64,
  int8,
  int16,
  int32,
  int64,
  float32,
  float64
}

/// Converts the token [s] to the enum.
Datatype dataTypeFromString(Token s) {
  switch(s.text) {
    case 'UBYTE': return Datatype.uint8;
    case 'SBYTE': return Datatype.int8;
    case 'UWORD': return Datatype.uint16;
    case 'SWORD': return Datatype.int16;
    case 'ULONG': return Datatype.uint32;
    case 'SLONG': return Datatype.int32;
    case 'A_UINT64': return Datatype.uint64;
    case 'A_INT64': return Datatype.int64;
    case 'FLOAT32_IEEE': return Datatype.float32;
    case 'FLOAT64_IEEE': return Datatype.float64;
    default: throw ParsingException('Unknown data type', s);
  }
}

/// Converts the enum to an a2l string.
String dataTypeToString(Datatype s) {
  switch(s) {
    case Datatype.uint8  : return 'UBYTE'       ;
    case Datatype.int8   : return 'SBYTE'       ;
    case Datatype.uint16 : return 'UWORD'       ;
    case Datatype.int16  : return 'SWORD'       ;
    case Datatype.uint32 : return 'ULONG'       ;
    case Datatype.int32  : return 'SLONG'       ;
    case Datatype.uint64 : return 'A_UINT64'    ;
    case Datatype.int64  : return 'A_INT64'     ;
    case Datatype.float32: return 'FLOAT32_IEEE';
    case Datatype.float64: return 'FLOAT64_IEEE';
    default: throw ValidationError('Unknown data type');
  }
}

/// Represents how data is stored on the ECU.
enum ByteOrder {
  MSB_LAST,
  MSB_FIRST
}

/// Converts token [s] to the enum or throws an exception.
ByteOrder byteOrderFromString(Token s) {
  switch(s.text) {
    case 'MSB_LAST': return ByteOrder.MSB_LAST;
    case 'MSB_FIRST': return ByteOrder.MSB_FIRST;
    // wtf? ASAP2 standard is wrong? Standard even mentions that it uses different names to normal, therefore MSB_LAST was introduced
    case 'BIG_ENDIAN': return ByteOrder.MSB_LAST; 
    // wtf? ASAP2 standard is wrong? Standard even mentions that it uses different names to normal, therefore MSB_FIRST was introduced
    case 'LITTLE_ENDIAN': return ByteOrder.MSB_FIRST;
    default: throw ParsingException('Unknown byte order', s);
  }
}

/// Converts [b] to the an a2l string.
String byteOrderToString(ByteOrder b) {
  switch(b) {
    case ByteOrder.MSB_LAST: return 'MSB_LAST';
    case ByteOrder.MSB_FIRST: return 'MSB_FIRST';
    default: throw ValidationError('Unknown byte order');
  }
}

/// Describes how arrays are indexed.
enum IndexMode {
  ALTERNATE_CURVES,
  ALTERNATE_WITH_X,
  ALTERNATE_WITH_Y,
  COLUMN_DIR,
  ROW_DIR
}

/// Converts the token [s] to the enum
IndexMode indexModeFromString(Token s) {
  switch(s.text) {
    case 'ALTERNATE_CURVES': return IndexMode.ALTERNATE_CURVES;
    case 'ALTERNATE_WITH_X': return IndexMode.ALTERNATE_WITH_X;
    case 'ALTERNATE_WITH_Y': return IndexMode.ALTERNATE_WITH_Y;
    case 'COLUMN_DIR': return IndexMode.COLUMN_DIR;
    case 'ROW_DIR': return IndexMode.ROW_DIR;
    default: throw ParsingException('Unknown index mode', s);
  }
}

/// Converts the enum [s] to the a2l string.
String indexModeToString(IndexMode s) {
  switch(s) {
    case IndexMode.ALTERNATE_CURVES: return 'ALTERNATE_CURVES';
    case IndexMode.ALTERNATE_WITH_X: return 'ALTERNATE_WITH_X';
    case IndexMode.ALTERNATE_WITH_Y: return 'ALTERNATE_WITH_Y';
    case IndexMode.COLUMN_DIR      : return 'COLUMN_DIR'      ;
    case IndexMode.ROW_DIR         : return 'ROW_DIR'         ;
    default: throw ValidationError('Unknown index mode');
  }
}

/// Describes a bit shift operation from the a2l file.
class BitOperation {
  /// amount of bits for a left shift
  int? leftShift;
  /// amount of bits for a right shift
  int? rightShift;
  /// if set to to true, then the most significant bit will be extended to all higher value bits after the right shift.
  bool signExtend=false;

  /// Converts this object to its a2l representation.
  String toFileContents(int depth){
    var rv = indent('/begin BIT_OPERATION', depth);
    if(leftShift!=null) {
      rv += indent('LEFT_SHIFT $leftShift', depth);
    }
    if(rightShift!=null) {
      rv += indent('RIGHT_SHIFT $rightShift', depth);
    }
    if(signExtend) {
      rv += indent('SIGN_EXTEND', depth);
    }
    rv += indent('/end BIT_OPERATION', depth);
    return rv;
  }
}

/// Describes a link to a symbol in the object file parsed from the a2l file.
class SymbolLink {
  /// the symbol name in the object file
  String name='';
  /// offset in the object file
  int offset=0;
  
  /// Converts this object to a2l entry with indentation [depth].
  String toFileContents(int depth){
    return indent('SYMBOL_LINK "$name" $offset', depth);
  }
}

enum MaxRefreshUnit {
  time_1usec,
  time_10usec,
  time_100usec,
  time_1msec,
  time_10msec,
  time_100msec,
  time_1sec,
  time_10sec,
  time_1min,
  time_1hour,
  time_1day,
  angle_degree,
  angle_revolutions_360_degree,
  angle_cycle_720_degree,
  combustion_cylinder_segment,
  /// source defined in keyword frame
  event_frame, 
  /// complex trigger condition
  event_newvalue, 
  non_deterministic
}

/// Converts the token [s] to the MaxRefreshUnit enum.
MaxRefreshUnit maxRefreshUnitFromString(Token s){
  switch(s.text){
    case '0': return MaxRefreshUnit.time_1usec;
    case '1': return MaxRefreshUnit.time_10usec;
    case '2': return MaxRefreshUnit.time_100usec;
    case '3': return MaxRefreshUnit.time_1msec;
    case '4': return MaxRefreshUnit.time_10msec;
    case '5': return MaxRefreshUnit.time_100msec;
    case '6': return MaxRefreshUnit.time_1sec;
    case '7': return MaxRefreshUnit.time_10sec;
    case '8': return MaxRefreshUnit.time_1min;
    case '9': return MaxRefreshUnit.time_1hour;
    case '10': return MaxRefreshUnit.time_1day;
    case '100': return MaxRefreshUnit.angle_degree;
    case '101': return MaxRefreshUnit.angle_revolutions_360_degree;
    case '102': return MaxRefreshUnit.angle_cycle_720_degree;
    case '103': return MaxRefreshUnit.combustion_cylinder_segment;
    case '998': return MaxRefreshUnit.event_frame;
    case '999': return MaxRefreshUnit.event_newvalue;
    case '1000': return MaxRefreshUnit.non_deterministic;
    default: throw ParsingException('Unknown ScalingUnit', s);
  }
}

/// Converts the token [s] to the MaxRefreshUnit enum.
String maxRefreshUnitToString(MaxRefreshUnit s){
  switch(s){
    case MaxRefreshUnit.time_1usec                  : return '0'   ;
    case MaxRefreshUnit.time_10usec                 : return '1'   ;
    case MaxRefreshUnit.time_100usec                : return '2'   ;
    case MaxRefreshUnit.time_1msec                  : return '3'   ;
    case MaxRefreshUnit.time_10msec                 : return '4'   ;
    case MaxRefreshUnit.time_100msec                : return '5'   ;
    case MaxRefreshUnit.time_1sec                   : return '6'   ;
    case MaxRefreshUnit.time_10sec                  : return '7'   ;
    case MaxRefreshUnit.time_1min                   : return '8'   ;
    case MaxRefreshUnit.time_1hour                  : return '9'   ;
    case MaxRefreshUnit.time_1day                   : return '10'  ;
    case MaxRefreshUnit.angle_degree                : return '100' ;
    case MaxRefreshUnit.angle_revolutions_360_degree: return '101' ;
    case MaxRefreshUnit.angle_cycle_720_degree      : return '102' ;
    case MaxRefreshUnit.combustion_cylinder_segment : return '103' ;
    case MaxRefreshUnit.event_frame                 : return '998' ;
    case MaxRefreshUnit.event_newvalue              : return '999' ;
    case MaxRefreshUnit.non_deterministic           : return '1000';
    default: throw ValidationError('Unknown ScalingUnit $s');
  }
}

/// Represents the maximum refresh rate of a value as base unit * rate.
class MaxRefresh {
  /// Which base unit to use.
  MaxRefreshUnit scalingUnit=MaxRefreshUnit.non_deterministic;
  /// Multiplier of the base unit.
  int rate=0;

  /// Converts this object to an a2l entry with indentation [depth].
  String toFileContents(int depth){
    return indent('MAX_REFRESH ${maxRefreshUnitToString(scalingUnit)} $rate', depth);
  }

}

/// Describes the matrix size.
class MatrixDim {
  int x=0;
  int y=0;
  int z=0;
  
  /// Converts this object to a2l entry with indentation [depth].
  String toFileContents(int depth){
    return indent('MATRIX_DIM $x $y $z', depth);
  }
}

class MeasurementCharacteristicBase extends DataContainer {
  // mandatory values
  String conversionMethod = '';
  double lowerLimit = 1.0;
  double upperLimit = 1.0;

  // optional values

  int? bitMask;
  ByteOrder? endianess;
  bool discrete = false;
  /// How the value is displayed. Must not be unique.
  String? displayIdentifier;
  /// address extension for XCP packages
  int? addressExtension;
  /// Display format string. overrides compu method.
  String? format;
  MatrixDim? matrixDim;
  MaxRefresh? maxRefresh;
  /// Can be used to override the unit at the conversion method
  String? unit;
  /// if the value is read write (characteristic default = rw, measurement default = ro)
  bool readWrite = false;
  String? memorySegment;
  SymbolLink? symbolLink;

  /// Converts the shared optional values to the a2l file contents.
  /// Entries are indented to [depth].
  /// This includes:
  ///   - BIT_MASK
  ///   - BYTE_ORDER
  ///   - DISCRETE
  ///   - DISPLAY_IDENTIFIER
  ///   - ECU_ADDRESS_EXTENSION
  ///   - FORMAT
  ///   - PHYS_UNIT
  ///   - REF_MEMORY_SEGMENT
  ///   - SYMBOL_LINK
  ///   - MATRIX_DIM
  ///   - MAX_REFRESH
  ///   - FUNCTION_LIST
  String optionalsToFileContents(int depth){
    var rv = '';
    if(bitMask!=null) {
      rv += indent('BIT_MASK 0x${bitMask!.toRadixString(16).padLeft(8,"0")}', depth);
    }
    if(endianess!=null) {
      rv += indent('BYTE_ORDER ${byteOrderToString(endianess!)}', depth);
    }
    if(discrete) {
      rv += indent('DISCRETE', depth);
    }
    if(displayIdentifier!=null) {
      rv += indent('DISPLAY_IDENTIFIER $displayIdentifier', depth);
    }
    if(addressExtension!=null) {
      rv += indent('ECU_ADDRESS_EXTENSION $addressExtension', depth);
    }
    if(format!=null && format!.isNotEmpty) {
      rv += indent('FORMAT "$format"', depth);
    }
    if(unit!=null) {
      rv += indent('PHYS_UNIT "$unit"', depth);
    }
    if(memorySegment!=null) {
      rv += indent('REF_MEMORY_SEGMENT $memorySegment', depth);
    }
    if(symbolLink!=null) {
      rv += symbolLink!.toFileContents(depth);
    }
    if(matrixDim!=null) {
      rv += matrixDim!.toFileContents(depth);
    }
    if(maxRefresh!=null) {
      rv += maxRefresh!.toFileContents(depth);
    }
    if(functions.isNotEmpty) {
      rv += indent('/begin FUNCTION_LIST',depth);
      for(final data in functions) {
        rv += indent('$data',depth+1);
      }
      rv += indent('/end FUNCTION_LIST',depth);
    }

    return rv;
  }
}

/// Describes how data is deposited
enum AddressType {
  /// memory location has 1 byte pointer to value
  PBYTE,
  /// memory location has 2 byte pointer to value
  PWORD,
  /// memory location has 4 byte pointer to value
  PLONG,
  /// memory location holds first value. Others follow by incrementing address.
  DIRECT
}

/// Converts a string to the address type
AddressType addressTypeFromString(Token s){
  switch(s.text) {
    case 'PBYTE': return AddressType.PBYTE;
    case 'PWORD': return AddressType.PWORD;
    case 'PLONG': return AddressType.PLONG;
    case 'DIRECT': return AddressType.DIRECT;
    default: throw ParsingException('Unknown address type $s', s);
  }
}

/// Converts an enum [s] to the address type a2l string
String addressTypeToString(AddressType s){
  switch(s) {
    case AddressType.PBYTE : return 'PBYTE' ;
    case AddressType.PWORD : return 'PWORD' ;
    case AddressType.PLONG : return 'PLONG' ;
    case AddressType.DIRECT: return 'DIRECT';
    default: throw ValidationError('Unknown address type $s');
  }
}

/// Deposite mode for axis
enum Deposit {
  /// absolute value is stored
  ABSOLUTE,
  /// difference to last is stored
  DIFFERENCE
}

/// Converts a string to deposit mode
Deposit depositFromString(Token s){
  switch(s.text) {
    case 'ABSOLUTE': return Deposit.ABSOLUTE;
    case 'DIFFERENCE': return Deposit.DIFFERENCE;
    default: throw ParsingException('Unknown deposit type', s);
  }
}

/// Converts a deposit mode to a2l string
String depositToString(Deposit s){
  switch(s) {
    case Deposit.ABSOLUTE: return 'ABSOLUTE';
    case Deposit.DIFFERENCE: return 'DIFFERENCE';
    default: throw ValidationError('Unknown deposit type');
  }
}


