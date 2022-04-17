
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/utility.dart';


class ComputeTableEntry {
  double x = 0.0;
  double x_up = 0.0;
  bool isFloat = false;
  double outNumeric = 0.0;
  String outString = '';

  ComputeTableEntry({this.x = 0.0, this.x_up = 0.0, this.isFloat = false, this.outNumeric = 0.0, this.outString = ''});
}

abstract class ComputeTableBase {
  String name = '';
  String description = '';
  ComputeMethodType type = ComputeMethodType.TAB_INTP;
  List<ComputeTableEntry> table;
  ComputeTableBase() : table=[];

  String convertToPhysical(double input);

  double convertToInternal(String input)
  {
    // TODO interpolation tables?
    for(var i=0;i<table.length; ++i) {
      if(input==table[i].outNumeric.toString()) {
        return table[i].x;
      }
    }
    throw ComputeException('"$input" is not part of the table $name!');
  }

  String? fallbackValue;
  double? fallbackValueNumeric;

  /// Converts the compute table to an a2l file with the given indentation [depth].
  String toFileContents(int depth);
}


class ComputeTable extends ComputeTableBase {

  @override
  String convertToPhysical(double input) {
    if(type ==  ComputeMethodType.TAB_INTP) {
      var rv=0.0;
      var index = -1;
      for(var i=0;i<table.length; ++i) {
        if(input<table[i].x) {
          index = i;
        }
      }
      if(index==0 || index==-1) {
        if(fallbackValueNumeric!=null) {
          return fallbackValueNumeric.toString();
        }
        if(fallbackValue!=null) {
          return fallbackValue!;
        }
        return 'Value out of range';
      }
      var ylow = table[index-1].outNumeric;
      var yhi = table[index].outNumeric;
      var xlow = table[index-1].x;
      var xhi = table[index].x;
      rv = ylow + yhi * (input-xlow)/(xhi-xlow);
      return rv.toString();
    }
    else {
      for(var i=0;i<table.length; ++i) {
        if(input==table[i].x) {
          return table[i].outNumeric.toString();
        }
      }
      if(fallbackValueNumeric!=null) {
        return fallbackValueNumeric.toString();
      }
      if(fallbackValue!=null) {
        return fallbackValue!;
      }
      return 'Value out of range';
    }
  }

  
  /// Converts the compute table to an a2l file with the given indentation [depth].
  @override
  String toFileContents(int depth){
    var rv = indent('/begin COMPU_TAB $name',depth);
    rv += indent('"$description"',depth+1);
    rv += indent('${computeMethodTypeToSting(type)} ${table.length}',depth+1);
    for(var val in table) {
      rv += indent('${val.x} ${val.outNumeric}',depth+1);
    }
    if(fallbackValue!=null && fallbackValueNumeric!=null) {
      throw ValidationError('Compute table "$name": DEFAULT_VALUE and DEFAULT_VALUE_NUMERIC cannot both be used!');
    }
    else if (fallbackValue!=null) {
      rv += indent('DEFAULT_VALUE "$fallbackValue"',depth+1);
    }
    else if (fallbackValueNumeric!=null) {
      rv += indent('DEFAULT_VALUE_NUMERIC $fallbackValueNumeric',depth+1);
    }
    rv += indent('/end COMPU_TAB\n\n',depth);
    return rv;
  }

}


class VerbatimTable extends ComputeTableBase {
  VerbatimTable() {
    type = ComputeMethodType.TAB_VERB;
  }

  @override
  String convertToPhysical(double input) {
    for(var i=0;i<table.length; ++i) {
      if(input==table[i].x) {
        return table[i].outString;
      }
    }
    if(fallbackValue!=null) {
      return fallbackValue!;
    }
    return 'Value out of range';
  }

  /// Converts the compute table to an a2l file with the given indentation [depth].
  @override
  String toFileContents(int depth){
    var rv = indent('/begin COMPU_VTAB $name',depth);
    rv += indent('"$description"',depth+1);
    rv += indent('${computeMethodTypeToSting(type)} ${table.length}',depth+1);
    for(var val in table) {
      rv += indent('${val.x} "${val.outString}"',depth+1);
    }
    if (fallbackValue!=null) {
      rv += indent('DEFAULT_VALUE "$fallbackValue"',depth+1);
    }
    rv += indent('/end COMPU_VTAB\n\n',depth);
    return rv;
  }
}


class VerbatimRangeTable extends ComputeTableBase {
  VerbatimRangeTable() {
    type = ComputeMethodType.TAB_VERB;
  }

  @override
  String convertToPhysical(double input) {
    for(var i=0;i<table.length; ++i) {
      if(table[i].x<= input && ((table[i].isFloat && input < table[i].x_up) || (input <= table[i].x_up))) {
        return table[i].outString;
      }
    }
    if(fallbackValue!=null) {
      return fallbackValue!;
    }
    return 'Value out of range';
  }

  /// Converts the compute table to an a2l file with the given indentation [depth].
  @override
  String toFileContents(int depth){
    var rv = indent('/begin COMPU_VTAB_RANGE $name',depth);
    rv += indent('"$description"',depth+1);
    rv += indent('${table.length}',depth+1);
    for(var val in table) {
      rv += indent('${val.x} ${val.x_up} "${val.outString}"',depth+1);
    }
    if (fallbackValue!=null) {
      rv += indent('DEFAULT_VALUE "$fallbackValue"',depth+1);
    }
    rv += indent('/end COMPU_VTAB_RANGE\n\n',depth);
    return rv;
  }
}











