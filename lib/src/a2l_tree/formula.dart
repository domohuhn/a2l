

import 'package:a2l/src/utility.dart';

/// Represents a formula from a compute method element.
class Formula {
  String formula = '';
  String? inverseFormula;

  /// Converts the compute method to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin FORMULA',depth);
    rv += indent('"$formula"',depth+1);
    if(inverseFormula!=null && inverseFormula!.isNotEmpty) {
      rv += indent('FORMULA_INV "$inverseFormula"',depth+1);
    }
    rv += indent('/end FORMULA',depth);
    return rv;
  }
}





