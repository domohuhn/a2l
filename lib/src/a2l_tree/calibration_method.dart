




import 'package:a2l/src/utility.dart';

/// This structure is used to indicate the calibration methods that can be used
/// regardless of the interface on the ECU.
class CalibrationMethod {
  CalibrationMethod() : handles = [];
  // mandatory
  /// This string identifies the calibration method.
  /// 'InCircuit', 'SERAM', 'DSERAP' and 'BSERAP' are used.
  String method = '';
  /// version number
  int version = 0;

  // optional
  /// Method arguments. Meaning depends on the selected method
  List<int> handles;
  String? handleText;

  /// Converts the object to a part of an a2l file with indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin CALIBRATION_METHOD', depth);
    rv += indent('"$method"', depth+1);
    rv += indent('$version', depth+1);
    if (handles.isNotEmpty || handleText != null) {
      rv += indent('/begin CALIBRATION_HANDLE', depth+1);
      for(final v in handles) {
        rv += indent('0x${v.toRadixString(16)}', depth+2);
      }
      if(handleText!=null) {
        rv += indent('CALIBRATION_HANDLE_TEXT "$handleText"', depth+2);
      }
      rv += indent('/end CALIBRATION_HANDLE', depth+1);
    }
    rv += indent('/end CALIBRATION_METHOD\n\n', depth);
    return rv;
  }
}



