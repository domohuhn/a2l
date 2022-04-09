
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';

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

class Measurement extends AnnotationContainer {
  String name = '';
  String description = '';
  Datatype datatype = Datatype.int8;
  String conversionMethod = '';
  int resolution = 1;
  double accuracy = 1.0;
  double lowerLimit = 1.0;
  double upperLimit = 1.0;
  int? arraySize;
  int? bitMask;
  // TODO BIT operation
  ByteOrder? endianess;
  // TODO discrete
  String? displayIdentifier;
  int? address;
  int? addressExtension;
  int? errorMask;
  String? format;
  // TODO Function list
  // TODO IF_DATA
  IndexMode? layout;
  // TODO MATRIX_DIM
  // TODO MAX_REFRESH
  String? unit;
  // TODO READ_WRITE
  String? memorySegment;
  // TODo SYMBOL LINK
  // TODO VIRUTAL
}

enum UnitType {
  DERIVED,
  EXTENDED_SI
}

class Unit {
  String name = '';
  String description = '';
  String display = '';
  UnitType type = UnitType.EXTENDED_SI;
  String? referencedUnit;
  int? exponent_length;
  int? exponent_mass;
  int? exponent_time;
  int? exponent_electricCurrent;
  int? exponent_temperature;
  int? exponent_amountOfSubstance;
  int? exponent_luminousIntensity;
  double? conversionLinear_slope;
  double? conversionLinear_offset;
}

class Module {
  String name = '';
  String description = '';
  List<Measurement> measurements;
  List<Unit> units;
  List<ComputeMethod> computeMethods;
  List<ComputeTableBase> computeTables;
  Module() :
    measurements = [],
    units = [],
    computeMethods = [],
    computeTables = []
  ;
}


class Project {
  String name = '';
  String longName = '';
  String? comment='';
  String? version;
  String? number;
  List<Module> modules;
  Project() : modules=[];
}

class A2LFile {
  int a2lMajorVersion = 0;
  int a2lMinorVersion = 0;
  int? a2mlMajorVersion;
  int? a2mlMinorVersion;
  Project project = Project();

}







