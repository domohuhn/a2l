
import 'package:a2l/src/a2l_tree/compute_method.dart';


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
}











