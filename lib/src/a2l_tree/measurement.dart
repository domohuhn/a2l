import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/utility.dart';

/// Describes a measurement from the ECU memory (a2l key: MEASUREMENT).
/// This is one of the primary componenst of A2L files.
///
/// A measurement needs a description how to read the values, a conversion method to convert
/// internal ECU values to a physical value, and potentially further display/layout options.
class Measurement extends MeasurementCharacteristicBase {
  /// Data type of the measurement.
  Datatype datatype = Datatype.int8;
  // conversion method is in base
  /// Resolution of the measurements.
  int resolution = 1;

  /// Accuracy of the measurements.
  double accuracy = 1.0;

  // optional values
  // lowerLimit is in base
  // upperLimit is in base
  /// Size of the Arrays for VAL_BLK
  int? arraySize;
  // bitMask  is in base
  BitOperation? bitOperation;
  // endianess is in base
  // discrete is in base
  // displayIdentifier is in base
  int? address;
  // addressExtension is in base
  int? errorMask;
  // format is in base
  // Function list is in base (DataContainer)
  // TODO IF_DATA
  IndexMode? layout;
  // matrixDim is in base
  // maxRefresh is in base
  // unit is in base
  // readWrite is in base
  // memorySegment is in base
  // symbolLink is in base
  // VIRTUAL is in measurements in base (DataContainer)

  Measurement() {
    readWrite = false;
  }

  /// Converts the measurement to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin MEASUREMENT $name', depth);
    rv += indent('"$description"', depth + 1);
    rv += indent('${dataTypeToString(datatype)} $conversionMethod $resolution $accuracy $lowerLimit $upperLimit', depth + 1);
    rv += optionalsToFileContents(depth + 1);
    if (arraySize != null) {
      rv += indent('ARRAY_SIZE $arraySize', depth + 1);
    }
    if (bitOperation != null) {
      rv += bitOperation!.toFileContents(depth + 1);
    }
    if (address != null) {
      rv += indent('ECU_ADDRESS 0x${address!.toRadixString(16).padLeft(8, "0")}', depth + 1);
    }
    if (errorMask != null) {
      rv += indent('ERROR_MASK 0x${errorMask!.toRadixString(16).padLeft(8, "0")}', depth + 1);
    }
    if (layout != null) {
      rv += indent('LAYOUT ${indexModeToString(layout!)}', depth + 1);
    }
    if (readWrite) {
      rv += indent('READ_WRITE', depth + 1);
    }

    if (measurements.isNotEmpty) {
      rv += indent('/begin VIRTUAL', depth + 1);
      for (final data in measurements) {
        rv += indent(data, depth + 2);
      }
      rv += indent('/end VIRTUAL', depth + 1);
    }
    rv += annotationsToFileContents(depth + 1);
    rv += indent('/end MEASUREMENT\n\n', depth);
    return rv;
  }
}
