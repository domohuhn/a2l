import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/utility.dart';

class Group extends DataContainer {
  bool root = false;

  /// Converts the group to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin GROUP $name',depth);
    if(characteristics.isNotEmpty) {
      rv += indent('/begin REF_CHARACTERISTIC',depth+1);
      for(final char in characteristics) {
        rv += indent('$char',depth+2);
      }
      rv += indent('/end REF_CHARACTERISTIC',depth+1);
    }
    if(measurements.isNotEmpty) {
      rv += indent('/begin REF_MEASUREMENT',depth+1);
      for(final measure in measurements) {
        rv += indent('$measure',depth+2);
      }
      rv += indent('/end REF_MEASUREMENT',depth+1);
    }
    if(groups.isNotEmpty) {
      rv += indent('/begin SUB_GROUP',depth+1);
      for(final data in groups) {
        rv += indent('$data',depth+2);
      }
      rv += indent('/end SUB_GROUP',depth+1);
    }
    
    if(functions.isNotEmpty) {
      rv += indent('/begin FUNCTION_LIST',depth+1);
      for(final data in functions) {
        rv += indent('$data',depth+2);
      }
      rv += indent('/end FUNCTION_LIST',depth+1);
    }
    
    if(root) {
      rv += indent('ROOT',depth+1);
    }
    rv += annotationsToFileContents(depth+1);
    rv += indent('/end GROUP\n\n',depth);
    return rv;
  }
}








