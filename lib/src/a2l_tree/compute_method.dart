import 'package:a2l/src/a2l_tree/formula.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'dart:math';

import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Describes the type of compute method to use.
enum ComputeMethodType {
  IDENTICAL,
  FORM,
  LINEAR,
  RAT_FUNC,
  TAB_INTP,
  TAB_NOINTP,
  TAB_VERB
}

/// Converts the a2l Token [s] to the enum.
ComputeMethodType computeMethodTypeFromSting(Token s) {
  switch(s.text) {
    case 'IDENTICAL': return ComputeMethodType.IDENTICAL;
    case 'FORM': return ComputeMethodType.FORM;
    case 'LINEAR': return ComputeMethodType.LINEAR;
    case 'RAT_FUNC': return ComputeMethodType.RAT_FUNC;
    case 'TAB_INTP': return ComputeMethodType.TAB_INTP;
    case 'TAB_NOINTP': return ComputeMethodType.TAB_NOINTP;
    case 'TAB_VERB': return ComputeMethodType.TAB_VERB;
    default: throw ParsingException('Unknown Compute Method Type', s);
  }
}

/// Converts the method type [s] to the a2l String.
String computeMethodTypeToSting(ComputeMethodType s) {
  switch(s) {
    case ComputeMethodType.IDENTICAL: return 'IDENTICAL';
    case ComputeMethodType.FORM: return 'FORM';
    case ComputeMethodType.LINEAR: return 'LINEAR';
    case ComputeMethodType.RAT_FUNC: return 'RAT_FUNC';
    case ComputeMethodType.TAB_INTP: return 'TAB_INTP';
    case ComputeMethodType.TAB_NOINTP: return 'TAB_NOINTP';
    case ComputeMethodType.TAB_VERB: return 'TAB_VERB';
    default: throw ValidationError('Unknown Compute Method Type');
  }
}

/// The expection thrown when an error happens during the converions.
class ComputeException implements Exception {
  /// Cause of the error.
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
  Formula? formula;
  String? referenced_unit;
  String? referenced_statusString;

  double convertToPhysical(BigInt input){
    switch(type) {
      case ComputeMethodType.IDENTICAL:
        return input.toDouble();
      case ComputeMethodType.FORM:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.LINEAR:
        if (coefficient_a == null || coefficient_b == null) {
          throw ComputeException('Coefficients for compute method "$name" LINEAR not defined!');
        }
        return coefficient_a! * input.toDouble() + coefficient_b!;
      case ComputeMethodType.RAT_FUNC:
        if (coefficient_a == null || coefficient_b == null || coefficient_c == null || coefficient_d == null || coefficient_e == null || coefficient_f == null) {
          throw ComputeException('Coefficients for compute method "$name" RAT_FUNC not defined!');
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
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.TAB_NOINTP:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.TAB_VERB:
        throw ComputeException('$type is not imlemented for "$name"!');
    }
  }

  BigInt convertToInternal(double input){
    switch(type) {
      case ComputeMethodType.IDENTICAL:
        return BigInt.from(input.toInt());
      case ComputeMethodType.FORM:
        throw ComputeException('$type is not imlemented for "$name"!');
      case ComputeMethodType.LINEAR:
        if (coefficient_a == null || coefficient_b == null) {
          throw ComputeException('Coefficients for compute method "$name" LINEAR not defined!');
        }
        return BigInt.from((input - coefficient_b!)~/coefficient_a!);
      case ComputeMethodType.RAT_FUNC:
        if (coefficient_a == null || coefficient_b == null || coefficient_c == null || coefficient_d == null || coefficient_e == null || coefficient_f == null) {
          throw ComputeException('Coefficients for compute method "$name" RAT_FUNC not defined!');
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

  /// Converts the compute method to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin COMPU_METHOD $name',depth);
    rv += indent('"$description"',depth+1);
    rv += indent('${computeMethodTypeToSting(type)} "$format" "$unit"',depth+1);
    switch(type) {
      case ComputeMethodType.IDENTICAL: break;
      case ComputeMethodType.FORM:
        if(formula!=null) {
          rv += formula!.toFileContents(depth+1);
        }
        else {
          throw ValidationError('Compute method "$name" has $type but no Formula');
        }
        break;
      case ComputeMethodType.LINEAR:
        if(coefficient_a!=null && coefficient_b!=null) {
          rv += indent('COEFFS_LINEAR $coefficient_a $coefficient_b',depth+1);
        } else {
          throw ValidationError('Compute method "$name" has $type but no coefficients a: $coefficient_a and b: $coefficient_b!');
        }
        break;
      case ComputeMethodType.RAT_FUNC:
        if(coefficient_a!=null && coefficient_b!=null && coefficient_c!=null
          && coefficient_d!=null && coefficient_e!=null && coefficient_f!=null) {
          rv += indent('COEFFS $coefficient_a $coefficient_b $coefficient_c $coefficient_d $coefficient_e $coefficient_f',depth+1);
        } else {
          throw ValidationError('Compute method "$name" has $type but no missing coefficients a: $coefficient_a b: $coefficient_b c: $coefficient_c d: $coefficient_d e: $coefficient_e f: $coefficient_f!');
        }
        break;
      case ComputeMethodType.TAB_INTP:
      case ComputeMethodType.TAB_NOINTP:
      case ComputeMethodType.TAB_VERB:
        if(referenced_table!=null && referenced_table!.isNotEmpty) {
          rv += indent('COMPU_TAB_REF $referenced_table',depth+1);
        } else {
          throw ValidationError('Compute method "$name" has $type but no referenced table!');
        }
        break;
    }
    if(referenced_unit!=null && referenced_unit!.isNotEmpty) {
      rv += indent('REF_UNIT $referenced_unit',depth+1);
    }
    if(referenced_statusString!=null && referenced_statusString!.isNotEmpty) {
      rv += indent('STATUS_STRING_REF $referenced_statusString',depth+1);
    }
    rv += indent('/end COMPU_METHOD\n\n',depth);
    return rv;
  }

}






