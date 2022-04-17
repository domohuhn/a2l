


import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/utility.dart';

/// Represents a list of measurements with a timing.
/// This allows selecting similiar measurements from a selection of lists in the calibration system.
class Frame {
  Frame() : measurements=[];
  /// name of the Frame object
  String name='';
  /// description of the object
  String description='';
  /// Which base unit to use.
  MaxRefreshUnit scalingUnit=MaxRefreshUnit.non_deterministic;
  /// Multiplier of the base unit.
  int rate=0;

  // optional
  /// references to other measuremnt objects
  List<String> measurements;
  // TODO IF_DATA

  /// Converts the compute method to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin FRAME $name',depth);
    rv += indent('"$description" ${maxRefreshUnitToString(scalingUnit)} $rate',depth+1);
    if(measurements.isNotEmpty) {
      var tmpStr = '';
      for(final m in measurements) {
        tmpStr += ' $m';
      }
      rv += indent('FRAME_MEASUREMENT$tmpStr',depth+1);
    }
    rv += indent('/end FRAME\n\n',depth);
    return rv;
  }
}







