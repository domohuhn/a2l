
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';
import 'package:a2l/src/a2l_tree/group.dart';
import 'package:a2l/src/a2l_tree/measurement.dart';
import 'package:a2l/src/a2l_tree/unit.dart';
import 'package:a2l/src/a2l_tree/module_common.dart';
import 'package:a2l/src/a2l_tree/module_parameters.dart';
import 'package:a2l/src/a2l_tree/record_layout.dart';



class Module {
  String name = '';
  String description = '';
  ModuleCommon? common;
  ModuleParameters? parameters;
  List<Measurement> measurements;
  List<Characteristic> characteristics;
  List<Unit> units;
  List<ComputeMethod> computeMethods;
  List<ComputeTableBase> computeTables;
  List<Group> groups;
  List<RecordLayout> recordLayouts;
  Module() :
    measurements = [],
    characteristics = [],
    units = [],
    computeMethods = [],
    computeTables = [],
    groups = [],
    recordLayouts = []
  ;

  
  @override
  String toString() {
    var rv='Module "$name"\n$description\n\n';
    rv+='Measurements: ${measurements.length}\n';
    rv+='Characteristics: ${characteristics.length}\n';
    rv+='Units: ${units.length}\n';
    rv+='Compute Methods: ${computeMethods.length}\n';
    rv+='Compute Tables: ${computeTables.length}\n';
    rv+='Groups: ${groups.length}\n';
    rv+='Record layouts: ${recordLayouts.length}\n';
    return rv;
  }

  /// Converts the module to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = '/begin MODULE\n\n';
    for(final u in units) {
      rv += u.toFileContents(depth+1);
    }
    rv += '/end MODULE\n\n';
    return rv;
  }
}




