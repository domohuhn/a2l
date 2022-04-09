import 'package:a2l/src/parsing_exception.dart';
import 'dart:math';

enum ComputeMethodType {
  IDENTICAL,
  FORM,
  LINEAR,
  RAT_FUNC,
  TAB_INTP,
  TAB_NOINTP,
  TAB_VERB
}

ComputeMethodType computeMethodTypeFromSting(String s) {
  switch(s) {
    case 'IDENTICAL': return ComputeMethodType.IDENTICAL;
    case 'FORM': return ComputeMethodType.FORM;
    case 'LINEAR': return ComputeMethodType.LINEAR;
    case 'RAT_FUNC': return ComputeMethodType.RAT_FUNC;
    case 'TAB_INTP': return ComputeMethodType.TAB_INTP;
    case 'TAB_NOINTP': return ComputeMethodType.TAB_NOINTP;
    case 'TAB_VERB': return ComputeMethodType.TAB_VERB;
    default: throw ParsingException('Unknown Compute Method Type $s', '', 0);
  }
}

class ComputeException implements Exception {
  String cause;
  ComputeException(this.cause);

  @override
  String toString() {
    return '$cause';
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

  double? coefficient_a;
  double? coefficient_b;
  double? coefficient_c;
  double? coefficient_d;
  double? coefficient_e;
  double? coefficient_f;
  String? referenced_table;
  String? formula;
  String? referenced_unit;
  String? referenced_statusString;

  double convertToPhysical(BigInt input){
    switch(type) {
      case ComputeMethodType.IDENTICAL:
        return input.toDouble();
      case ComputeMethodType.FORM:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.LINEAR:
        if (coefficient_a == null || coefficient_b == null) {
          throw ComputeException('Coefficients for compute method LINEAR not defined!');
        }
        return coefficient_a! * input.toDouble() + coefficient_b!;
      case ComputeMethodType.RAT_FUNC:
        if (coefficient_a == null || coefficient_b == null || coefficient_c == null || coefficient_d == null || coefficient_e == null || coefficient_f == null) {
          throw ComputeException('Coefficients for compute method RAT_FUNC not defined!');
        }
        var x = input.toDouble();
        var p_a = (coefficient_d!*x-coefficient_a!);
        var p_b = (coefficient_e!*x-coefficient_b!);
        var p_c = (coefficient_f!*x-coefficient_c!);
        if(p_a!=0.0) {
          return (-p_b + sqrt(p_b*p_b - 4*p_a*p_c))/(2*p_a);
        } else if(p_b!=0.0) {
          return -p_c/p_b;
        } else {
          return p_c;
        }
      case ComputeMethodType.TAB_INTP:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.TAB_NOINTP:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.TAB_VERB:
        throw ComputeException('$type is not imlemented!');
    }
  }

  BigInt convertToInternal(double input){
    switch(type) {
      case ComputeMethodType.IDENTICAL:
        return BigInt.from(input.toInt());
      case ComputeMethodType.FORM:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.LINEAR:
        if (coefficient_a == null || coefficient_b == null) {
          throw ComputeException('Coefficients for compute method LINEAR not defined!');
        }
        return BigInt.from((input - coefficient_b!)~/coefficient_a!);
      case ComputeMethodType.RAT_FUNC:
        if (coefficient_a == null || coefficient_b == null || coefficient_c == null || coefficient_d == null || coefficient_e == null || coefficient_f == null) {
          throw ComputeException('Coefficients for compute method RAT_FUNC not defined!');
        }
        return BigInt.from((coefficient_a! *input*input+ coefficient_b! *input + coefficient_c!)~/(coefficient_d!*input*input + coefficient_e!*input+ coefficient_f!));
      case ComputeMethodType.TAB_INTP:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.TAB_NOINTP:
        throw ComputeException('$type is not imlemented!');
      case ComputeMethodType.TAB_VERB:
        throw ComputeException('$type is not imlemented!');
    }
  }


}






