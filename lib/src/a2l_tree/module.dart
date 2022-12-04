import 'package:a2l/src/a2l_tree/axis_pts.dart';
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';
import 'package:a2l/src/a2l_tree/frame.dart';
import 'package:a2l/src/a2l_tree/function.dart';
import 'package:a2l/src/a2l_tree/group.dart';
import 'package:a2l/src/a2l_tree/measurement.dart';
import 'package:a2l/src/a2l_tree/passthrough_blocks.dart';
import 'package:a2l/src/a2l_tree/unit.dart';
import 'package:a2l/src/a2l_tree/module_common.dart';
import 'package:a2l/src/a2l_tree/module_parameters.dart';
import 'package:a2l/src/a2l_tree/record_layout.dart';
import 'package:a2l/src/a2l_tree/user_rights.dart';
import 'package:a2l/src/a2l_tree/variant_coding.dart';
import 'package:a2l/src/utility.dart';

/// Holds the top level module information.
/// A project may have multiple modules.
/// a2l key: MODULE
class Module {
  // mandatory
  /// name of the module. must be unique.
  String name = '';

  /// description of the module.
  String description = '';

  // optional
  /// Common module data (e.g. type alignments.). (a2l key: MOD_COMMON)
  ModuleCommon? common;

  /// Some general module parameters (e.g. version, supplier, cpu). (a2l key: MOD_PAR)
  ModuleParameters? parameters;

  /// Describes characteristics that change based on coding. (a2l key: VARIANT_CODING)
  VariantCoding? coding;

  /// Describes measurement values. (a2l key: MEASUREMENT)
  List<Measurement> measurements;

  /// Describes calibration parameters. (a2l key: CHARACTERISTIC)
  List<Characteristic> characteristics;

  /// Describes physical units. (a2l key: UNIT)
  List<Unit> units;

  /// Describes conversion methods of raw data to displayed values. (a2l key: COMPU_METHOD)
  List<ComputeMethod> computeMethods;

  /// Describes conversion tables of raw data to displayed values. (a2l key: COMPU_TAB, COMPU_VTAB, COMPU_VTAB_RANGE depending on selected class)
  List<ComputeTableBase> computeTables;

  /// Can be used to group other values (a2l key: GROUP)
  List<Group> groups;

  /// Data record layout. Describes the representation of the objects in ECU memory. (a2l key: RECORD_LAYOUT)
  List<RecordLayout> recordLayouts;

  /// The frames in the a2l file. (It is possible that there is only one allowed frame - no star in standard.
  /// But everything else refers to frames in plural.) (a2l key: FRAME)
  List<Frame> frames;

  /// Describes visible values and access rights for certain users (a2l key: USER_RIGHTS)
  List<UserRights> userRights;

  /// Can be used to group measurements and characteristics from a functional point of view (a2l key: FUNCTION)
  List<CFunction> functions;

  /// Describes axis data of curves if they are stored at different locations. (a2l key: AXIS_PTS)
  List<AxisPoints> axisPoints;

  /// The A2ML description (if present). The library will not process these strings in any way. (a2l key: A2ML)
  List<String> a2ml;

  /// The interface description (if present). The library will not process these strings in any way.  (a2l key: IFDATA)
  List<String> interfaceData;

  Module()
      : measurements = [],
        characteristics = [],
        units = [],
        computeMethods = [],
        computeTables = [],
        groups = [],
        recordLayouts = [],
        frames = [],
        userRights = [],
        functions = [],
        axisPoints = [],
        a2ml = [],
        interfaceData = [];

  @override
  String toString() {
    var rv = 'Module "$name"\n$description\n\n';
    rv += 'Measurements: ${measurements.length}\n';
    rv += 'Characteristics: ${characteristics.length}\n';
    rv += 'Units: ${units.length}\n';
    rv += 'Compute Methods: ${computeMethods.length}\n';
    rv += 'Compute Tables: ${computeTables.length}\n';
    rv += 'Groups: ${groups.length}\n';
    rv += 'Record layouts: ${recordLayouts.length}\n';
    rv += 'Frames: ${frames.length}\n';
    rv += 'User rights: ${userRights.length}\n';
    rv += 'Functions: ${functions.length}\n';
    return rv;
  }

  /// Converts the module to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin MODULE $name', depth);
    rv += indent('"$description"\n\n', depth + 1);

    rv += writeListOfBlocks( depth + 1, 'A2ML', a2ml);
    rv += writeListOfBlocks( depth + 1, 'IF_DATA', interfaceData);

    if (common != null) {
      rv += common!.toFileContents(depth + 1);
    }
    if (parameters != null) {
      rv += parameters!.toFileContents(depth + 1);
    }
    for (final rl in recordLayouts) {
      rv += rl.toFileContents(depth + 1);
    }
    for (final c in computeMethods) {
      rv += c.toFileContents(depth + 1);
    }
    for (final t in computeTables) {
      rv += t.toFileContents(depth + 1);
    }
    for (final c in characteristics) {
      rv += c.toFileContents(depth + 1);
    }
    for (final a in axisPoints) {
      rv += a.toFileContents(depth + 1);
    }
    for (final m in measurements) {
      rv += m.toFileContents(depth + 1);
    }
    for (final u in units) {
      rv += u.toFileContents(depth + 1);
    }
    for (final g in groups) {
      rv += g.toFileContents(depth + 1);
    }
    for (final f in functions) {
      rv += f.toFileContents(depth + 1);
    }
    for (final f in frames) {
      rv += f.toFileContents(depth + 1);
    }
    for (final r in userRights) {
      rv += r.toFileContents(depth + 1);
    }
    if (coding != null) {
      rv += coding!.toFileContents(depth + 1);
    }
    rv += indent('/end MODULE\n\n', depth);
    return rv;
  }
}
