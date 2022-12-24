# A2L file handling library
[![Dart](https://github.com/domohuhn/a2l/actions/workflows/dart.yml/badge.svg)](https://github.com/domohuhn/a2l/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/domohuhn/a2l/branch/main/graph/badge.svg?token=YSTK1T7ZTQ)](https://codecov.io/gh/domohuhn/a2l)
## Introduction
A library for Dart developers to handle [ASAM MCD-2MC](https://www.asam.net/standards/detail/mcd-2-mc/) (ASAP2 or A2L) files.
The file format is mostly used in the automotive industry for the development of electronic control units.
It defines the memory layout of an embedded system, so that internal variables can be read and modified via 
a calibration and measurement system in-situ. For example, it can be used to change the engine response curve 
when the accelerator pedal is pressed. The calibration can be done via different bus systems, e.g. CAN, Ethernet, USB... 
because the calibration mechanism is agnostic of the actual transport protocol used.

A common transport layer used for the calibrations is the [XCP protocol](https://en.wikipedia.org/wiki/XCP_(protocol)), which can be used
with most bus system that are present on modern vehicles.

## Usage

A simple usage example to parse a given A2L file to an AST tree:

```dart
import 'package:a2l/a2l.dart';

main() {
  var file = parseA2lFileSync('path/to/file.a2l');
}
```


## File format

The ASAP2 or A2L files are similar to XML files, but the syntax is different. The file format was specified before XML was standardized and the standardization body never felt the need to update the ASAP2 specification.
A very basic file looks like this:
```
/* 
This is a simple a2l file.
This is a multiline comment.                            
*/
// This is a single line comment

// required for every valid file - a named value with major and minor version.
ASAP2_VERSION 1 61

// a block element
/begin PROJECT DH.XCP.SIMPLE /* name of the project */
  "Simple Project" /* description of the project */

  /begin MODULE DH.XCP.SIM /* name of the module */
    "XCP Simulation module"  /* description of the module */
  /end MODULE
/end PROJECT
```

The file format uses different ways to define data:
 - named values followed by mandatory values (numbers, strings and identifiers)
 - named flags without arguments (e.g. READ_ONLY)
 - blocks started via "/begin XXX" followed by mandatory values, followed by optional values identified via names
 - a block must be closed with a matching "/end XXX" statement

Named values are usually optional, while the unamed values are required. A valid file must contain one of "ASAP2_VERSION", a "PROJECT" block with at least one "MODULE". The module contains the relevant data for an ECU.
The most important blocks inside the module are "CHARACTERISTIC", which describes calibration values/parameters, "MEASUREMENT", "RECORD_LAYOUT" and "COMPU_METHOD" describgin how to convert the internal ECU data to phsyical values.

See the contents of the data directory in this repository for more examples.

## Features and bugs

The library can read ASAP2 files conforming to the standards 1.5 and 1.6, and can write files for standard 1.6.
However, currently there are some keywords that are only partially supported: A2ML, IF_DATA and FORMULA. The first two use the standardized ASAM MCD-2MC metalanguage
which descirbes the interface specific data. During parsing, these block are simple passed through into the
resulting data structure as strings.
Formulas are currently also not parsed and instead stay as string. See also [the supported keywords page.](SupportedKeywords.md)

Please file feature requests and bugs at the [issue tracker](https://github.com/domohuhn/a2l/issues).




