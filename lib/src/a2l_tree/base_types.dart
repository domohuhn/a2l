
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';

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


enum UnitType {
  DERIVED,
  EXTENDED_SI
}



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

Datatype dataTypeFromString(String s) {
  switch(s) {
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
    default: throw ParsingException('Unknown data type $s', '', 0);
  }
}

enum ByteOrder {
  MSB_LAST,
  MSB_FIRST
}

ByteOrder byteOrderFromString(String s) {
  switch(s) {
    case 'MSB_LAST': return ByteOrder.MSB_LAST;
    case 'MSB_FIRST': return ByteOrder.MSB_FIRST;
    // wtf? ASAP2 standard is wrong? Standard even mentions that it uses different names to normal, therefore MSB_LAST was introduced
    case 'BIG_ENDIAN': return ByteOrder.MSB_LAST; 
    // wtf? ASAP2 standard is wrong? Standard even mentions that it uses different names to normal, therefore MSB_FIRST was introduced
    case 'LITTLE_ENDIAN': return ByteOrder.MSB_FIRST;
    default: throw ParsingException('Unknown byte order $s', '', 0);
  }
}

enum IndexMode {
  ALTERNATE_CURVES,
  ALTERNATE_WITH_X,
  ALTERNATE_WITH_Y,
  COLUMN_DIR,
  ROW_DIR
}

IndexMode indexModeFromString(String s) {
  switch(s) {
    case 'ALTERNATE_CURVES': return IndexMode.ALTERNATE_CURVES;
    case 'ALTERNATE_WITH_X': return IndexMode.ALTERNATE_WITH_X;
    case 'ALTERNATE_WITH_Y': return IndexMode.ALTERNATE_WITH_Y;
    case 'COLUMN_DIR': return IndexMode.COLUMN_DIR;
    case 'ROW_DIR': return IndexMode.ROW_DIR;
    default: throw ParsingException('Unknown index mode $s', '', 0);
  }
}

class BitOperation {
  int? leftShift;
  int? rightShift;
  bool signExtend=false;
}

class SymbolLink {
  String name='';
  int offset=0;
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

MaxRefreshUnit maxRefreshUnitFromString(String s){
  switch(s){
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
    default: throw ParsingException('Unknown ScalingUnit $s', '', 0);
  }
}

class MaxRefresh {
  MaxRefreshUnit scalingUnit=MaxRefreshUnit.non_deterministic;
  int rate=0;
}

class MatrixDim {
  int x=0;
  int y=0;
  int z=0;
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
  String? displayIdentifier;
  int? addressExtension;
  String? format;
  MatrixDim? matrixDim;
  MaxRefresh? maxRefresh;
  String? unit;
  /// if the value is read write (characteristic default = rw, measurement default = ro)
  bool readWrite = false;
  String? memorySegment;
  SymbolLink? symbolLink;
}
