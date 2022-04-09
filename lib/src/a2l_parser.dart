import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';

import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/utility.dart';
import 'package:a2l/src/a2l_tree/a2l_file.dart';
import 'dart:collection';

enum ValueType {
  flag,
  id,
  text,
  integer,
  floating
}

class A2LElement {
  String name;
  bool optional;
  bool unique;
  int count = 0;
  A2LElement(this.name, this.optional, {this.unique=true});
}

class Value extends A2LElement {
  ValueType type;
  bool _valueSet = false;
  List<String> _value;
  /// how many times a value should be read
  int multiplicity;
  /// how many String tokens are needed to initialize this value
  int requiredTokens;

  final void Function(ValueType,List<String>) _callback;

  Value(String name, this.type, this._callback, {this.multiplicity = 1, this.requiredTokens = 1}) : _value = [], super(name,false);

  set value(List<String> values) {
    for(final val in values) {
      if(val == '/begin' || val == '/end') {
        throw ParsingException('A parsed value cannot be $val', '', 0);
      }
    }
    if(values.length != requiredTokens) {
        throw ParsingException('A value of type "$name" requires exactly $requiredTokens, but received ${values.length}', '', 0);
    }
    _value = values;
    _valueSet = true;
    _callback(type,_value);
  }

  bool get valueSet => _valueSet;

  List<String> get value => _value;

  @override
  String toString() {
    return '$type ("$name")';
  }
}

class NamedValue extends A2LElement {
  List<Value> values;
  NamedValue(String name, this.values, {bool optional=false, bool unique=true}) : super(name, optional, unique: unique);
}

class A2LElementParsingOptions {
  dynamic current;
  List<Value> mandatoryPositional;
  List<A2LElement> named;

  A2LElementParsingOptions(this.current,this.mandatoryPositional, this.named);
}

class BlockElement extends A2LElement {
  List<Value> values;
  List<NamedValue> namedValues;
  List<BlockElement> children;
  BlockElement(String name, this._callback,{this.values=const [], this.namedValues=const [], this.children=const [], bool optional=false, bool unique=true}) : super(name, optional, unique: unique);
  
  final A2LElementParsingOptions Function(dynamic self, dynamic parent) _callback;

  A2LElementParsingOptions prepareNewLement(dynamic parent) {
    return _callback(this, parent);
  }
}

class EntryData {
  String name;

  EntryData(this.name);
}

class TokenParser {
  List<String> tokens = [];
  List<bool> usedTokens = [];
  int currentIndex = 0;
  String currentToken = '';
  List<A2LElement> expectedTokens = [];

  var stack = Queue<List<A2LElement>>();

  A2LFile parsed=A2LFile();

  TokenParser();

  
  A2LFile parse()
  {
    setTopLevelTokens();
    usedTokens = List<bool>.generate(3, (int index) => false, growable: false);
    _parseRecursive(parsed,0,tokens.length);
    return parsed;
  }

  void _parseRecursive(dynamic current, int start, int end)
  {
    print("RECURSING $start $end");
    for (var i=start; i<end; ++i) {
      currentIndex = i;
      print("= Token ${tokens[i]}");
      if (tokens[i]=='/begin') {
        print("begin ${tokens[i+1]}");
        var limit = findMatchingEndToken();
        var expected = findExpected(tokens[i+1]);
        print("$expected");
        if(expected!=null) {
          print("expected ${expected.name}");
          if(expected is BlockElement){
            print("is block");
            currentIndex = i+2;
            stack.add(expectedTokens);
            var opts = expected.prepareNewLement(current);
            parseRequiredOrderedElements(opts.mandatoryPositional,limit);
            // Todo push stack, change expected

            expectedTokens = [];
            expectedTokens.addAll(opts.named);
            _parseRecursive(opts.current,currentIndex,limit);
            expectedTokens = stack.last;
            stack.removeLast();
            // todo restore expected from stack
            expected.count += 1;
          } else {
            throw ParsingException('Element "${expected.name}" is not a block element!', '', 0);
          }
        }
        i = limit+1;
        print("new index $currentIndex");
        continue;
      }
      for(final token in expectedTokens) {
        if(token.name != tokens[i]) {
          continue;
        }
        if(token is NamedValue) {
          print("named value $token");
          currentIndex = i+1;
          parseRequiredOrderedElements(token.values,end);
          token.count += 1;
          i+=token.values.length;
          continue;
        }
      }
    }
    for(final token in expectedTokens) {
      if(!token.optional && token.count==0) {
        throw ParsingException('Mandatory element "${token.name}" not found', '', 0);
      }
      if(token.unique && token.count>1) {
        throw ParsingException('${token.name} can only occur once! Found ${token.count}', '', 0);
      }
    }
  }

  A2LElement? findExpected(String nm){
    for(final token in expectedTokens) {
        print("${token.name} == $nm");
        if(token.name == nm) {
          return token;
        }
    }
    return null;
  }

  /// [max] is one past the end.
  void parseRequiredOrderedElements(List<Value> values, int max)
  {
    if ( values.length + currentIndex > max) {
      throw ParsingException('Token "$currentToken" has at least ${values.length} mandatory values! Only found ${max-currentIndex}', '', currentIndex);
    }
    print("Parse $currentIndex to ${max} : ${tokens[currentIndex]} to ${tokens[max-1]}");

    for(var k=0; k<values.length; k++) {
        if(values[k].multiplicity>=0){
          _parseSingleValue(values, max, k);
        }
        else {
          _parseRemainingTokens(values, max, k);
          break;
        }
    }
  }

  void _parseRemainingTokens(List<Value> values, int max, int k,) {
    if (k != values.length - 1) {
      throw ParsingException('Value ${values[k]} at $k (of ${values.length}) requested all remaining tokens! Some values could not be processed','',currentIndex);
    }
    print("Parse all $currentIndex to ${max} : ${tokens[currentIndex]} to ${tokens[max-1]}");

    try {
      while (currentIndex + values[k].requiredTokens <= max) {
        print("$currentIndex to ${currentIndex+values[k].requiredTokens} : ${tokens[currentIndex]} to ${tokens[currentIndex+values[k].requiredTokens]}");
        values[k].value = tokens.sublist(currentIndex, currentIndex + values[k].requiredTokens);
        currentIndex += values[k].requiredTokens;
      }
    } catch (ex) {
      throw ParsingException('Token $currentIndex "${tokens[currentIndex]}" could not be converted to ${values[k]}','', currentIndex);
    }

    if (currentIndex != max) {
      throw ParsingException('Not all tokens could be processed! Target $max, stride ${values[k].requiredTokens}, ended at $currentIndex','', currentIndex);
    }
  }

  void _parseSingleValue(List<Value> values, int max, int k) {
    for (var i = 0; i < values[k].multiplicity; ++i) {
      if (currentIndex + values[k].requiredTokens > max) {
        throw ParsingException('Not enough tokens! Target $max, stride ${values[k].requiredTokens}, multiplicity ${values[k].multiplicity}, ended at iteration $i, token $currentIndex','',currentIndex);
      }
      try {
        values[k].value = tokens.sublist(currentIndex, currentIndex + values[k].requiredTokens);
      } catch (ex) {
        throw ParsingException('Token $currentIndex "${tokens[currentIndex]}" could not be converted to ${values[k]}','',currentIndex);
      }
      currentIndex += values[k].requiredTokens;
    }
  }


  int findMatchingEndToken() {
    var beginCount = 0;
    var name = tokens[currentIndex+1];
    for(var k = currentIndex; k<tokens.length; ++k) {
      //print("Check ${tokens[k]}");
      if(tokens[k]=='/begin') {
        beginCount += 1;
        //print("add $beginCount");
      }
      if(tokens[k]=='/end') {
        beginCount -= 1;
        //print("remove $beginCount");
      }
      if(beginCount==0) {
        //print("found $k : ${tokens[k]} ${tokens[k+1]}");
        if(tokens[k+1]!=name) {
          throw ParsingException('Expected /end $name, got /end ${tokens[k+1]}', '', currentIndex);
        }
        return k;
      }
    }
    throw ParsingException('Missing /end $name', '', currentIndex);
  }

  void setTopLevelTokens() {
    parsed = A2LFile();
    var asap2VersionValues = <Value>[
        Value('VersionNo', ValueType.integer, (ValueType t, List<String> s) {
          parsed.a2lMajorVersion = int.parse(s[0]);
        }),
        Value('UpgradeNo', ValueType.integer, (ValueType t, List<String> s) {
          parsed.a2lMinorVersion = int.parse(s[0]);
        })
    ];
    var asap2MLVersionValues = <Value>[
        Value('VersionNo', ValueType.integer, (ValueType t, List<String> s) {
          parsed.a2mlMajorVersion = int.parse(s[0]);
        }),
        Value('UpgradeNo', ValueType.integer, (ValueType t, List<String> s) {
          parsed.a2mlMinorVersion = int.parse(s[0]);
        })
    ];

    
    var projectValues = <Value>[
        Value('Name', ValueType.id, (ValueType t, List<String> s) {
          parsed.project.name = s[0];
        }),
        Value('LongIdentifier', ValueType.integer, (ValueType t, List<String> s) {
          parsed.project.longName = removeQuotes(s[0]);
        })
    ];

    var project = BlockElement('PROJECT',(s,p) {
      return A2LElementParsingOptions(p,s.values , s.children);
    } ,values: projectValues, children: createProjectChildren());

    expectedTokens = [
      NamedValue('ASAP2_VERSION', asap2VersionValues),
      NamedValue('A2ML_VERSION', asap2MLVersionValues, optional : true),
      project
    ];
  }

  List<BlockElement> createProjectChildren() {
    var header = BlockElement('HEADER',(s,p) {
      return A2LElementParsingOptions(p,s.values , s.namedValues);
    } ,values: [
      Value('Comment', ValueType.text, (ValueType t, List<String> s) {
        print('setting comment to ${s[0]}');
        parsed.project.comment = removeQuotes(s[0]);
      })
    ], namedValues: [
      NamedValue(
          'VERSION',
          [
            Value('version number', ValueType.text, (ValueType t, List<String> s) {
        print('setting version to ${s[0]}');
              parsed.project.version = s[0];
            })
          ],
          optional: true),
      NamedValue(
          'PROJECT_NO',
          [
            Value('project number', ValueType.text, (ValueType t, List<String> s) {
        print('setting num to $s');
              parsed.project.number = s[0];
            })
          ],
          optional: true),
    ], optional: true);

    var module = BlockElement('MODULE',(s,p) {
      var module = Module();
      p.project.modules.add(module);
      var values = [
        Value('Name', ValueType.id, (ValueType t, List<String> s) {
        print("Setting name $s");
        module.name = s[0];
      }),
      Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
        print("Setting desc $s");
        module.description = removeQuotes(s[0]);
      })
      ];
      return A2LElementParsingOptions(module,values , createModuleChildren());
    },optional: false, unique: false);

    return [header,module];
  }


  List<BlockElement> createModuleChildren() {
    return [_createUnit(), _createMeasurement(), _createComputeMethod(), _createComputeTable(), _createComputeVerbatimTable(), _createComputeVerbatimRangeTable()];
  }

  BlockElement _createUnit() {
    return BlockElement('UNIT', (s, p) {
      if (p is Module) {
        var unit = Unit();
        p.units.add(unit);
        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            unit.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            unit.description = removeQuotes(s[0]);
          }),
          Value('Display', ValueType.text, (ValueType t, List<String> s) {
            unit.display = removeQuotes(s[0]);
          }),
          Value('Type', ValueType.text, (ValueType t, List<String> s) {
            if (s[0] == 'DERIVED') {
              unit.type = UnitType.DERIVED;
            } else if (s[0] == 'EXTENDED_SI') {
              unit.type = UnitType.EXTENDED_SI;
            } else {
              throw ParsingException('Unsupported unit type $s', '', 0);
            }
          })
        ];
        var optional = <A2LElement>[
          NamedValue('REF_UNIT', [
            Value('Unit', ValueType.id, (ValueType t, List<String> s) {
              unit.referencedUnit = s[0];
            }),
          ], optional: true),
          NamedValue('SI_EXPONENTS', [
            Value('Length', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_length = int.parse(s[0]);
            }),
            Value('Mass', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_mass = int.parse(s[0]);
            }),
            Value('Time', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_time = int.parse(s[0]);
            }),
            Value('ElectricCurrent', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_electricCurrent = int.parse(s[0]);
            }),
            Value('Temperature', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_temperature = int.parse(s[0]);
            }),
            Value('AmountOfSubstance', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_amountOfSubstance = int.parse(s[0]);
            }),
            Value('LuminousIntensity', ValueType.id, (ValueType t, List<String> s) {
              unit.exponent_luminousIntensity = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('UNIT_CONVERSION', [
            Value('Slope', ValueType.id, (ValueType t, List<String> s) {
              unit.conversionLinear_slope = double.parse(s[0]);
            }),
            Value('Offset', ValueType.id, (ValueType t, List<String> s) {
              unit.conversionLinear_offset = double.parse(s[0]);
            }),
          ], optional: true),
        ];
        return A2LElementParsingOptions(unit, values, optional);
      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of UNIT must be module!', '', 0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createMeasurement() {
    return BlockElement('MEASUREMENT', (s, p) {
      if (p is Module) {
        var measurement = Measurement();
        p.measurements.add(measurement);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            measurement.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            measurement.description = removeQuotes(s[0]);
          }),
          Value('Datatype', ValueType.text, (ValueType t, List<String> s) {
            measurement.datatype = dataTypeFromString(s[0]);
          }),
          Value('Conversion', ValueType.text, (ValueType t, List<String> s) {
            measurement.conversionMethod = s[0];
          }),
          Value('Resolution', ValueType.integer, (ValueType t, List<String> s) {
            measurement.resolution = int.parse(s[0]);
          }),
          Value('Accuracy', ValueType.floating, (ValueType t, List<String> s) {
            measurement.accuracy = double.parse(s[0]);
          }),
          Value('LowerLimit', ValueType.floating, (ValueType t, List<String> s) {
            measurement.lowerLimit = double.parse(s[0]);
          }),
          Value('UpperLimit', ValueType.floating, (ValueType t, List<String> s) {
            measurement.upperLimit = double.parse(s[0]);
          })
        ];

        var optional = <A2LElement>[
          NamedValue('ARRAY_SIZE', [
            Value('size', ValueType.integer, (ValueType t, List<String> s) {
              measurement.arraySize = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('BIT_MASK', [
            Value('mask', ValueType.integer, (ValueType t, List<String> s) {
              measurement.bitMask = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('BYTE_ORDER', [
            Value('order', ValueType.text, (ValueType t, List<String> s) {
              measurement.endianess = byteOrderFromString(s[0]);
            })
          ], optional: true),
          NamedValue('DISPLAY_IDENTIFIER', [
            Value('id', ValueType.text, (ValueType t, List<String> s) {
              measurement.displayIdentifier = removeQuotes(s[0]);
            })
          ], optional: true),
          NamedValue('ECU_ADDRESS', [
            Value('address', ValueType.integer, (ValueType t, List<String> s) {
              measurement.address = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('ECU_ADDRESS_EXTENSION', [
            Value('address extension', ValueType.integer, (ValueType t, List<String> s) {
              measurement.addressExtension = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('ERROR_MASK', [
            Value('error mask', ValueType.integer, (ValueType t, List<String> s) {
              measurement.errorMask = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('FORMAT', [
            Value('format', ValueType.text, (ValueType t, List<String> s) {
              measurement.format = removeQuotes(s[0]);
            })
          ], optional: true),
          NamedValue('LAYOUT', [
            Value('layout', ValueType.text, (ValueType t, List<String> s) {
              measurement.layout = indexModeFromString(s[0]);
            })
          ], optional: true),
          NamedValue('PHYS_UNIT', [
            Value('unit', ValueType.text, (ValueType t, List<String> s) {
              measurement.unit = removeQuotes(s[0]);
            })
          ], optional: true),
          NamedValue('REF_MEMORY_SEGMENT', [
            Value('segment', ValueType.text, (ValueType t, List<String> s) {
              measurement.memorySegment = s[0];
            })
          ], optional: true),
          _createAnnotation()
        ];
        return A2LElementParsingOptions(measurement, values, optional);
      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
      }
    }, optional: true, unique: false);
  }


  BlockElement _createComputeMethod() {
    return BlockElement('COMPU_METHOD', (s, p) {
      if (p is Module) {
        var comp = ComputeMethod();
        p.computeMethods.add(comp);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            comp.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            comp.description = removeQuotes(s[0]);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, List<String> s) {
            comp.type = computeMethodTypeFromSting(s[0]);
          }),
          Value('Format', ValueType.text, (ValueType t, List<String> s) {
            comp.format = removeQuotes(s[0]);
          }),
          Value('Unit', ValueType.text, (ValueType t, List<String> s) {
            comp.unit = removeQuotes(s[0]);
          }),
        ];

        var optional = <A2LElement>[
          NamedValue('COEFFS', [
            Value('a', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_a = double.parse(s[0]);
            }),
            Value('b', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_b = double.parse(s[0]);
            }),
            Value('c', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_c = double.parse(s[0]);
            }),
            Value('d', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_d = double.parse(s[0]);
            }),
            Value('e', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_e = double.parse(s[0]);
            }),
            Value('f', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_f = double.parse(s[0]);
            }),
          ], optional: true),
          NamedValue('COEFFS_LINEAR', [
            Value('a', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_a = double.parse(s[0]);
            }),
            Value('b', ValueType.integer, (ValueType t, List<String> s) {
              comp.coefficient_b = double.parse(s[0]);
            }),
          ], optional: true),
          NamedValue('COMPU_TAB_REF', [
            Value('format', ValueType.id, (ValueType t, List<String> s) {
              comp.referenced_table = s[0];
            })
          ], optional: true),
          NamedValue('FORMULA', [
            Value('forumla', ValueType.text, (ValueType t, List<String> s) {
              comp.formula = removeQuotes(s[0]);
            })
          ], optional: true),
          NamedValue('REF_UNIT', [
            Value('unit', ValueType.id, (ValueType t, List<String> s) {
              comp.referenced_unit = s[0];
            })
          ], optional: true),
          NamedValue('STATUS_STRING_REF', [
            Value('segment', ValueType.id, (ValueType t, List<String> s) {
              comp.referenced_statusString = s[0];
            })
          ], optional: true)
        ];
        return A2LElementParsingOptions(comp, values, optional);

      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeTable() {
    return BlockElement('COMPU_TAB', (s, p) {
      if (p is Module) {
        var tab = ComputeTable();
        p.computeTables.add(tab);

        var pairs = Value('Pairs', ValueType.text, (ValueType t, List<String> s) {
            tab.table.add(ComputeTableEntry(x: double.parse(s[0]), outNumeric: double.parse(s[1]), outString: s[1]));
        }, requiredTokens: 2);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            tab.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            tab.description = removeQuotes(s[0]);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, List<String> s) {
            tab.type = computeMethodTypeFromSting(s[0]);
          }),
          Value('NumberValuePairs', ValueType.integer, (ValueType t, List<String> s) {
            pairs.multiplicity = int.parse(s[0]);
          }),
          pairs
        ];

        var optional = <A2LElement>[
          NamedValue('DEFAULT_VALUE', [
            Value('default value double', ValueType.text, (ValueType t, List<String> s) {
              tab.fallbackValue = removeQuotes(s[0]);
            }),
          ], optional: true),
          NamedValue('DEFAULT_VALUE_NUMERIC', [
            Value('default value string', ValueType.floating, (ValueType t, List<String> s) {
              tab.fallbackValueNumeric = double.parse(s[0]);
            }),
          ], optional: true),
        ];
        return A2LElementParsingOptions(tab, values, optional);

      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeVerbatimTable() {
    return BlockElement('COMPU_VTAB', (s, p) {
      if (p is Module) {
        var tab = VerbatimTable();
        p.computeTables.add(tab);

        var pairs = Value('Pairs', ValueType.text, (ValueType t, List<String> s) {
            tab.table.add(ComputeTableEntry(x: double.parse(s[0]), outString: removeQuotes(s[1])));
        }, requiredTokens: 2);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            tab.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            tab.description = removeQuotes(s[0]);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, List<String> s) {
            tab.type = computeMethodTypeFromSting(s[0]);
          }),
          Value('NumberValuePairs', ValueType.integer, (ValueType t, List<String> s) {
            pairs.multiplicity = int.parse(s[0]);
          }),
          pairs
        ];

        var optional = <A2LElement>[
          NamedValue('DEFAULT_VALUE', [
            Value('default value double', ValueType.text, (ValueType t, List<String> s) {
              tab.fallbackValue = removeQuotes(s[0]);
            }),
          ], optional: true),
        ];
        return A2LElementParsingOptions(tab, values, optional);
      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createComputeVerbatimRangeTable() {
    return BlockElement('COMPU_VTAB_RANGE', (s, p) {
      if (p is Module) {
        var tab = VerbatimRangeTable();
        p.computeTables.add(tab);

        var pairs = Value('Pairs', ValueType.text, (ValueType t, List<String> s) {
            tab.table.add(ComputeTableEntry(x: double.parse(s[0]), x_up: double.parse(s[1]), isFloat: s[1].contains('.'), outString: removeQuotes(s[2])));
        }, requiredTokens: 3);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            tab.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            tab.description = removeQuotes(s[0]);
          }),
          Value('NumberValueTriples', ValueType.integer, (ValueType t, List<String> s) {
            pairs.multiplicity = int.parse(s[0]);
          }),
          pairs
        ];

        var optional = <A2LElement>[
          NamedValue('DEFAULT_VALUE', [
            Value('default value double', ValueType.text, (ValueType t, List<String> s) {
              tab.fallbackValue = removeQuotes(s[0]);
            }),
          ], optional: true),
        ];
        return A2LElementParsingOptions(tab, values, optional);
      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createAnnotation() {
    return BlockElement('ANNOTATION', (s, p) {
      if (p is AnnotationContainer) {
        var anno = Annotation();
        p.annotations.add(anno);

        var optional = <A2LElement>[
          NamedValue('ANNOTATION_LABEL', [
            Value('ANNOTATION_LABEL', ValueType.text, (ValueType t, List<String> s) {
              anno.label = removeQuotes(s[0]);
            }),
          ], optional: true),
          NamedValue('ANNOTATION_ORIGIN', [
            Value('ANNOTATION_ORIGIN', ValueType.text, (ValueType t, List<String> s) {
              anno.origin = removeQuotes(s[0]);
            }),
          ], optional: true),
          BlockElement('ANNOTATION_TEXT', (s, p) {
            if(p is Annotation) {
              return A2LElementParsingOptions(anno, [
                Value('TEXT', ValueType.text, (ValueType t, List<String> s) {
                  anno.text.add(removeQuotes(s[0]));
                }, multiplicity: -1)], []);
            } else {
              throw ParsingException('Parse tree built wrong, parent of ANNOTATION_TEXT must be derived from Annotation!','', 0);
            }
          },optional: true)
        ];
        return A2LElementParsingOptions(anno, [], optional);
      } else {
        throw ParsingException('Parse tree built wrong, parent of ANNOTATION must be derived from AnnotationContainer!','', 0);
      }
    }, optional: true, unique: false);
  }
}
