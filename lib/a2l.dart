/// This library supports reading and writing ASAM MCD-2MC files (A2L files) in versions 1.5 and 1.6.
/// The ASAM MCD-2MC standard is an automotive standard that is used to describe the memory layout
/// of embedded systems. In combination with a calibration protocol (for example the Universal Measurement and Calibration Protocol XCP - Standard ASAM MCD-1 XCP)
/// and a calibration system an embedded system can be calibrated in-situ in a vehicle/drone/robot.
/// 
/// The library provides an abstract syntax tree that describes an ECU according to the A2L format called
/// [A2LFile]. It can be read from a file in the file system with the following method [parseA2lFileSync()]:
/// ```dart
///   var file = parseA2lFileSync(path);
/// ```
/// Converting the file back to an A2L representation can also be done via a single method call:
/// ```dart
///   var output = file.toFileContents();
/// ```
/// Both of these methods may throw exceptions if errors occur. This may happen during parsing
/// for a wrong syntax in the file. Another possibility is that while creating the output some
/// requirements to create a correct A2L file were not met (e.g. illegal combinations of options).
library a2l;


export 'package:a2l/src/a2l_parser.dart';
export 'package:a2l/src/preprocessor.dart';
export 'package:a2l/src/file_parser.dart';

export 'package:a2l/src/a2l_tree/a2l_file.dart';
export 'package:a2l/src/a2l_tree/annotation.dart';
export 'package:a2l/src/a2l_tree/axis_descr.dart';
export 'package:a2l/src/a2l_tree/axis_pts.dart';
export 'package:a2l/src/a2l_tree/base_types.dart';
export 'package:a2l/src/a2l_tree/calibration_method.dart';
export 'package:a2l/src/a2l_tree/characteristic.dart';
export 'package:a2l/src/a2l_tree/compute_method.dart';
export 'package:a2l/src/a2l_tree/compute_table.dart';
export 'package:a2l/src/a2l_tree/formula.dart';
export 'package:a2l/src/a2l_tree/frame.dart';
export 'package:a2l/src/a2l_tree/function.dart';
export 'package:a2l/src/a2l_tree/group.dart';
export 'package:a2l/src/a2l_tree/measurement.dart';
export 'package:a2l/src/a2l_tree/memory_layout.dart';
export 'package:a2l/src/a2l_tree/memory_segment.dart';
export 'package:a2l/src/a2l_tree/module_common.dart';
export 'package:a2l/src/a2l_tree/module_parameters.dart';
export 'package:a2l/src/a2l_tree/module.dart';
export 'package:a2l/src/a2l_tree/project.dart';
export 'package:a2l/src/a2l_tree/record_layout.dart';
export 'package:a2l/src/a2l_tree/unit.dart';
export 'package:a2l/src/a2l_tree/variant_coding.dart';
