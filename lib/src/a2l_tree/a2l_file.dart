
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';
import 'package:a2l/src/a2l_tree/group.dart';
import 'package:a2l/src/a2l_tree/measurement.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';

class Unit {
  String name = '';
  String description = '';
  String display = '';
  UnitType type = UnitType.EXTENDED_SI;
  String? referencedUnit;
  int? exponent_length;
  int? exponent_mass;
  int? exponent_time;
  int? exponent_electricCurrent;
  int? exponent_temperature;
  int? exponent_amountOfSubstance;
  int? exponent_luminousIntensity;
  double? conversionLinear_slope;
  double? conversionLinear_offset;
}

class Module {
  String name = '';
  String description = '';
  List<Measurement> measurements;
  List<Unit> units;
  List<ComputeMethod> computeMethods;
  List<ComputeTableBase> computeTables;
  List<Group> groups;
  Module() :
    measurements = [],
    units = [],
    computeMethods = [],
    computeTables = [],
    groups = []
  ;
}


class Project {
  String name = '';
  String longName = '';
  String? comment='';
  String? version;
  String? number;
  List<Module> modules;
  Project() : modules=[];
}

class A2LFile {
  int a2lMajorVersion = 0;
  int a2lMinorVersion = 0;
  int? a2mlMajorVersion;
  int? a2mlMinorVersion;
  Project project = Project();

}







