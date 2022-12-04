import 'package:a2l/src/a2l_tree/axis_descr.dart';
import 'package:a2l/src/a2l_tree/axis_pts.dart';
import 'package:a2l/src/a2l_tree/calibration_method.dart';
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';
import 'package:a2l/src/a2l_tree/formula.dart';
import 'package:a2l/src/a2l_tree/frame.dart';
import 'package:a2l/src/a2l_tree/function.dart';
import 'package:a2l/src/a2l_tree/group.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/measurement.dart';
import 'package:a2l/src/a2l_tree/memory_layout.dart';
import 'package:a2l/src/a2l_tree/memory_segment.dart';
import 'package:a2l/src/a2l_tree/project.dart';
import 'package:a2l/src/a2l_tree/module.dart';
import 'package:a2l/src/a2l_tree/module_common.dart';
import 'package:a2l/src/a2l_tree/module_parameters.dart';
import 'package:a2l/src/a2l_tree/record_layout.dart';
import 'package:a2l/src/a2l_tree/unit.dart';
import 'package:a2l/src/a2l_tree/user_rights.dart';
import 'package:a2l/src/a2l_tree/variant_coding.dart';

import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/utility.dart';
import 'package:a2l/src/a2l_tree/a2l_file.dart';
import 'package:a2l/src/token.dart';
import 'dart:collection';

enum ValueType { flag, id, text, integer, floating }

class A2LElement {
  String name;
  bool optional;
  bool unique;
  int count = 0;
  A2LElement(this.name, this.optional, {this.unique = true});
}

class Value extends A2LElement {
  ValueType type;
  bool _valueSet = false;
  List<Token> _value;

  /// how many times a value should be read. Set this to -1 to read all remaining values.
  int multiplicity;

  /// in case multiplicity ist set to a negative value, this value determines at what tokens we stop
  List<String> stopAt;

  /// how many String tokens are needed to initialize this value.
  /// Set to negative value to read all remaining tokens.
  final int _requiredTokens;

  final void Function(ValueType, List<Token>) _callback;

  Value(String name, this.type, this._callback, {this.multiplicity = 1, int requiredTokens = 1, this.stopAt = const []})
      : _value = [],
        _requiredTokens = requiredTokens,
        super(name, false) {
    if (_requiredTokens==0) {
      throw ValidationError('A value must read at least one token! "$name" was constructed with $_requiredTokens required tokens!');
    }
  }

  set value(List<Token> values) {
    for (final val in values) {
      if (val.text == '/begin' || val.text == '/end') {
        throw ParsingException('Syntax error: a value cannot be a reserved keyword.', val);
      }
    }
    if (_requiredTokens> 0 && values.length != _requiredTokens) {
      throw ParsingException('A value of type "$name" requires exactly $_requiredTokens, but received ${values.length}', values[0]);
    }
    _valueSet = true;
    _value = values;
    _callback(type, _value);
  }

  bool get valueSet => _valueSet;

  List<Token> get value => _value;

  /// Gets the required token stride for this value.
  /// [maxCount] is the max count of tokens that can be read.
  int stride(int maxCount) {
    if (_requiredTokens<0) {
      return maxCount;
    }
    return _requiredTokens;
  }

  @override
  String toString() {
    return '$type ("$name")';
  }
}

/// Empty function, needed as default argument for the callbacks.
void doNothing() {}

/// This class represent a named value inside the A2L file.
/// The are typcially entered as KEY value0 value1 ...
///
class NamedValue extends A2LElement {
  /// The mandatory values required after the key word.
  List<Value> values;

  /// The callback to invoke when the key is found inside the file.
  final void Function() _callback;

  /// Constructor for named values.
  /// [name] is the key in the file.
  /// [values] are the mandatory values after the key.
  /// [optional] determines if the key is required. Parsing will throw an exception if [optional] is false and the key was not found.
  /// [unique] determines if the key can occur more than once. Parsing will throw an exception if [unique] is false and the key was found more than once.
  /// [callback] is invoked whenever the key is found.
  NamedValue(String name, this.values, {bool optional = false, bool unique = true, void Function() callback = doNothing})
      : _callback = callback,
        super(name, optional, unique: unique);

  /// This method is invoked whenever the NamedValue key is found in the A2L file.
  void keyFound() {
    _callback();
  }
}

class A2LElementParsingOptions {
  dynamic current;
  List<Value> mandatoryPositional;
  List<A2LElement> named;

  A2LElementParsingOptions(this.current, this.mandatoryPositional, this.named);
}

class BlockElement extends A2LElement {
  List<Value> values;
  List<NamedValue> namedValues;
  List<BlockElement> children;
  BlockElement(String name, this._callback,
      {this.values = const [], this.namedValues = const [], this.children = const [], bool optional = false, bool unique = true})
      : super(name, optional, unique: unique);

  final A2LElementParsingOptions Function(dynamic self, dynamic parent) _callback;

  A2LElementParsingOptions prepareNewLement(dynamic parent) {
    return _callback(this, parent);
  }
}

class EntryData {
  String name;

  EntryData(this.name);
}

/// The TokenParser converts the preprocessed tokens to the A2L File data structure.
class TokenParser {
  List<Token> tokens = [];
  List<bool> usedTokens = [];
  int currentIndex = 0;
  String currentToken = '';
  List<A2LElement> expectedTokens = [];

  var stack = Queue<List<A2LElement>>();

  A2LFile parsed = A2LFile();

  TokenParser();

  A2LFile parse() {
    setTopLevelTokens();
    usedTokens = List<bool>.generate(3, (int index) => false, growable: false);
    _parseRecursive(parsed, 0, tokens.length);
    return parsed;
  }

  void _parseRecursive(dynamic current, int start, int end) {
    for (var i = start; i < end; ++i) {
      currentIndex = i;
      if (tokens[i].text == '/begin') {
        var limit = findMatchingEndToken();
        var expected = findExpected(tokens[i + 1].text);
        if (expected != null) {
          if (expected is BlockElement) {
            currentIndex = i + 2;
            stack.add(expectedTokens);
            var opts = expected.prepareNewLement(current);
            parseRequiredOrderedElements(opts.mandatoryPositional, limit);
            expectedTokens = [];
            expectedTokens.addAll(opts.named);
            _parseRecursive(opts.current, currentIndex, limit);
            expectedTokens = stack.last;
            stack.removeLast();
            expected.count += 1;
          } else {
            throw ParsingException('Element "${expected.name}" is not a block element!', tokens[i]);
          }
        }
        i = limit + 1;
        continue;
      }
      for (final token in expectedTokens) {
        if (token.name != tokens[i].text) {
          continue;
        }
        if (token is NamedValue) {
          currentIndex = i + 1;
          token.keyFound();
          parseRequiredOrderedElements(token.values, end);
          token.count += 1;
          i += token.values.length;
          continue;
        }
      }
    }
    for (final token in expectedTokens) {
      if (!token.optional && token.count == 0) {
        throw ParsingException('Mandatory element "${token.name}" was not found', tokens[currentIndex]);
      }
      if (token.unique && token.count > 1) {
        throw ParsingException('${token.name} can only occur once! Found ${token.count}', tokens[currentIndex]);
      }
    }
  }

  A2LElement? findExpected(String nm) {
    for (final token in expectedTokens) {
      if (token.name == nm) {
        return token;
      }
    }
    return null;
  }

  /// [max] is one past the end.
  void parseRequiredOrderedElements(List<Value> values, int max) {
    if (values.length + currentIndex > max) {
      throw ParsingException(
          'Token "$currentToken" has at least ${values.length} mandatory values! Only found ${max - currentIndex}', tokens[currentIndex]);
    }

    for (var k = 0; k < values.length; k++) {
      if (values[k].multiplicity >= 0) {
        _parseSingleValue(values, max, k);
      } else if (values[k].stopAt.isEmpty) {
        _parseRemainingTokens(values, max, k, checkIndex: true);
        break;
      } else {
        var end = findNextBegin(max, values[k].stopAt);
        _parseRemainingTokens(values, end, k, checkIndex: false);
      }
    }
  }

  void _parseRemainingTokens(List<Value> values, int max, int k, {bool checkIndex = true}) {
    if (checkIndex && k != values.length - 1) {
      throw ParsingException(
          'Value ${values[k]} at $k (of ${values.length}) requested all remaining tokens! Some values could not be processed',
          tokens[currentIndex]);
    }

    var remaining = max - currentIndex;
    var stride = values[k].stride(remaining);
    try {
      while (currentIndex + stride <= max) {
        values[k].value = tokens.sublist(currentIndex, currentIndex + stride);
        currentIndex += stride;
        remaining = max - currentIndex;
        stride = values[k].stride(remaining);
      }
    } catch (ex) {
      throw ParsingException('${tokens[currentIndex]} could not be converted to ${values[k]}', tokens[currentIndex]);
    }

    if (currentIndex != max) {
      throw ParsingException('Not all tokens could be processed! Target $max, stride $stride, ended at $currentIndex',
          tokens[currentIndex]);
    }
  }

  void _parseSingleValue(List<Value> values, int max, int k) {
    for (var i = 0; i < values[k].multiplicity; ++i) {
      final remaining = max - currentIndex;
      final stride = values[k].stride(remaining);
      if (currentIndex + stride > max) {
        throw ParsingException(
            'Not enough tokens! Target $max, stride $stride, multiplicity ${values[k].multiplicity}, ended at iteration $i, token $currentIndex',
            tokens[currentIndex]);
      }
      try {
        values[k].value = tokens.sublist(currentIndex, currentIndex + stride);
      } catch (ex) {
        throw ParsingException('${tokens[currentIndex]} could not be converted to ${values[k]}:\n$ex', tokens[currentIndex]);
      }
      currentIndex += stride;
    }
  }

  int findNextBegin(int max, List<String> stopTokens) {
    var rv = max;
    for (var k = currentIndex; k < max; ++k) {
      for (final t in stopTokens) {
        if (tokens[k].text == t) {
          return k;
        }
      }
    }
    return rv;
  }

  int findMatchingEndToken() {
    var beginCount = 0;
    var name = tokens[currentIndex + 1].text;
    for (var k = currentIndex; k < tokens.length; ++k) {
      if (tokens[k].text == '/begin') {
        beginCount += 1;
      }
      if (tokens[k].text == '/end') {
        beginCount -= 1;
      }
      if (beginCount == 0) {
        if (tokens[k + 1].text != name) {
          throw ParsingException('Expected /end $name, got /end ${tokens[k + 1].text} at ${tokens[k + 1]}', tokens[currentIndex]);
        }
        return k;
      }
    }
    throw ParsingException('Missing /end $name', tokens[currentIndex]);
  }

  void setTopLevelTokens() {
    parsed = A2LFile();
    var asap2VersionValues = <Value>[
      Value('VersionNo', ValueType.integer, (ValueType t, List<Token> s) {
        parsed.a2lMajorVersion = int.parse(s[0].text);
      }),
      Value('UpgradeNo', ValueType.integer, (ValueType t, List<Token> s) {
        parsed.a2lMinorVersion = int.parse(s[0].text);
      })
    ];
    var asap2MLVersionValues = <Value>[
      Value('VersionNo', ValueType.integer, (ValueType t, List<Token> s) {
        parsed.a2mlMajorVersion = int.parse(s[0].text);
      }),
      Value('UpgradeNo', ValueType.integer, (ValueType t, List<Token> s) {
        parsed.a2mlMinorVersion = int.parse(s[0].text);
      })
    ];

    var projectValues = <Value>[
      Value('Name', ValueType.id, (ValueType t, List<Token> s) {
        parsed.project.name = s[0].text;
      }),
      Value('LongIdentifier', ValueType.integer, (ValueType t, List<Token> s) {
        parsed.project.description = removeQuotes(s[0].text);
      })
    ];

    var project = BlockElement('PROJECT', (s, p) {
      return A2LElementParsingOptions(p, s.values, s.children);
    }, values: projectValues, children: createProjectChildren());

    expectedTokens = [
      NamedValue('ASAP2_VERSION', asap2VersionValues),
      NamedValue('A2ML_VERSION', asap2MLVersionValues, optional: true),
      project
    ];
  }

  List<BlockElement> createProjectChildren() {
    var header = BlockElement('HEADER', (s, p) {
      return A2LElementParsingOptions(p, s.values, s.namedValues);
    }, values: [
      Value('Comment', ValueType.text, (ValueType t, List<Token> s) {
        parsed.project.header ??= Header();
        parsed.project.header!.description = removeQuotes(s[0].text);
      })
    ], namedValues: [
      NamedValue(
          'VERSION',
          [
            Value('version number', ValueType.text, (ValueType t, List<Token> s) {
              parsed.project.header!.version = removeQuotes(s[0].text);
            })
          ],
          optional: true),
      NamedValue(
          'PROJECT_NO',
          [
            Value('project number', ValueType.text, (ValueType t, List<Token> s) {
              parsed.project.header!.number = s[0].text;
            })
          ],
          optional: true),
    ], optional: true);

    var module = BlockElement('MODULE', (s, p) {
      var module = Module();
      p.project.modules.add(module);
      var values = [
        Value('Name', ValueType.id, (ValueType t, List<Token> s) {
          module.name = s[0].text;
        }),
        Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
          module.description = removeQuotes(s[0].text);
        })
      ];
      return A2LElementParsingOptions(module, values, createModuleChildren());
    }, optional: false, unique: false);

    return [header, module];
  }

  List<BlockElement> createModuleChildren() {
    return [
      _createA2MLParser(),
      _createInterfaceDataParser(),
      _createUnit(),
      _createMeasurement(),
      _createCharacteristic(),
      _createComputeMethod(),
      _createComputeTable(),
      _createComputeVerbatimTable(),
      _createComputeVerbatimRangeTable(),
      _createGroups(),
      _createRecordLayout(),
      _createModuleCommon(),
      _createModuleParameters(),
      _createFrames(),
      _createUserRights(),
      _createVariantCoding(),
      _createFunction(),
      _createAxisPoints()
    ];
  }
  
  BlockElement _createA2MLParser() {
    return BlockElement('A2ML', (s, p) {
      if (p is Module) {
        return A2LElementParsingOptions(p, [Value('A2ML', ValueType.text, (type, tokens) {
          String txt = '';
          for(final t in tokens) {
            txt += t.text;
          }
          p.a2ml.add(txt);
        }, requiredTokens: -1)], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of AXIS_PTS must be a module!');
      }

    }, optional: true, unique: false);
  }

  BlockElement _createInterfaceDataParser() {
    return BlockElement('IF_DATA', (s, p) {
      return A2LElementParsingOptions(p, [Value('IF_DATA', ValueType.text, (type, tokens) {
        String txt = '';
        for(final t in tokens) {
          txt += t.text;
        }
        p.interfaceData.add(txt);
      }, requiredTokens: -1)], []);
    }, optional: true, unique: false);
  }

  BlockElement _createAxisPoints() {
    return BlockElement('AXIS_PTS', (s, p) {
      if (p is Module) {
        var axis = AxisPoints();
        p.axisPoints.add(axis);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            axis.name = s[0].text;
          }),
          Value('Description', ValueType.text, (ValueType t, List<Token> s) {
            axis.description = removeQuotes(s[0].text);
          }),
          Value('address', ValueType.integer, (ValueType t, List<Token> s) {
            axis.address = int.parse(s[0].text);
          }),
          Value('InputQuantity', ValueType.id, (ValueType t, List<Token> s) {
            axis.inputQuantity = s[0].text;
          }),
          Value('Deposit', ValueType.id, (ValueType t, List<Token> s) {
            axis.recordLayout = s[0].text;
          }),
          Value('MaxDiff', ValueType.floating, (ValueType t, List<Token> s) {
            axis.maxDifferenceFromTable = double.parse(s[0].text);
          }),
          Value('Conversion', ValueType.id, (ValueType t, List<Token> s) {
            axis.conversionMethod = s[0].text;
          }),
          Value('MaxAxisPoints', ValueType.integer, (ValueType t, List<Token> s) {
            axis.maxAxisPoints = int.parse(s[0].text);
          }),
          Value('LowerLimit', ValueType.floating, (ValueType t, List<Token> s) {
            axis.lowerLimit = double.parse(s[0].text);
          }),
          Value('UpperLimit', ValueType.floating, (ValueType t, List<Token> s) {
            axis.upperLimit = double.parse(s[0].text);
          }),
        ];

        var optional = <A2LElement>[
          _createAnnotation(),
          _createFunctionList(),
          _createInterfaceDataParser(),
          NamedValue('READ_ONLY', [], callback: () {
            axis.readWrite = false;
          }, optional: true),
          NamedValue('GUARD_RAILS', [], callback: () {
            axis.guardRails = true;
          }, optional: true),
          NamedValue(
              'STEP_SIZE',
              [
                Value('Step size', ValueType.floating, (p0, p1) {
                  axis.stepSize = double.parse(p1[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'CALIBRATION_ACCESS',
              [
                Value('CALIBRATION_ACCESS', ValueType.text, (p0, p1) {
                  axis.calibrationAccess = calibrationAccessFromString(p1[0]);
                })
              ],
              optional: true),
          NamedValue(
              'EXTENDED_LIMITS',
              [
                Value('EXTENDED_LIMITS', ValueType.floating, (p0, p1) {
                  axis.extendedLimits ??= ExtendedLimits();
                  axis.extendedLimits!.lowerLimit = double.parse(p1[0].text);
                  axis.extendedLimits!.upperLimit = double.parse(p1[1].text);
                }, requiredTokens: 2)
              ],
              optional: true),
          NamedValue(
              'BYTE_ORDER',
              [
                Value('order', ValueType.text, (ValueType t, List<Token> s) {
                  axis.endianess = byteOrderFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'DISPLAY_IDENTIFIER',
              [
                Value('id', ValueType.text, (ValueType t, List<Token> s) {
                  axis.displayIdentifier = s[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'ECU_ADDRESS_EXTENSION',
              [
                Value('address extension', ValueType.integer, (ValueType t, List<Token> s) {
                  axis.addressExtension = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'FORMAT',
              [
                Value('format', ValueType.text, (ValueType t, List<Token> s) {
                  axis.format = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'PHYS_UNIT',
              [
                Value('unit', ValueType.text, (ValueType t, List<Token> s) {
                  axis.unit = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'REF_MEMORY_SEGMENT',
              [
                Value('segment', ValueType.text, (ValueType t, List<Token> s) {
                  axis.memorySegment = s[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'DEPOSIT',
              [
                Value('depositMode', ValueType.text, (ValueType t, List<Token> s) {
                  axis.depositMode = depositFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'MONOTONY',
              [
                Value('monotony', ValueType.text, (ValueType t, List<Token> s) {
                  axis.monotony = monotonyFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'SYMBOL_LINK',
              [
                Value('SymbolName', ValueType.text, (ValueType t, List<Token> s) {
                  axis.symbolLink ??= SymbolLink();
                  axis.symbolLink!.name = removeQuotes(s[0].text);
                }),
                Value('Offset', ValueType.integer, (ValueType t, List<Token> s) {
                  axis.symbolLink!.offset = int.parse(s[0].text);
                }),
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(axis, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of AXIS_PTS must be a module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createAxisDescription() {
    return BlockElement('AXIS_DESCR', (s, p) {
      if (p is Characteristic) {
        var axis = AxisDescription();
        p.axisDescription.add(axis);

        var values = [
          Value('Attribute', ValueType.text, (ValueType t, List<Token> s) {
            axis.type = axisTypeFromString(s[0]);
          }),
          Value('InputQuantity', ValueType.id, (ValueType t, List<Token> s) {
            axis.inputQuantity = s[0].text;
          }),
          Value('Conversion', ValueType.id, (ValueType t, List<Token> s) {
            axis.conversionMethod = s[0].text;
          }),
          Value('MaxAxisPoints', ValueType.integer, (ValueType t, List<Token> s) {
            axis.maxAxisPoints = int.parse(s[0].text);
          }),
          Value('LowerLimit', ValueType.floating, (ValueType t, List<Token> s) {
            axis.lowerLimit = double.parse(s[0].text);
          }),
          Value('UpperLimit', ValueType.floating, (ValueType t, List<Token> s) {
            axis.upperLimit = double.parse(s[0].text);
          }),
        ];

        var optional = <A2LElement>[
          _createAnnotation(),
          NamedValue('READ_ONLY', [], callback: () {
            axis.readWrite = false;
          }, optional: true),
          NamedValue(
              'STEP_SIZE',
              [
                Value('Step size', ValueType.floating, (p0, p1) {
                  axis.stepSize = double.parse(p1[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'AXIS_PTS_REF',
              [
                Value('axis_pts reference', ValueType.id, (p0, p1) {
                  axis.axisPoints = p1[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'CURVE_AXIS_REF',
              [
                Value('axis_pts reference', ValueType.id, (p0, p1) {
                  axis.rescaleAxisPoints = p1[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'MAX_GRAD',
              [
                Value('max gradient', ValueType.floating, (p0, p1) {
                  axis.maxGradient = double.parse(p1[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'FIX_AXIS_PAR',
              [
                Value('offset, shift, number', ValueType.integer, (p0, p1) {
                  axis.fixedAxisPoints1 ??= FixedAxisPoints();
                  axis.fixedAxisPoints1!.p0 = int.parse(p1[0].text);
                  axis.fixedAxisPoints1!.p1 = 1 << int.parse(p1[1].text);
                  axis.fixedAxisPoints1!.max = int.parse(p1[2].text);
                }, requiredTokens: 3)
              ],
              optional: true),
          NamedValue(
              'FIX_AXIS_PAR_DIST',
              [
                Value('offset, distance, number', ValueType.integer, (p0, p1) {
                  axis.fixedAxisPoints2 ??= FixedAxisPoints();
                  axis.fixedAxisPoints2!.p0 = int.parse(p1[0].text);
                  axis.fixedAxisPoints2!.p1 = int.parse(p1[1].text);
                  axis.fixedAxisPoints2!.max = int.parse(p1[2].text);
                }, requiredTokens: 3)
              ],
              optional: true),
          BlockElement('FIX_AXIS_PAR_LIST', (s, p2) {
            if (p2 is AxisDescription) {
              return A2LElementParsingOptions(p2, [
                Value('AxisPts_Value', ValueType.floating, (p0, p1) {
                  axis.ecuAxisPoints.add(double.parse(p1[0].text));
                }, multiplicity: -1)
              ], []);
            } else {
              throw ValidationError('Parse tree built wrong, parent of FIX_AXIS_PAR_LIST must be an AxisDescription!');
            }
          }, optional: true),
          NamedValue(
              'EXTENDED_LIMITS',
              [
                Value('EXTENDED_LIMITS', ValueType.floating, (p0, p1) {
                  axis.extendedLimits ??= ExtendedLimits();
                  axis.extendedLimits!.lowerLimit = double.parse(p1[0].text);
                  axis.extendedLimits!.upperLimit = double.parse(p1[1].text);
                }, requiredTokens: 2)
              ],
              optional: true),
          NamedValue(
              'BYTE_ORDER',
              [
                Value('order', ValueType.text, (ValueType t, List<Token> s) {
                  axis.endianess = byteOrderFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'FORMAT',
              [
                Value('format', ValueType.text, (ValueType t, List<Token> s) {
                  axis.format = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'PHYS_UNIT',
              [
                Value('unit', ValueType.text, (ValueType t, List<Token> s) {
                  axis.unit = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'DEPOSIT',
              [
                Value('depositMode', ValueType.text, (ValueType t, List<Token> s) {
                  axis.depositMode = depositFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'MONOTONY',
              [
                Value('monotony', ValueType.text, (ValueType t, List<Token> s) {
                  axis.monotony = monotonyFromString(s[0]);
                })
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(axis, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of AXIS_DESCR must be a characteristic!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createFunction() {
    return BlockElement('FUNCTION', (s, p) {
      if (p is Module) {
        var fun = CFunction();
        p.functions.add(fun);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            fun.name = s[0].text;
          }),
          Value('Description', ValueType.text, (ValueType t, List<Token> s) {
            fun.description = removeQuotes(s[0].text);
          }),
        ];

        var optional = <A2LElement>[
          NamedValue(
              'FUNCTION_VERSION',
              [
                Value('version', ValueType.text, (p0, p1) {
                  fun.version = removeQuotes(p1[0].text);
                })
              ],
              optional: true),
          _createAnnotation(),
          _createInterfaceDataParser(),
          _createCharacteristicsList(),
          _createCharacteristicsList(key: 'DEF_CHARACTERISTIC', cb: (a) => a.definedCharacteristics),
          _createFunctionList(key: 'SUB_FUNCTION'),
          _createMeasurementsList(key: 'IN_MEASUREMENT', cb: (a) => a.inputMeasurements),
          _createMeasurementsList(key: 'LOC_MEASUREMENT'),
          _createMeasurementsList(key: 'OUT_MEASUREMENT', cb: (a) => a.outputMeasurements),
        ];
        return A2LElementParsingOptions(fun, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of VARIANT_CODING must be a module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createVariantCoding() {
    return BlockElement('VARIANT_CODING', (s, p) {
      if (p is Module) {
        var cod = VariantCoding();
        p.coding ??= cod;
        var optional = <A2LElement>[
          NamedValue(
              'VAR_SEPARATOR',
              [
                Value('separator', ValueType.text, (p0, p1) {
                  cod.separator = removeQuotes(p1[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'VAR_NAMING',
              [
                Value('NamingScheme', ValueType.text, (p0, p1) {
                  cod.namingScheme = variantNamingFromString(p1[0]);
                })
              ],
              optional: true),
          _createVariantEnumeration(),
          _createForbiddenCombination(),
          _createVariantCharacteristic()
        ];
        return A2LElementParsingOptions(cod, [], optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of VARIANT_CODING must be a module!');
      }
    }, optional: true);
  }

  BlockElement _createVariantEnumeration() {
    return BlockElement('VAR_CRITERION', (s, p) {
      if (p is VariantCoding) {
        var enu = VariantEnumeration();
        p.enumerations.add(enu);
        var values = <Value>[
          Value('name', ValueType.id, (p0, p1) {
            enu.name = p1[0].text;
          }),
          Value('description', ValueType.text, (p0, p1) {
            enu.description = removeQuotes(p1[0].text);
          }),
          Value('value', ValueType.text, (p0, p1) {
            enu.values.add(p1[0].text);
          }, multiplicity: -1, stopAt: ['VAR_MEASUREMENT', 'VAR_SELECTION_CHARACTERISTIC'])
        ];
        var optional = <A2LElement>[
          NamedValue(
              'VAR_MEASUREMENT',
              [
                Value('measurement', ValueType.id, (p0, p1) {
                  enu.measurement = p1[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'VAR_SELECTION_CHARACTERISTIC',
              [
                Value('characteristic', ValueType.id, (p0, p1) {
                  enu.characteristic = p1[0].text;
                })
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(enu, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of VAR_CRITERION must be a VariantCoding!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createForbiddenCombination() {
    return BlockElement('VAR_FORBIDDEN_COMB', (s, p) {
      if (p is VariantCoding) {
        var forb = ForbiddenCombination();
        p.forbidden.add(forb);
        var values = <Value>[
          Value('value', ValueType.text, (p0, p1) {
            forb.comibination.add(NameValuePair(p1[0].text, p1[1].text));
          }, multiplicity: -1, requiredTokens: 2)
        ];
        return A2LElementParsingOptions(forb, values, []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of VAR_FORBIDDEN_COMB must be a VariantCoding!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createVariantCharacteristic() {
    return BlockElement('VAR_CHARACTERISTIC', (s, p) {
      if (p is VariantCoding) {
        var ch = VariantCharacteristic();
        p.characteristics.add(ch);
        var values = <Value>[
          Value('name', ValueType.id, (p0, p1) {
            ch.name = p1[0].text;
          }),
          Value('enumerations', ValueType.id, (p0, p1) {
            ch.enumerations.add(p1[0].text);
          }, multiplicity: -1, stopAt: ['/begin'])
        ];
        var optional = <A2LElement>[
          BlockElement('VAR_ADDRESS', (s, p2) {
            if (p2 is VariantCharacteristic) {
              return A2LElementParsingOptions(p2, [
                Value('address', ValueType.integer, (p0, p1) {
                  ch.address.add(int.parse(p1[0].text));
                }, multiplicity: -1)
              ], []);
            } else {
              throw ValidationError('Parse tree built wrong, parent of VAR_ADDRESS must be a VariantCharacteristic!');
            }
          }, optional: true)
        ];
        return A2LElementParsingOptions(ch, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of VAR_CHARACTERISTIC must be a VariantCoding!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createUserRights() {
    return BlockElement('USER_RIGHTS', (s, p) {
      if (p is Module) {
        var ur = UserRights();
        p.userRights.add(ur);
        var values = [
          Value('UserLevelId', ValueType.id, (ValueType t, List<Token> s) {
            ur.userId = s[0].text;
          })
        ];
        var optional = <A2LElement>[
          NamedValue('READ_ONLY', [], callback: () => ur.readOnly = true, optional: true),
          BlockElement('REF_GROUP', (s, p2) {
            if (p2 is UserRights) {
              return A2LElementParsingOptions(p2, [
                Value('Group id', ValueType.text, (ValueType t, List<Token> s) {
                  p2.groups.add(s[0].text);
                }, multiplicity: -1)
              ], []);
            } else {
              throw ValidationError('Parse tree built wrong, parent of REF_GROUP must be a USER_RIGHTS!');
            }
          }, optional: true),
        ];
        return A2LElementParsingOptions(ur, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of USER_RIGHTS must be a module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createFrames() {
    return BlockElement('FRAME', (s, p) {
      if (p is Module) {
        var frame = Frame();
        p.frames.add(frame);
        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            frame.name = s[0].text;
          }),
          Value('Description', ValueType.text, (ValueType t, List<Token> s) {
            frame.description = removeQuotes(s[0].text);
          }),
          Value('ScalingUnit', ValueType.integer, (ValueType t, List<Token> s) {
            frame.scalingUnit = maxRefreshUnitFromString(s[0]);
          }),
          Value('Rate', ValueType.integer, (ValueType t, List<Token> s) {
            frame.rate = int.parse(s[0].text);
          }),
        ];
        var optional = <A2LElement>[
          NamedValue(
              'FRAME_MEASUREMENT',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  frame.measurements.add(s[0].text);
                }, multiplicity: -1, stopAt: ['/begin'])
              ],
              optional: true),
          _createInterfaceDataParser()
        ];
        return A2LElementParsingOptions(frame, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of FRAME must be a module!');
      }
    },
        optional: true,
        // maybe this should be unique? - standard is not clear.
        unique: false);
  }

  BlockElement _createModuleCommon() {
    return BlockElement('MOD_COMMON', (s, p) {
      if (p is Module) {
        var common = ModuleCommon();
        p.common = common;
        var values = [
          Value('Description', ValueType.id, (ValueType t, List<Token> s) {
            common.description = removeQuotes(s[0].text);
          })
        ];

        var optional = <A2LElement>[
          NamedValue(
              'ALIGNMENT_BYTE',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  common.aligmentInt8 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_WORD',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  common.aligmentInt16 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_LONG',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  common.aligmentInt32 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_INT64',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  common.aligmentInt64 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_FLOAT32_IEEE',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  common.aligmentFloat32 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_FLOAT64_IEEE',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  common.aligmentFloat64 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'BYTE_ORDER',
              [
                Value('order', ValueType.text, (ValueType t, List<Token> s) {
                  common.endianess = byteOrderFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'DATA_SIZE',
              [
                Value('Position', ValueType.integer, (ValueType t, List<Token> s) {
                  common.dataSize = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'DEPOSIT',
              [
                Value('deposit mode', ValueType.text, (ValueType t, List<Token> s) {
                  common.standardDeposit = depositFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue(
              'S_REC_LAYOUT',
              [
                Value('Identifier', ValueType.id, (ValueType t, List<Token> s) {
                  common.standardRecordLayout = s[0].text;
                })
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(common, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MOD_COMMON must be a module!');
      }
    }, optional: true, unique: true);
  }

  BlockElement _createModuleParameters() {
    return BlockElement('MOD_PAR', (s, p) {
      if (p is Module) {
        var pars = ModuleParameters();
        p.parameters = pars;
        var values = [
          Value('Description', ValueType.id, (ValueType t, List<Token> s) {
            pars.description = removeQuotes(s[0].text);
          })
        ];

        var optional = <A2LElement>[
          NamedValue(
              'CPU_TYPE',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.cpuType = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'CUSTOMER',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.customer = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'CUSTOMER_NO',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.customerNumber = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'ECU',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.controlUnit = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'EPK',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.epromIdentifier = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'PHONE_NO',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.phoneNumber = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'SUPPLIER',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.supplier = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'USER',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.user = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'VERSION',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  pars.version = removeQuotes(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'ECU_CALIBRATION_OFFSET',
              [
                Value('offset', ValueType.integer, (ValueType t, List<Token> s) {
                  pars.calibrationOffset = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'NO_OF_INTERFACES',
              [
                Value('count', ValueType.integer, (ValueType t, List<Token> s) {
                  pars.numberOfInterfaces = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'ADDR_EPK',
              [
                Value('address', ValueType.integer, (ValueType t, List<Token> s) {
                  pars.eepromIdentifiers.add(int.parse(s[0].text));
                })
              ],
              optional: true,
              unique: false),
          NamedValue(
              'SYSTEM_CONSTANT',
              [
                Value('name', ValueType.text, (ValueType t, List<Token> s) {
                  pars.systemConstants.add(SystemConstant());
                  pars.systemConstants.last.name = removeQuotes(s[0].text);
                }),
                Value('value', ValueType.text, (ValueType t, List<Token> s) {
                  pars.systemConstants.last.value = removeQuotes(s[0].text);
                }),
              ],
              optional: true,
              unique: false),
          _createCalibrationMethod(),
          _createMemoryLayout(),
          _createMemorySegment()
        ];
        return A2LElementParsingOptions(pars, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MOD_PAR must be a module!');
      }
    }, optional: true, unique: true);
  }

  List<Value> _createSharedSegmentData(dynamic x) {
    return [
      Value('address', ValueType.integer, (ValueType t, List<Token> s) {
        x.address = int.parse(s[0].text);
      }),
      Value('size', ValueType.integer, (ValueType t, List<Token> s) {
        x.size = int.parse(s[0].text);
      }),
      Value('offsets', ValueType.integer, (ValueType t, List<Token> s) {
        x.offsets = [int.parse(s[0].text), int.parse(s[1].text), int.parse(s[2].text), int.parse(s[3].text), int.parse(s[4].text)];
      }, requiredTokens: 5),
    ];
  }

  BlockElement _createMemorySegment() {
    return BlockElement('MEMORY_SEGMENT', (s, p) {
      if (p is ModuleParameters) {
        var seg = MemorySegment();
        p.memorySegments.add(seg);
        var values = <Value>[
          Value('Name', ValueType.text, (ValueType t, List<Token> s) {
            seg.name = s[0].text;
          }),
          Value('description', ValueType.text, (ValueType t, List<Token> s) {
            seg.description = removeQuotes(s[0].text);
          }),
          Value('PrgType', ValueType.text, (ValueType t, List<Token> s) {
            seg.type = segmentTypeFromString(s[0]);
          }),
          Value('MemoryType', ValueType.text, (ValueType t, List<Token> s) {
            seg.memoryType = memoryTypeFromString(s[0]);
          }),
          Value('Attribute', ValueType.text, (ValueType t, List<Token> s) {
            seg.attribute = segmentAttributeFromString(s[0]);
          }),
        ];
        values.addAll(_createSharedSegmentData(seg));

        return A2LElementParsingOptions(seg, values, [_createInterfaceDataParser()]);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEMORY_LAYOUT must be a ModuleParameters!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createMemoryLayout() {
    return BlockElement('MEMORY_LAYOUT', (s, p) {
      if (p is ModuleParameters) {
        var lay = MemoryLayout();
        p.memoryLayouts.add(lay);
        var values = <Value>[
          Value('PrgType', ValueType.text, (ValueType t, List<Token> s) {
            lay.type = memoryLayoutTypeFromString(s[0]);
          }),
        ];
        values.addAll(_createSharedSegmentData(lay));
        return A2LElementParsingOptions(lay, values, [_createInterfaceDataParser()]);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEMORY_LAYOUT must be a ModuleParameters!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createCalibrationMethod() {
    return BlockElement('CALIBRATION_METHOD', (s, p) {
      if (p is ModuleParameters) {
        var method = CalibrationMethod();
        p.calibrationMethods.add(method);
        var values = [
          Value('Method', ValueType.id, (ValueType t, List<Token> s) {
            method.method = removeQuotes(s[0].text);
          }),
          Value('Version', ValueType.integer, (ValueType t, List<Token> s) {
            method.version = int.parse(s[0].text);
          })
        ];

        var optional = <A2LElement>[_createCalibrationHandle()];
        return A2LElementParsingOptions(method, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of CALIBRATION_METHOD must be a ModuleParameters!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createCalibrationHandle() {
    return BlockElement('CALIBRATION_HANDLE', (s, p) {
      if (p is CalibrationMethod) {
        var values = [
          Value('handle', ValueType.id, (ValueType t, List<Token> s) {
            p.handles.add(int.parse(s[0].text));
          }, multiplicity: -1, stopAt: ['CALIBRATION_HANDLE_TEXT'])
        ];

        var optional = <A2LElement>[
          NamedValue(
              'CALIBRATION_HANDLE_TEXT',
              [
                Value('string', ValueType.text, (ValueType t, List<Token> s) {
                  p.handleText = removeQuotes(s[0].text);
                })
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(p, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of CALIBRATION_METHOD must be a ModuleParameters!');
      }
    }, optional: true, unique: true);
  }

  BlockElement _createRecordLayout() {
    return BlockElement('RECORD_LAYOUT', (s, p) {
      if (p is Module) {
        var rl = RecordLayout();
        p.recordLayouts.add(rl);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            rl.name = s[0].text;
          })
        ];

        var optional = <A2LElement>[
          NamedValue(
              'ALIGNMENT_BYTE',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.aligmentInt8 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_WORD',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.aligmentInt16 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_LONG',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.aligmentInt32 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_INT64',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.aligmentInt64 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_FLOAT32_IEEE',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.aligmentFloat32 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ALIGNMENT_FLOAT64_IEEE',
              [
                Value('alignment', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.aligmentFloat64 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'FNC_VALUES',
              [
                Value('Position', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.values ??= LayoutData();
                  rl.values!.position = int.parse(s[0].text);
                }),
                Value('Datatype', ValueType.text, (ValueType t, List<Token> s) {
                  rl.values!.type = dataTypeFromString(s[0]);
                }),
                Value('IndexMode', ValueType.text, (ValueType t, List<Token> s) {
                  rl.values!.mode = indexModeFromString(s[0]);
                }),
                Value('Addresstype', ValueType.text, (ValueType t, List<Token> s) {
                  rl.values!.addressType = addressTypeFromString(s[0]);
                }),
              ],
              optional: true),
          _createBaseLayoutData('SHIFT_OP_X', () {
            rl.shiftX ??= BaseLayoutData();
            return rl.shiftX!;
          }),
          _createBaseLayoutData('SHIFT_OP_Y', () {
            rl.shiftY ??= BaseLayoutData();
            return rl.shiftY!;
          }),
          _createBaseLayoutData('SHIFT_OP_Z', () {
            rl.shiftZ ??= BaseLayoutData();
            return rl.shiftZ!;
          }),
          _createBaseLayoutData('SHIFT_OP_4', () {
            rl.shift4 ??= BaseLayoutData();
            return rl.shift4!;
          }),
          _createBaseLayoutData('SHIFT_OP_5', () {
            rl.shift5 ??= BaseLayoutData();
            return rl.shift5!;
          }),
          _createBaseLayoutData('SRC_ADDR_X', () {
            rl.inputX ??= BaseLayoutData();
            return rl.inputX!;
          }),
          _createBaseLayoutData('SRC_ADDR_Y', () {
            rl.inputY ??= BaseLayoutData();
            return rl.inputY!;
          }),
          _createBaseLayoutData('SRC_ADDR_Z', () {
            rl.inputZ ??= BaseLayoutData();
            return rl.inputZ!;
          }),
          _createBaseLayoutData('SRC_ADDR_4', () {
            rl.input4 ??= BaseLayoutData();
            return rl.input4!;
          }),
          _createBaseLayoutData('SRC_ADDR_5', () {
            rl.input5 ??= BaseLayoutData();
            return rl.input5!;
          }),
          _createBaseLayoutData('RIP_ADDR_W', () {
            rl.output ??= BaseLayoutData();
            return rl.output!;
          }),
          _createBaseLayoutData('RIP_ADDR_X', () {
            rl.intermediateX ??= BaseLayoutData();
            return rl.intermediateX!;
          }),
          _createBaseLayoutData('RIP_ADDR_Y', () {
            rl.intermediateY ??= BaseLayoutData();
            return rl.intermediateY!;
          }),
          _createBaseLayoutData('RIP_ADDR_Z', () {
            rl.intermediateZ ??= BaseLayoutData();
            return rl.intermediateZ!;
          }),
          _createBaseLayoutData('RIP_ADDR_4', () {
            rl.intermediate4 ??= BaseLayoutData();
            return rl.intermediate4!;
          }),
          _createBaseLayoutData('RIP_ADDR_5', () {
            rl.intermediate5 ??= BaseLayoutData();
            return rl.intermediate5!;
          }),
          _createBaseLayoutData('OFFSET_X', () {
            rl.offsetX ??= BaseLayoutData();
            return rl.offsetX!;
          }),
          _createBaseLayoutData('OFFSET_Y', () {
            rl.offsetY ??= BaseLayoutData();
            return rl.offsetY!;
          }),
          _createBaseLayoutData('OFFSET_Z', () {
            rl.offsetZ ??= BaseLayoutData();
            return rl.offsetZ!;
          }),
          _createBaseLayoutData('OFFSET_4', () {
            rl.offset4 ??= BaseLayoutData();
            return rl.offset4!;
          }),
          _createBaseLayoutData('OFFSET_5', () {
            rl.offset5 ??= BaseLayoutData();
            return rl.offset5!;
          }),
          _createBaseLayoutData('NO_RESCALE_X', () {
            rl.numberOfRescalePointsX ??= BaseLayoutData();
            return rl.numberOfRescalePointsX!;
          }),
          _createBaseLayoutData('NO_RESCALE_Y', () {
            rl.numberOfRescalePointsY ??= BaseLayoutData();
            return rl.numberOfRescalePointsY!;
          }),
          _createBaseLayoutData('NO_RESCALE_Z', () {
            rl.numberOfRescalePointsZ ??= BaseLayoutData();
            return rl.numberOfRescalePointsZ!;
          }),
          _createBaseLayoutData('NO_RESCALE_4', () {
            rl.numberOfRescalePoints4 ??= BaseLayoutData();
            return rl.numberOfRescalePoints4!;
          }),
          _createBaseLayoutData('NO_RESCALE_5', () {
            rl.numberOfRescalePoints5 ??= BaseLayoutData();
            return rl.numberOfRescalePoints5!;
          }),
          _createBaseLayoutData('IDENTIFICATION', () {
            rl.identification ??= BaseLayoutData();
            return rl.identification!;
          }),
          _createBaseLayoutData('DIST_OP_X', () {
            rl.distanceX ??= BaseLayoutData();
            return rl.distanceX!;
          }),
          _createBaseLayoutData('DIST_OP_Y', () {
            rl.distanceY ??= BaseLayoutData();
            return rl.distanceY!;
          }),
          _createBaseLayoutData('DIST_OP_Z', () {
            rl.distanceZ ??= BaseLayoutData();
            return rl.distanceZ!;
          }),
          _createBaseLayoutData('DIST_OP_4', () {
            rl.distance4 ??= BaseLayoutData();
            return rl.distance4!;
          }),
          _createBaseLayoutData('DIST_OP_5', () {
            rl.distance5 ??= BaseLayoutData();
            return rl.distance5!;
          }),
          NamedValue(
              'FIX_NO_AXIS_PTS_X',
              [
                Value('number', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.fixedNumberOfAxisPointsX = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'FIX_NO_AXIS_PTS_Y',
              [
                Value('number', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.fixedNumberOfAxisPointsY = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'FIX_NO_AXIS_PTS_Z',
              [
                Value('number', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.fixedNumberOfAxisPointsZ = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'FIX_NO_AXIS_PTS_4',
              [
                Value('number', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.fixedNumberOfAxisPoints4 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'FIX_NO_AXIS_PTS_5',
              [
                Value('number', ValueType.integer, (ValueType t, List<Token> s) {
                  rl.fixedNumberOfAxisPoints5 = int.parse(s[0].text);
                }),
              ],
              optional: true),
          _createAxisLayoutData('AXIS_PTS_X', () {
            rl.axisPointsX ??= AxisLayoutData();
            return rl.axisPointsX!;
          }),
          _createAxisLayoutData('AXIS_PTS_Y', () {
            rl.axisPointsY ??= AxisLayoutData();
            return rl.axisPointsY!;
          }),
          _createAxisLayoutData('AXIS_PTS_Z', () {
            rl.axisPointsZ ??= AxisLayoutData();
            return rl.axisPointsZ!;
          }),
          _createAxisLayoutData('AXIS_PTS_4', () {
            rl.axisPoints4 ??= AxisLayoutData();
            return rl.axisPoints4!;
          }),
          _createAxisLayoutData('AXIS_PTS_5', () {
            rl.axisPoints5 ??= AxisLayoutData();
            return rl.axisPoints5!;
          }),
          _createAxisRescaleLayoutData('AXIS_RESCALE_X', () {
            rl.axisRescaleX ??= AxisRescaleData();
            return rl.axisRescaleX!;
          }),
          _createAxisRescaleLayoutData('AXIS_RESCALE_Y', () {
            rl.axisRescaleY ??= AxisRescaleData();
            return rl.axisRescaleY!;
          }),
          _createAxisRescaleLayoutData('AXIS_RESCALE_Z', () {
            rl.axisRescaleZ ??= AxisRescaleData();
            return rl.axisRescaleZ!;
          }),
          _createAxisRescaleLayoutData('AXIS_RESCALE_4', () {
            rl.axisRescale4 ??= AxisRescaleData();
            return rl.axisRescale4!;
          }),
          _createAxisRescaleLayoutData('AXIS_RESCALE_5', () {
            rl.axisRescale5 ??= AxisRescaleData();
            return rl.axisRescale5!;
          }),
          NamedValue('STATIC_RECORD_LAYOUT', [], callback: () {
            rl.staticRecordLayout = true;
          }, optional: true),
          NamedValue(
              'RESERVED',
              [
                Value('Position', ValueType.integer, (ValueType t, List<Token> s) {
                  var data = BaseLayoutData();
                  data.position = int.parse(s[0].text);
                  rl.reserved.add(data);
                }),
                Value('Datatype', ValueType.text, (ValueType t, List<Token> s) {
                  rl.reserved.last.type = dataTypeFromString(s[0]);
                })
              ],
              optional: true,
              unique: false)
        ];
        return A2LElementParsingOptions(rl, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of RECORD_LAYOUT must be module!');
      }
    }, optional: true, unique: false);
  }

  NamedValue _createBaseLayoutData(String key, BaseLayoutData Function() data) {
    return NamedValue(
        key,
        [
          Value('Position', ValueType.integer, (ValueType t, List<Token> s) {
            data().position = int.parse(s[0].text);
          }),
          Value('Datatype', ValueType.text, (ValueType t, List<Token> s) {
            data().type = dataTypeFromString(s[0]);
          })
        ],
        optional: true);
  }

  NamedValue _createAxisLayoutData(String key, AxisLayoutData Function() data) {
    return NamedValue(
        key,
        [
          Value('Position', ValueType.integer, (ValueType t, List<Token> s) {
            data().position = int.parse(s[0].text);
          }),
          Value('Datatype', ValueType.text, (ValueType t, List<Token> s) {
            data().type = dataTypeFromString(s[0]);
          }),
          Value('indexOrder', ValueType.text, (ValueType t, List<Token> s) {
            data().order = indexOrderFromString(s[0]);
          }),
          Value('addressType', ValueType.text, (ValueType t, List<Token> s) {
            data().addressType = addressTypeFromString(s[0]);
          }),
        ],
        optional: true);
  }

  NamedValue _createAxisRescaleLayoutData(String key, AxisRescaleData Function() data) {
    return NamedValue(
        key,
        [
          Value('Position', ValueType.integer, (ValueType t, List<Token> s) {
            data().position = int.parse(s[0].text);
          }),
          Value('Datatype', ValueType.text, (ValueType t, List<Token> s) {
            data().type = dataTypeFromString(s[0]);
          }),
          Value('maxNumber', ValueType.integer, (ValueType t, List<Token> s) {
            data().maxNumberOfPairs = int.parse(s[0].text);
          }),
          Value('indexOrder', ValueType.text, (ValueType t, List<Token> s) {
            data().order = indexOrderFromString(s[0]);
          }),
          Value('addressType', ValueType.text, (ValueType t, List<Token> s) {
            data().addressType = addressTypeFromString(s[0]);
          }),
        ],
        optional: true);
  }

  BlockElement _createUnit() {
    return BlockElement('UNIT', (s, p) {
      if (p is Module) {
        var unit = Unit();
        p.units.add(unit);
        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            unit.name = s[0].text;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
            unit.description = removeQuotes(s[0].text);
          }),
          Value('Display', ValueType.text, (ValueType t, List<Token> s) {
            unit.display = removeQuotes(s[0].text);
          }),
          Value('Type', ValueType.text, (ValueType t, List<Token> s) {
            unit.type = unitTypeFromString(s[0]);
          })
        ];
        var optional = <A2LElement>[
          NamedValue(
              'REF_UNIT',
              [
                Value('Unit', ValueType.id, (ValueType t, List<Token> s) {
                  unit.referencedUnit = s[0].text;
                }),
              ],
              optional: true),
          NamedValue(
              'SI_EXPONENTS',
              [
                Value('Length', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents ??= SIExponents();
                  unit.exponents!.length = int.parse(s[0].text);
                }),
                Value('Mass', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents!.mass = int.parse(s[0].text);
                }),
                Value('Time', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents!.time = int.parse(s[0].text);
                }),
                Value('ElectricCurrent', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents!.electricCurrent = int.parse(s[0].text);
                }),
                Value('Temperature', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents!.temperature = int.parse(s[0].text);
                }),
                Value('AmountOfSubstance', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents!.amountOfSubstance = int.parse(s[0].text);
                }),
                Value('LuminousIntensity', ValueType.id, (ValueType t, List<Token> s) {
                  unit.exponents!.luminousIntensity = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'UNIT_CONVERSION',
              [
                Value('Slope', ValueType.id, (ValueType t, List<Token> s) {
                  unit.conversionLinearSlope = double.parse(s[0].text);
                }),
                Value('Offset', ValueType.id, (ValueType t, List<Token> s) {
                  unit.conversionLinearOffset = double.parse(s[0].text);
                }),
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(unit, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of UNIT must be module!');
      }
    }, optional: true, unique: false);
  }

  List<Value> _createSharedValuesMeasurementCharacteristicStart(MeasurementCharacteristicBase base) {
    var values = <Value>[
      Value('Name', ValueType.id, (ValueType t, List<Token> s) {
        base.name = s[0].text;
      }),
      Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
        base.description = removeQuotes(s[0].text);
      })
    ];
    return values;
  }

  List<Value> _createSharedValuesMeasurementCharacteristicEnd(MeasurementCharacteristicBase base) {
    var values = <Value>[
      Value('LowerLimit', ValueType.floating, (ValueType t, List<Token> s) {
        base.lowerLimit = double.parse(s[0].text);
      }),
      Value('UpperLimit', ValueType.floating, (ValueType t, List<Token> s) {
        base.upperLimit = double.parse(s[0].text);
      })
    ];
    return values;
  }

  List<A2LElement> _createSharedOptionalsMeasurementCharacteristic(MeasurementCharacteristicBase base) {
    var values = <A2LElement>[
      NamedValue(
          'BIT_MASK',
          [
            Value('mask', ValueType.integer, (ValueType t, List<Token> s) {
              base.bitMask = int.parse(s[0].text);
            })
          ],
          optional: true),
      NamedValue(
          'BYTE_ORDER',
          [
            Value('order', ValueType.text, (ValueType t, List<Token> s) {
              base.endianess = byteOrderFromString(s[0]);
            })
          ],
          optional: true),
      NamedValue('DISCRETE', [], callback: () {
        base.discrete = true;
      }, optional: true),
      NamedValue(
          'DISPLAY_IDENTIFIER',
          [
            Value('id', ValueType.text, (ValueType t, List<Token> s) {
              base.displayIdentifier = s[0].text;
            })
          ],
          optional: true),
      NamedValue(
          'ECU_ADDRESS_EXTENSION',
          [
            Value('address extension', ValueType.integer, (ValueType t, List<Token> s) {
              base.addressExtension = int.parse(s[0].text);
            })
          ],
          optional: true),
      NamedValue(
          'FORMAT',
          [
            Value('format', ValueType.text, (ValueType t, List<Token> s) {
              base.format = removeQuotes(s[0].text);
            })
          ],
          optional: true),
      NamedValue(
          'PHYS_UNIT',
          [
            Value('unit', ValueType.text, (ValueType t, List<Token> s) {
              base.unit = removeQuotes(s[0].text);
            })
          ],
          optional: true),
      NamedValue(
          'REF_MEMORY_SEGMENT',
          [
            Value('segment', ValueType.text, (ValueType t, List<Token> s) {
              base.memorySegment = s[0].text;
            })
          ],
          optional: true),
      NamedValue(
          'SYMBOL_LINK',
          [
            Value('SymbolName', ValueType.text, (ValueType t, List<Token> s) {
              base.symbolLink ??= SymbolLink();
              base.symbolLink!.name = removeQuotes(s[0].text);
            }),
            Value('Offset', ValueType.integer, (ValueType t, List<Token> s) {
              base.symbolLink!.offset = int.parse(s[0].text);
            }),
          ],
          optional: true),
      NamedValue(
          'MATRIX_DIM',
          [
            Value('Dimensions', ValueType.integer, (ValueType t, List<Token> s) {
              base.matrixDim ??= MatrixDim();
              base.matrixDim!.x = int.parse(s[0].text);
              base.matrixDim!.y = int.parse(s[1].text);
              base.matrixDim!.z = int.parse(s[2].text);
            }, requiredTokens: 3),
          ],
          optional: true),
      NamedValue(
          'MAX_REFRESH',
          [
            Value('ScalingUnit', ValueType.integer, (ValueType t, List<Token> s) {
              base.maxRefresh ??= MaxRefresh();
              base.maxRefresh!.scalingUnit = maxRefreshUnitFromString(s[0]);
            }),
            Value('Rate', ValueType.integer, (ValueType t, List<Token> s) {
              base.maxRefresh!.rate = int.parse(s[0].text);
            }),
          ],
          optional: true),
      _createInterfaceDataParser()
    ];
    return values;
  }

  BlockElement _createMeasurement() {
    return BlockElement('MEASUREMENT', (s, p) {
      if (p is Module) {
        var measurement = Measurement();
        p.measurements.add(measurement);

        var values = _createSharedValuesMeasurementCharacteristicStart(measurement);
        values.addAll([
          Value('Datatype', ValueType.text, (ValueType t, List<Token> s) {
            measurement.datatype = dataTypeFromString(s[0]);
          }),
          Value('Conversion', ValueType.text, (ValueType t, List<Token> s) {
            measurement.conversionMethod = s[0].text;
          }),
          Value('Resolution', ValueType.integer, (ValueType t, List<Token> s) {
            measurement.resolution = int.parse(s[0].text);
          }),
          Value('Accuracy', ValueType.floating, (ValueType t, List<Token> s) {
            measurement.accuracy = double.parse(s[0].text);
          }),
        ]);
        values.addAll(_createSharedValuesMeasurementCharacteristicEnd(measurement));

        var optional = _createSharedOptionalsMeasurementCharacteristic(measurement);
        optional.addAll(<A2LElement>[
          NamedValue(
              'ARRAY_SIZE',
              [
                Value('size', ValueType.integer, (ValueType t, List<Token> s) {
                  measurement.arraySize = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'ECU_ADDRESS',
              [
                Value('address', ValueType.integer, (ValueType t, List<Token> s) {
                  measurement.address = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'ERROR_MASK',
              [
                Value('error mask', ValueType.integer, (ValueType t, List<Token> s) {
                  measurement.errorMask = int.parse(s[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'LAYOUT',
              [
                Value('layout', ValueType.text, (ValueType t, List<Token> s) {
                  measurement.layout = indexModeFromString(s[0]);
                })
              ],
              optional: true),
          NamedValue('READ_WRITE', [], callback: () {
            measurement.readWrite = true;
          }, optional: true),
          _createBitOperation(),
          _createAnnotation(),
          _createFunctionList(),
          _createMeasurementsList(key: 'VIRTUAL')
        ]);
        return A2LElementParsingOptions(measurement, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEASUREMENT must be module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createCharacteristic() {
    return BlockElement('CHARACTERISTIC', (s, p) {
      if (p is Module) {
        var char = Characteristic();
        p.characteristics.add(char);

        var values = _createSharedValuesMeasurementCharacteristicStart(char);
        values.addAll([
          Value('Type', ValueType.text, (ValueType t, List<Token> s) {
            char.type = characteristicTypeFromString(s[0]);
          }),
          Value('Address', ValueType.integer, (ValueType t, List<Token> s) {
            char.address = int.parse(s[0].text);
          }),
          Value('Deposit', ValueType.id, (ValueType t, List<Token> s) {
            char.recordLayout = s[0].text;
          }),
          Value('MaxDiff', ValueType.floating, (ValueType t, List<Token> s) {
            char.maxDiff = double.parse(s[0].text);
          }),
          Value('Conversion', ValueType.id, (ValueType t, List<Token> s) {
            char.conversionMethod = s[0].text;
          }),
        ]);
        values.addAll(_createSharedValuesMeasurementCharacteristicEnd(char));

        var optional = _createSharedOptionalsMeasurementCharacteristic(char);
        optional.addAll(<A2LElement>[
          NamedValue('READ_ONLY', [], callback: () {
            char.readWrite = false;
          }, optional: true),
          NamedValue('GUARD_RAILS', [], callback: () {
            char.guardRails = true;
          }, optional: true),
          NamedValue(
              'STEP_SIZE',
              [
                Value('Step size', ValueType.floating, (p0, p1) {
                  char.stepSize = double.parse(p1[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'NUMBER',
              [
                Value('number', ValueType.integer, (p0, p1) {
                  char.number = int.parse(p1[0].text);
                })
              ],
              optional: true),
          NamedValue(
              'COMPARISON_QUANTITY',
              [
                Value('COMPARISON_QUANTITY', ValueType.id, (p0, p1) {
                  char.comparisionQuantity = p1[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'CALIBRATION_ACCESS',
              [
                Value('CALIBRATION_ACCESS', ValueType.text, (p0, p1) {
                  char.calibrationAccess = calibrationAccessFromString(p1[0]);
                })
              ],
              optional: true),
          NamedValue(
              'EXTENDED_LIMITS',
              [
                Value('EXTENDED_LIMITS', ValueType.floating, (p0, p1) {
                  char.extendedLimits ??= ExtendedLimits();
                  char.extendedLimits!.lowerLimit = double.parse(p1[0].text);
                  char.extendedLimits!.upperLimit = double.parse(p1[1].text);
                }, requiredTokens: 2)
              ],
              optional: true),
          _createAnnotation(),
          _createFunctionList(),
          _createVirtualCharacteristics(),
          _createVirtualCharacteristics(key: 'DEPENDENT_CHARACTERISTIC', virtual: false),
          _createAxisDescription(),
          _createMapListParser()
        ]);
        return A2LElementParsingOptions(char, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEASUREMENT must be module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createMapListParser() {
    return BlockElement('MAP_LIST', (s, p) {
      if (p is Characteristic) {
        return A2LElementParsingOptions(p, [
          Value('map name', ValueType.id, (ValueType t, List<Token> s) { p.mapList.add(s[0].text); }, multiplicity: -1)
        ], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of "MAP_LIST" must be derived from Characteristic!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createVirtualCharacteristics({String key = 'VIRTUAL_CHARACTERISTIC', bool virtual = true}) {
    return BlockElement(key, (s, p) {
      if (p is Characteristic) {
        return A2LElementParsingOptions(p, [
          Value('Formula', ValueType.text, (ValueType t, List<Token> s) {
            if (virtual) {
              p.virtualCharacteristics ??= DependentCharacteristics();
              p.virtualCharacteristics!.formula = removeQuotes(s[0].text);
            } else {
              p.dependentCharacteristics ??= DependentCharacteristics();
              p.dependentCharacteristics!.formula = removeQuotes(s[0].text);
            }
          }),
          Value('Characteristics id', ValueType.id, (ValueType t, List<Token> s) {
            if (virtual) {
              p.virtualCharacteristics!.characteristics.add(s[0].text);
            } else {
              p.dependentCharacteristics!.characteristics.add(s[0].text);
            }
          }, multiplicity: -1)
        ], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of $key must be derived from Characteristic!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeMethod() {
    return BlockElement('COMPU_METHOD', (s, p) {
      if (p is Module) {
        var comp = ComputeMethod();
        p.computeMethods.add(comp);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            comp.name = s[0].text;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
            comp.description = removeQuotes(s[0].text);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, List<Token> s) {
            comp.type = computeMethodTypeFromSting(s[0]);
          }),
          Value('Format', ValueType.text, (ValueType t, List<Token> s) {
            comp.format = removeQuotes(s[0].text);
          }),
          Value('Unit', ValueType.text, (ValueType t, List<Token> s) {
            comp.unit = removeQuotes(s[0].text);
          }),
        ];

        var optional = <A2LElement>[
          NamedValue(
              'COEFFS',
              [
                Value('a', ValueType.floating, (ValueType t, List<Token> s) {
                  comp.coefficientA = double.parse(s[0].text);
                  comp.coefficientB = double.parse(s[1].text);
                  comp.coefficientC = double.parse(s[2].text);
                  comp.coefficientD = double.parse(s[3].text);
                  comp.coefficientE = double.parse(s[4].text);
                  comp.coefficientF = double.parse(s[5].text);
                }, requiredTokens: 6)
              ],
              optional: true),
          NamedValue(
              'COEFFS_LINEAR',
              [
                Value('a', ValueType.floating, (ValueType t, List<Token> s) {
                  comp.coefficientA = double.parse(s[0].text);
                  comp.coefficientB = double.parse(s[1].text);
                }, requiredTokens: 2)
              ],
              optional: true),
          NamedValue(
              'COMPU_TAB_REF',
              [
                Value('format', ValueType.id, (ValueType t, List<Token> s) {
                  comp.referencedTable = s[0].text;
                })
              ],
              optional: true),
          _createFormula(),
          NamedValue(
              'REF_UNIT',
              [
                Value('unit', ValueType.id, (ValueType t, List<Token> s) {
                  comp.referencedUnit = s[0].text;
                })
              ],
              optional: true),
          NamedValue(
              'STATUS_STRING_REF',
              [
                Value('segment', ValueType.id, (ValueType t, List<Token> s) {
                  comp.referencedStatusString = s[0].text;
                })
              ],
              optional: true)
        ];
        return A2LElementParsingOptions(comp, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEASUREMENT must be module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeTable() {
    return BlockElement('COMPU_TAB', (s, p) {
      if (p is Module) {
        var tab = ComputeTable();
        p.computeTables.add(tab);

        var pairs = Value('Pairs', ValueType.text, (ValueType t, List<Token> s) {
          tab.table.add(ComputeTableEntry(x: double.parse(s[0].text), outNumeric: double.parse(s[1].text), outString: s[1].text));
        }, requiredTokens: 2);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            tab.name = s[0].text;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
            tab.description = removeQuotes(s[0].text);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, List<Token> s) {
            tab.type = computeMethodTypeFromSting(s[0]);
          }),
          Value('NumberValuePairs', ValueType.integer, (ValueType t, List<Token> s) {
            pairs.multiplicity = int.parse(s[0].text);
          }),
          pairs
        ];

        var optional = <A2LElement>[
          NamedValue(
              'DEFAULT_VALUE',
              [
                Value('default value double', ValueType.text, (ValueType t, List<Token> s) {
                  tab.fallbackValue = removeQuotes(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'DEFAULT_VALUE_NUMERIC',
              [
                Value('default value string', ValueType.floating, (ValueType t, List<Token> s) {
                  tab.fallbackValueNumeric = double.parse(s[0].text);
                }),
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(tab, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEASUREMENT must be module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeVerbatimTable() {
    return BlockElement('COMPU_VTAB', (s, p) {
      if (p is Module) {
        var tab = VerbatimTable();
        p.computeTables.add(tab);

        var pairs = Value('Pairs', ValueType.text, (ValueType t, List<Token> s) {
          tab.table.add(ComputeTableEntry(x: double.parse(s[0].text), outString: removeQuotes(s[1].text)));
        }, requiredTokens: 2);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            tab.name = s[0].text;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
            tab.description = removeQuotes(s[0].text);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, List<Token> s) {
            tab.type = computeMethodTypeFromSting(s[0]);
          }),
          Value('NumberValuePairs', ValueType.integer, (ValueType t, List<Token> s) {
            pairs.multiplicity = int.parse(s[0].text);
          }),
          pairs
        ];

        var optional = <A2LElement>[
          NamedValue(
              'DEFAULT_VALUE',
              [
                Value('default value double', ValueType.text, (ValueType t, List<Token> s) {
                  tab.fallbackValue = removeQuotes(s[0].text);
                }),
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(tab, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEASUREMENT must be module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeVerbatimRangeTable() {
    return BlockElement('COMPU_VTAB_RANGE', (s, p) {
      if (p is Module) {
        var tab = VerbatimRangeTable();
        p.computeTables.add(tab);

        var pairs = Value('Pairs', ValueType.text, (ValueType t, List<Token> s) {
          tab.table.add(ComputeTableEntry(
              x: double.parse(s[0].text),
              xUp: double.parse(s[1].text),
              isFloat: s[1].text.contains('.'),
              outString: removeQuotes(s[2].text)));
        }, requiredTokens: 3);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            tab.name = s[0].text;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
            tab.description = removeQuotes(s[0].text);
          }),
          Value('NumberValueTriples', ValueType.integer, (ValueType t, List<Token> s) {
            pairs.multiplicity = int.parse(s[0].text);
          }),
          pairs
        ];

        var optional = <A2LElement>[
          NamedValue(
              'DEFAULT_VALUE',
              [
                Value('default value double', ValueType.text, (ValueType t, List<Token> s) {
                  tab.fallbackValue = removeQuotes(s[0].text);
                }),
              ],
              optional: true),
        ];
        return A2LElementParsingOptions(tab, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of MEASUREMENT must be module!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createFormula() {
    return BlockElement('FORMULA', (s, p) {
      if (p is ComputeMethod) {
        p.formula ??= Formula();
        var values = <Value>[
          Value('Formula', ValueType.text, ((ValueType t, List<Token> s) {
            p.formula!.formula = removeQuotes(s[0].text);
          }))
        ];
        var optional = <A2LElement>[
          NamedValue(
              'FORMULA_INV',
              [
                Value('FORMULA_INV', ValueType.text, (ValueType t, List<Token> s) {
                  p.formula!.inverseFormula = removeQuotes(s[0].text);
                }),
              ],
              optional: true)
        ];
        return A2LElementParsingOptions(p, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of Formula must be derived from ComputeMethod!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createBitOperation() {
    return BlockElement('BIT_OPERATION', (s, p) {
      if (p is Measurement) {
        p.bitOperation = BitOperation();

        var optional = <A2LElement>[
          NamedValue(
              'LEFT_SHIFT',
              [
                Value('LEFT_SHIFT', ValueType.text, (ValueType t, List<Token> s) {
                  p.bitOperation!.leftShift = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'RIGHT_SHIFT',
              [
                Value('RIGHT_SHIFT', ValueType.text, (ValueType t, List<Token> s) {
                  p.bitOperation!.rightShift = int.parse(s[0].text);
                }),
              ],
              optional: true),
          NamedValue('SIGN_EXTEND', [], callback: () => p.bitOperation!.signExtend = true, optional: true)
        ];
        return A2LElementParsingOptions(p, [], optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of ANNOTATION must be derived from AnnotationContainer!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createAnnotation() {
    return BlockElement('ANNOTATION', (s, p) {
      if (p is AnnotationContainer) {
        var anno = Annotation();
        p.annotations.add(anno);

        var optional = <A2LElement>[
          NamedValue(
              'ANNOTATION_LABEL',
              [
                Value('ANNOTATION_LABEL', ValueType.text, (ValueType t, List<Token> s) {
                  anno.label = removeQuotes(s[0].text);
                }),
              ],
              optional: true),
          NamedValue(
              'ANNOTATION_ORIGIN',
              [
                Value('ANNOTATION_ORIGIN', ValueType.text, (ValueType t, List<Token> s) {
                  anno.origin = removeQuotes(s[0].text);
                }),
              ],
              optional: true),
          BlockElement('ANNOTATION_TEXT', (s, p) {
            if (p is Annotation) {
              return A2LElementParsingOptions(anno, [
                Value('TEXT', ValueType.text, (ValueType t, List<Token> s) {
                  anno.text.add(removeQuotes(s[0].text));
                }, multiplicity: -1)
              ], []);
            } else {
              throw ValidationError('Parse tree built wrong, parent of ANNOTATION_TEXT must be derived from Annotation!');
            }
          }, optional: true)
        ];
        return A2LElementParsingOptions(anno, [], optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of ANNOTATION must be derived from AnnotationContainer!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createFunctionList({String key = 'FUNCTION_LIST'}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
          Value('Function id', ValueType.text, (ValueType t, List<Token> s) {
            p.functions.add(s[0].text);
          }, multiplicity: -1)
        ], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of FUNCTION_LIST must be derived from DataContainer!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createCharacteristicsList({String key = 'REF_CHARACTERISTIC', List<String> Function(dynamic) cb = getCharacteristics}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
          Value('Characteristics id', ValueType.text, (ValueType t, List<Token> s) {
            cb(p).add(s[0].text);
          }, multiplicity: -1)
        ], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of $key must be derived from DataContainer!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createMeasurementsList({String key = 'REF_MEASUREMENT', List<String> Function(dynamic) cb = getMeasurements}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
          Value('Measurements id', ValueType.text, (ValueType t, List<Token> s) {
            cb(p).add(s[0].text);
          }, multiplicity: -1)
        ], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of $key must be derived from DataContainer!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createGroupList({String key = 'SUB_GROUP'}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
          Value('Group id', ValueType.text, (ValueType t, List<Token> s) {
            p.groups.add(s[0].text);
          }, multiplicity: -1)
        ], []);
      } else {
        throw ValidationError('Parse tree built wrong, parent of $key must be derived from DataContainer!');
      }
    }, optional: true, unique: false);
  }

  BlockElement _createGroups() {
    return BlockElement('GROUP', (s, p) {
      if (p is Module) {
        var grp = Group();
        p.groups.add(grp);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<Token> s) {
            grp.name = s[0].text;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<Token> s) {
            grp.description = removeQuotes(s[0].text);
          })
        ];

        var optional = <A2LElement>[
          _createAnnotation(),
          _createFunctionList(),
          _createCharacteristicsList(),
          _createMeasurementsList(),
          _createGroupList(),
          _createInterfaceDataParser(),
          NamedValue('ROOT', [], optional: true, unique: true, callback: () {
            grp.root = true;
          })
        ];
        return A2LElementParsingOptions(grp, values, optional);
      } else {
        throw ValidationError('Parse tree built wrong, parent of GROUP must be module!');
      }
    }, optional: true, unique: false);
  }
}

/// returns the characteristics member list.
List<String> getCharacteristics(dynamic p) {
  return p.characteristics;
}

/// returns the measurements member list.
List<String> getMeasurements(dynamic p) {
  return p.measurements;
}
