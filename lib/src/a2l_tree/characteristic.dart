import 'package:a2l/src/a2l_tree/axis_descr.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Represents the characteristic type in the a2l file.
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

/// Converts the token [s] to the characteristic type enum.
CharacteristicType characteristicTypeFromString(Token s) {
  switch (s.text) {
    case 'ASCII':
      return CharacteristicType.ASCII;
    case 'CURVE':
      return CharacteristicType.CURVE;
    case 'MAP':
      return CharacteristicType.MAP;
    case 'CUBOID':
      return CharacteristicType.CUBOID;
    case 'CUBE_4':
      return CharacteristicType.CUBE_4;
    case 'CUBE_5':
      return CharacteristicType.CUBE_5;
    case 'VAL_BLK':
      return CharacteristicType.VAL_BLK;
    case 'VALUE':
      return CharacteristicType.VALUE;
    default:
      throw ParsingException('Unknown Characteristic Type', s);
  }
}

/// Converts the enum value [s] to the a2l string.
String characteristicTypeToString(CharacteristicType s) {
  switch (s) {
    case CharacteristicType.ASCII:
      return 'ASCII';
    case CharacteristicType.CURVE:
      return 'CURVE';
    case CharacteristicType.MAP:
      return 'MAP';
    case CharacteristicType.CUBOID:
      return 'CUBOID';
    case CharacteristicType.CUBE_4:
      return 'CUBE_4';
    case CharacteristicType.CUBE_5:
      return 'CUBE_5';
    case CharacteristicType.VAL_BLK:
      return 'VAL_BLK';
    case CharacteristicType.VALUE:
      return 'VALUE';
    default:
      throw ValidationError('Unknown Characteristic Type $s');
  }
}

/// Represents the possible access modes of the value.
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

/// Converts the token [s] to the CalibrationAccess enum.
CalibrationAccess calibrationAccessFromString(Token s) {
  switch (s.text) {
    case 'CALIBRATION':
      return CalibrationAccess.CALIBRATION;
    case 'NO_CALIBRATION':
      return CalibrationAccess.NO_CALIBRATION;
    case 'NOT_IN_MCD_SYSTEM':
      return CalibrationAccess.NOT_IN_MCD_SYSTEM;
    case 'OFFLINE_CALIBRATION':
      return CalibrationAccess.OFFLINE_CALIBRATION;
    default:
      throw ParsingException('Unknown Calibration Access', s);
  }
}

/// Converts the enum [s] to the a2l string.
String calibrationAccessToString(CalibrationAccess s) {
  switch (s) {
    case CalibrationAccess.CALIBRATION:
      return 'CALIBRATION';
    case CalibrationAccess.NO_CALIBRATION:
      return 'NO_CALIBRATION';
    case CalibrationAccess.NOT_IN_MCD_SYSTEM:
      return 'NOT_IN_MCD_SYSTEM';
    case CalibrationAccess.OFFLINE_CALIBRATION:
      return 'OFFLINE_CALIBRATION';
    default:
      throw ValidationError('Unknown Calibration Access $s');
  }
}

/// Extended limits. The calibration system may allow to leave the normal limits.
class ExtendedLimits {
  double lowerLimit = 0.0;
  double upperLimit = 0.0;

  /// Converts the object to its an a2l string representation with the given indentation [depth].
  String toFileContents(int depth) {
    return indent('EXTENDED_LIMITS $lowerLimit $upperLimit', depth);
  }
}

/// Contains the list of characteristics that depend on this characteristic.
class DependentCharacteristics {
  String formula = '';
  List<String> characteristics;
  DependentCharacteristics() : characteristics = [];

  /// Converts the object to its an a2l string representation with the given indentation [depth].
  String toFileContents(String key, int depth) {
    var rv = indent('/begin $key', depth);
    rv += indent('"$formula"', depth + 1);
    for (final c in characteristics) {
      rv += indent(c, depth + 1);
    }
    rv += indent('/end $key', depth);
    return rv;
  }
}

/// This class represents a configurable value in the ECU (a2l key: CHARACTERISTIC).
/// This is one of the primary components of A2L files. It allows the user to
/// modify the memory of an embedded system during runtime.
///
/// A Characteristic needs a description how to read the values ([address] and a reference to [RecordLayout]), a conversion method to convert
/// internal ECU values to a physical value, and potentially further display/layout options.
///
/// A Characteristic may be a single value, an array of values, or a curve with multiple axis.
/// The valid values for [type] are:
///
///   - ASCII: C-like char string (needs member [number] to be set).
///   - CURVE: a x-axis lookup to find the index and interpolation positions, and an output array that uses the positions to compute the output.
///   - MAP: a x-axis and y-axis lookup to find the index and interpolation positions, and an output array that uses the positions to compute the output.
///   - CUBOID: a x,y,z-axis lookup to find the index and interpolation positions, and an output array that uses the positions to compute the output.
///   - CUBE_4: a 4-axis lookup to find the index and interpolation positions, and an output array that uses the positions to compute the output.
///   - CUBE_5: a 5-axis lookup to find the index and interpolation positions, and an output array that uses the positions to compute the output.
///   - VAL_BLK: C-like array (needs member [number] to be set).
///   - VALUE: a single value located at the [address].
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
  // Description of the axis in order x,y,z,4,5 (a2l key: AXIS_DESCR)
  List<AxisDescription> axisDescription;
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

  Characteristic()
      : mapList = [],
        axisDescription = [] {
    readWrite = true;
  }

  /// Converts the characteristic to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin CHARACTERISTIC $name', depth);
    rv += indent('"$description"', depth + 1);
    rv += indent(
        '${characteristicTypeToString(type)} 0x${address.toRadixString(16).padLeft(8, "0")} $recordLayout $maxDiff $conversionMethod $lowerLimit $upperLimit',
        depth + 1);
    rv += optionalsToFileContents(depth + 1);
    if (calibrationAccess != null) {
      rv += indent('CALIBRATION_ACCESS ${calibrationAccessToString(calibrationAccess!)}', depth + 1);
    }
    if (comparisionQuantity != null) {
      rv += indent('COMPARISON_QUANTITY $comparisionQuantity', depth + 1);
    }
    if (extendedLimits != null) {
      rv += extendedLimits!.toFileContents(depth + 1);
    }
    if (guardRails) {
      rv += indent('GUARD_RAILS', depth + 1);
    }
    if (mapList.isNotEmpty) {
      rv += indent('/begin MAP_LIST', depth + 1);
      for (final data in mapList) {
        rv += indent(data, depth + 2);
      }
      rv += indent('/end MAP_LIST', depth + 1);
    }
    if (type == CharacteristicType.ASCII || type == CharacteristicType.VAL_BLK) {
      if (number != null || number! <= 0) {
        rv += indent('NUMBER $number', depth + 1);
      } else {
        throw ValidationError('Charactristic $name of $type needs a number > 0! got $number');
      }
    }
    if (stepSize != null) {
      rv += indent('STEP_SIZE $stepSize', depth + 1);
    }
    if (!readWrite) {
      rv += indent('READ_ONLY', depth + 1);
    }
    if (dependentCharacteristics != null) {
      rv += dependentCharacteristics!.toFileContents('DEPENDENT_CHARACTERISTIC', depth + 1);
    }
    if (virtualCharacteristics != null) {
      rv += virtualCharacteristics!.toFileContents('VIRTUAL_CHARACTERISTIC', depth + 1);
    }
    for (final a in axisDescription) {
      rv += a.toFileContents(depth + 1);
    }
    rv += annotationsToFileContents(depth + 1);
    rv += indent('/end CHARACTERISTIC\n\n', depth);
    return rv;
  }
}
