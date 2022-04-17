import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';

enum CharacteristicType {
  /// String
  ASCII,
  /// 1d array with axes
  CURVE,
  /// 2d array with axes
  MAP,
  /// 3d array with axes
  CUBOID,
  /// 4d array with axes
  CUBE_4,
  /// 5d array with axes
  CUBE_5,
  /// array without axes
  VAL_BLK,
  /// scalar
  VALUE
}

CharacteristicType characteristicTypeFromString(Token s) {
    switch(s.text){
    case 'ASCII': return CharacteristicType.ASCII;
    case 'CURVE': return CharacteristicType.CURVE;
    case 'MAP': return CharacteristicType.MAP;
    case 'CUBOID': return CharacteristicType.CUBOID;
    case 'CUBE_4': return CharacteristicType.CUBE_4;
    case 'CUBE_5': return CharacteristicType.CUBE_5;
    case 'VAL_BLK': return CharacteristicType.VAL_BLK;
    case 'VALUE': return CharacteristicType.VALUE;
    default: throw ParsingException('Unknown Characteristic Type', s);
  }
}


enum CalibrationAccess {
  /// object can be modified
  CALIBRATION,
  /// object is read only
  NO_CALIBRATION,
  /// object can not be accessed
  NOT_IN_MCD_SYSTEM,
  /// object can be flashed but not changed online
  OFFLINE_CALIBRATION
 
}

CalibrationAccess calibrationAccessFromString(Token s) {
    switch(s.text){
    case 'CALIBRATION': return CalibrationAccess.CALIBRATION;
    case 'NO_CALIBRATION': return CalibrationAccess.NO_CALIBRATION;
    case 'NOT_IN_MCD_SYSTEM': return CalibrationAccess.NOT_IN_MCD_SYSTEM;
    case 'OFFLINE_CALIBRATION': return CalibrationAccess.OFFLINE_CALIBRATION;
    default: throw ParsingException('Unknown Calibration Access', s);
  }
}

class ExtendedLimits {
  double lowerLimit=0.0;
  double upperLimit=0.0;
}

class DependentCharacteristics {
  String formula='';
  List<String> characteristics;
  DependentCharacteristics() : characteristics=[];
}

/// This class represents a configurable value in the ECU.
class Characteristic extends MeasurementCharacteristicBase {
  // name is in base
  // desciption is in base
  CharacteristicType type = CharacteristicType.VALUE;
  int address = 0;
  String recordLayout = '';
  double maxDiff = 0.0;
  // conversion method is in base
  // lowerLimit is in base
  // upperLimit is in base

  // optional
  // annotation  is in base
  // TODO AXIS_DESCR
  // bitMask  is in base
  // endianess is in base
  CalibrationAccess? calibrationAccess;
  String? comparisionQuantity;
  DependentCharacteristics? dependentCharacteristics;
  // discrete is in base
  // displayIdentifier is in base
  // addressExtension is in base
  ExtendedLimits? extendedLimits;
  // format is in base
  // Function list is in base (DataContainer)
  /// If the object uses guard rails (if first and last value can be modified)
  bool guardRails = false;

  // TODO IF_DATA

  List<String> mapList;
  // matrixDim is in base
  // maxRefresh is in base
  /// Describes size for types ASCII and VAL_BLK
  int? number;
  // unit is in base
  // readWrite is in base
  // memorySegment is in base
  // symbolLink is in base
  double? stepSize;
  DependentCharacteristics? virtualCharacteristics;

  Characteristic() : mapList=[] {
    readWrite = true;
  }
}






