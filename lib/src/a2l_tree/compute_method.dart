import 'package:a2l/src/a2l_tree/formula.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'dart:math';

import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Describes the type of compute method to use.
enum ComputeMethodType { IDENTICAL, FORM, LINEAR, RAT_FUNC, TAB_INTP, TAB_NOINTP, TAB_VERB }

/// Converts the a2l Token [s] to the enum.
ComputeMethodType computeMethodTypeFromSting(Token s) {
  switch (s.text) {
    case 'IDENTICAL':
      return ComputeMethodType.IDENTICAL;
    case 'FORM':
      return ComputeMethodType.FORM;
    case 'LINEAR':
      return ComputeMethodType.LINEAR;
    case 'RAT_FUNC':
      return ComputeMethodType.RAT_FUNC;
    case 'TAB_INTP':
      return ComputeMethodType.TAB_INTP;
    case 'TAB_NOINTP':
      return ComputeMethodType.TAB_NOINTP;
    case 'TAB_VERB':
      return ComputeMethodType.TAB_VERB;
    default:
      throw ParsingException('Unknown Compute Method Type', s);
  }
}

/// Converts the method type [s] to the a2l String.
String computeMethodTypeToSting(ComputeMethodType s) {
  switch (s) {
    case ComputeMethodType.IDENTICAL:
      return 'IDENTICAL';
    case ComputeMethodType.FORM:
      return 'FORM';
    case ComputeMethodType.LINEAR:
      return 'LINEAR';
    case ComputeMethodType.RAT_FUNC:
      return 'RAT_FUNC';
    case ComputeMethodType.TAB_INTP:
      return 'TAB_INTP';
    case ComputeMethodType.TAB_NOINTP:
      return 'TAB_NOINTP';
    case ComputeMethodType.TAB_VERB:
      return 'TAB_VERB';
    default:
      throw ValidationError('Unknown Compute Method Type');
  }
}

/// The expection thrown when an error happens during the converions.
class ComputeException implements Exception {
  /// Cause of the error.
  String cause;
  ComputeException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

/// This class holds the data to convert physical values to bus data and vice versa.
///
/// For linear conversions, the following formula is used (internal -> physical):
///     physical = a*x + b
///
/// For rational conversions, the following formula is used (physical -> internal):
///     internal = (a*x*x + b*x +c)/(d*x*x + e*x + f)
class ComputeMethod {
  String name = '';
  String description = '';
  ComputeMethodType type = ComputeMethodType.IDENTICAL;
  String format = '';
  String unit = '';

  double? coefficientA;
  double? coefficientB;
  double? coefficientC;
  double? coefficientD;
  double? coefficientE;
  double? coefficientF;
  String? referencedTable;
  Formula? formula;
  String? referencedUnit;
  String? referencedStatusString;

  double convertToPhysical(BigInt input) {
    switch (type) {
      case ComputeMethodType.IDENTICAL:
        return input.toDouble();
      case ComputeMethodType.FORM:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.LINEAR:
        if (coefficientA == null || coefficientB == null) {
          throw ComputeException('Coefficients for compute method "$name" LINEAR not defined!');
        }
        return coefficientA! * input.toDouble() + coefficientB!;
      case ComputeMethodType.RAT_FUNC:
        if (coefficientA == null ||
            coefficientB == null ||
            coefficientC == null ||
            coefficientD == null ||
            coefficientE == null ||
            coefficientF == null) {
          throw ComputeException('Coefficients for compute method "$name" RAT_FUNC not defined!');
        }
        var x = input.toDouble();
        var A = (coefficientD! * x - coefficientA!);
        var B = (coefficientE! * x - coefficientB!);
        var C = (coefficientF! * x - coefficientC!);
        if (A != 0.0) {
          return (-B + sqrt(B * B - 4 * A * C)) / (2 * A);
        } else if (B != 0.0) {
          return -C / B;
        } else {
          return C;
        }
      case ComputeMethodType.TAB_INTP:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.TAB_NOINTP:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.TAB_VERB:
        throw ComputeException('$type is not imlemented for "$name"!');
    }
  }

  BigInt convertToInternal(double input) {
    switch (type) {
      case ComputeMethodType.IDENTICAL:
        return BigInt.from(input.toInt());
      case ComputeMethodType.FORM:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.LINEAR:
        if (coefficientA == null || coefficientB == null) {
          throw ComputeException('Coefficients for compute method "$name" LINEAR not defined!');
        }
        return BigInt.from((input - coefficientB!) ~/ coefficientA!);
      case ComputeMethodType.RAT_FUNC:
        if (coefficientA == null ||
            coefficientB == null ||
            coefficientC == null ||
            coefficientD == null ||
            coefficientE == null ||
            coefficientF == null) {
          throw ComputeException('Coefficients for compute method "$name" RAT_FUNC not defined!');
        }
        return BigInt.from((coefficientA! * input * input + coefficientB! * input + coefficientC!) ~/
            (coefficientD! * input * input + coefficientE! * input + coefficientF!));
      case ComputeMethodType.TAB_INTP:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.TAB_NOINTP:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.TAB_VERB:
        throw ComputeException('$type is not imlemented!');
    }
  }

  /// Converts the compute method to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin COMPU_METHOD $name', depth);
    rv += indent('"$description"', depth + 1);
    rv += indent('${computeMethodTypeToSting(type)} "$format" "$unit"', depth + 1);
    switch (type) {
      case ComputeMethodType.IDENTICAL:
        break;
      case ComputeMethodType.FORM:
        if (formula != null) {
          rv += formula!.toFileContents(depth + 1);
        } else {
          throw ValidationError('Compute method "$name" has $type but no Formula');
        }
        break;
      case ComputeMethodType.LINEAR:
        if (coefficientA != null && coefficientB != null) {
          rv += indent('COEFFS_LINEAR $coefficientA $coefficientB', depth + 1);
        } else {
          throw ValidationError('Compute method "$name" has $type but no coefficients a: $coefficientA and b: $coefficientB!');
        }
        break;
      case ComputeMethodType.RAT_FUNC:
        if (coefficientA != null &&
            coefficientB != null &&
            coefficientC != null &&
            coefficientD != null &&
            coefficientE != null &&
            coefficientF != null) {
          rv += indent('COEFFS $coefficientA $coefficientB $coefficientC $coefficientD $coefficientE $coefficientF', depth + 1);
        } else {
          throw ValidationError(
              'Compute method "$name" has $type but no missing coefficients a: $coefficientA b: $coefficientB c: $coefficientC d: $coefficientD e: $coefficientE f: $coefficientF!');
        }
        break;
      case ComputeMethodType.TAB_INTP:
      case ComputeMethodType.TAB_NOINTP:
      case ComputeMethodType.TAB_VERB:
        if (referencedTable != null && referencedTable!.isNotEmpty) {
          rv += indent('COMPU_TAB_REF $referencedTable', depth + 1);
        } else {
          throw ValidationError('Compute method "$name" has $type but no referenced table!');
        }
        break;
    }
    if (referencedUnit != null && referencedUnit!.isNotEmpty) {
      rv += indent('REF_UNIT $referencedUnit', depth + 1);
    }
    if (referencedStatusString != null && referencedStatusString!.isNotEmpty) {
      rv += indent('STATUS_STRING_REF $referencedStatusString', depth + 1);
    }
    rv += indent('/end COMPU_METHOD\n\n', depth);
    return rv;
  }
}
