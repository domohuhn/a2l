import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/passthrough_blocks.dart';
import 'package:a2l/src/utility.dart';

/// Holds data that can be used to structure large projects from a functional point of view.
/// Name, description, Referenced characteristics, annotations, sub functions and local
/// measurements are in base class.
///
/// Called CFunction to prevent naming conflicts with the dart Function keyword.
class CFunction extends DataContainer {
  CFunction()
      : definedCharacteristics = [],
        inputMeasurements = [],
        outputMeasurements = [],
        interfaceData = [];

  // optional
  // annotations are in base.
  /// characteristics defined in the function
  List<String> definedCharacteristics;

  /// Measurement values for the input to the function
  List<String> inputMeasurements;

  /// Measurement values for the output of the function
  List<String> outputMeasurements;

  /// version of the function object
  String? version;

  /// The interface description (if present). The library will not process these strings in any way.  (a2l key: IFDATA)
  List<String> interfaceData;

  /// Converts the object to an a2l string with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin FUNCTION $name', depth);
    rv += indent('"$description"', depth + 1);
    if (version != null) {
      rv += indent('FUNCTION_VERSION "$version"', depth + 1);
    }
    rv += annotationsToFileContents(depth + 1);
    if (definedCharacteristics.isNotEmpty) {
      rv += indent('/begin DEF_CHARACTERISTIC', depth + 1);
      for (final v in definedCharacteristics) {
        rv += indent(v, depth + 2);
      }
      rv += indent('/end DEF_CHARACTERISTIC', depth + 1);
    }
    if (inputMeasurements.isNotEmpty) {
      rv += indent('/begin IN_MEASUREMENT', depth + 1);
      for (final v in inputMeasurements) {
        rv += indent(v, depth + 2);
      }
      rv += indent('/end IN_MEASUREMENT', depth + 1);
    }
    if (measurements.isNotEmpty) {
      rv += indent('/begin LOC_MEASUREMENT', depth + 1);
      for (final v in measurements) {
        rv += indent(v, depth + 2);
      }
      rv += indent('/end LOC_MEASUREMENT', depth + 1);
    }
    if (outputMeasurements.isNotEmpty) {
      rv += indent('/begin OUT_MEASUREMENT', depth + 1);
      for (final v in outputMeasurements) {
        rv += indent(v, depth + 2);
      }
      rv += indent('/end OUT_MEASUREMENT', depth + 1);
    }
    if (characteristics.isNotEmpty) {
      rv += indent('/begin REF_CHARACTERISTIC', depth + 1);
      for (final v in characteristics) {
        rv += indent(v, depth + 2);
      }
      rv += indent('/end REF_CHARACTERISTIC', depth + 1);
    }
    if (functions.isNotEmpty) {
      rv += indent('/begin SUB_FUNCTION', depth + 1);
      for (final v in functions) {
        rv += indent(v, depth + 2);
      }
      rv += indent('/end SUB_FUNCTION', depth + 1);
    }
    rv += writeListOfBlocks( depth + 1, 'IF_DATA', interfaceData);

    rv += indent('/end FUNCTION\n\n', depth);
    return rv;
  }
}
