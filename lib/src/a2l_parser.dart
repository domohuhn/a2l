import 'package:a2l/src/a2l_tree/compute_method.dart';

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
  String _value = '';
  /// how many times a value should be read
  int multiplicity = 1;
  /// how many String tokens are needed to initialize this value
  int requiredTokens = 1;

  final void Function(ValueType,String) _callback;

  Value(String name, this.type, this._callback) : super(name,false);

  set value(String val) {
    if(val == '/begin' || val == '/end') {
      throw ParsingException('A parsed value cannot be $val', '', 0);
    }
    _value = val;
    _valueSet = true;
    _callback(type,_value);
  }

  bool get valueSet => _valueSet;

  String get value => _value;

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
            parseRequiredOrderedElements(opts.mandatoryPositional, currentIndex+opts.mandatoryPositional.length);
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
          parseRequiredOrderedElements(token.values, currentIndex+token.values.length);
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

  void parseRequiredOrderedElements(List<Value> values, int max)
  {
    if ( values.length + currentIndex > max) {
      throw ParsingException('Token "$currentToken" has ${values.length} mandatory values! Only found ${max-currentIndex}', '', currentIndex);
    }

    for(var k=0; k<values.length; k++) {
      try {
        values[k].value = tokens[currentIndex+k];
      }
      catch (ex) {
        throw ParsingException('Token ${currentIndex+k} "${tokens[currentIndex+k]}" could not be converted to ${values[k]}', '', currentIndex+k);
      }
    }
    currentIndex += values.length;
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
        Value('VersionNo', ValueType.integer, (ValueType t, String s) {
          parsed.a2lMajorVersion = int.parse(s);
        }),
        Value('UpgradeNo', ValueType.integer, (ValueType t, String s) {
          parsed.a2lMinorVersion = int.parse(s);
        })
    ];
    var asap2MLVersionValues = <Value>[
        Value('VersionNo', ValueType.integer, (ValueType t, String s) {
          parsed.a2mlMajorVersion = int.parse(s);
        }),
        Value('UpgradeNo', ValueType.integer, (ValueType t, String s) {
          parsed.a2mlMinorVersion = int.parse(s);
        })
    ];

    
    var projectValues = <Value>[
        Value('Name', ValueType.id, (ValueType t, String s) {
          parsed.project.name = s;
        }),
        Value('LongIdentifier', ValueType.integer, (ValueType t, String s) {
          parsed.project.longName = removeQuotes(s);
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
      Value('Comment', ValueType.text, (ValueType t, String s) {
        print('setting comment to $s');
        parsed.project.comment = removeQuotes(s);
      })
    ], namedValues: [
      NamedValue(
          'VERSION',
          [
            Value('version number', ValueType.text, (ValueType t, String s) {
        print('setting version to $s');
              parsed.project.version = s;
            })
          ],
          optional: true),
      NamedValue(
          'PROJECT_NO',
          [
            Value('project number', ValueType.text, (ValueType t, String s) {
        print('setting num to $s');
              parsed.project.number = s;
            })
          ],
          optional: true),
    ], optional: true);

    var module = BlockElement('MODULE',(s,p) {
      var module = Module();
      p.project.modules.add(module);
      var values = [
        Value('Name', ValueType.id, (ValueType t, String s) {
        print("Setting name $s");
        module.name = s;
      }),
      Value('LongIdentifier', ValueType.text, (ValueType t, String s) {
        print("Setting desc $s");
        module.description = removeQuotes(s);
      })
      ];
      return A2LElementParsingOptions(module,values , createModuleChildren());
    },optional: false, unique: false);

    return [header,module];
  }


  List<BlockElement> createModuleChildren() {
    return [createUnit(), createMeasurement(), createComputeMethod()];
  }

  BlockElement createUnit() {
    return BlockElement('UNIT', (s, p) {
      if (p is Module) {
        var unit = Unit();
        p.units.add(unit);
        var values = [
          Value('Name', ValueType.id, (ValueType t, String s) {
            unit.name = s;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, String s) {
            unit.description = removeQuotes(s);
          }),
          Value('Display', ValueType.text, (ValueType t, String s) {
            unit.display = removeQuotes(s);
          }),
          Value('Type', ValueType.text, (ValueType t, String s) {
            if (s == 'DERIVED') {
              unit.type = UnitType.DERIVED;
            } else if (s == 'EXTENDED_SI') {
              unit.type = UnitType.EXTENDED_SI;
            } else {
              throw ParsingException('Unsupported unit type $s', '', 0);
            }
          })
        ];
        var optional = <A2LElement>[
          NamedValue('REF_UNIT', [
            Value('Unit', ValueType.id, (ValueType t, String s) {
              unit.referencedUnit = s;
            }),
          ], optional: true),
          NamedValue('SI_EXPONENTS', [
            Value('Length', ValueType.id, (ValueType t, String s) {
              unit.exponent_length = int.parse(s);
            }),
            Value('Mass', ValueType.id, (ValueType t, String s) {
              unit.exponent_mass = int.parse(s);
            }),
            Value('Time', ValueType.id, (ValueType t, String s) {
              unit.exponent_time = int.parse(s);
            }),
            Value('ElectricCurrent', ValueType.id, (ValueType t, String s) {
              unit.exponent_electricCurrent = int.parse(s);
            }),
            Value('Temperature', ValueType.id, (ValueType t, String s) {
              unit.exponent_temperature = int.parse(s);
            }),
            Value('AmountOfSubstance', ValueType.id, (ValueType t, String s) {
              unit.exponent_amountOfSubstance = int.parse(s);
            }),
            Value('LuminousIntensity', ValueType.id, (ValueType t, String s) {
              unit.exponent_luminousIntensity = int.parse(s);
            })
          ], optional: true),
          NamedValue('UNIT_CONVERSION', [
            Value('Slope', ValueType.id, (ValueType t, String s) {
              unit.conversionLinear_slope = double.parse(s);
            }),
            Value('Offset', ValueType.id, (ValueType t, String s) {
              unit.conversionLinear_offset = double.parse(s);
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

  BlockElement createMeasurement() {
    return BlockElement('MEASUREMENT', (s, p) {
      if (p is Module) {
        var measurement = Measurement();
        p.measurements.add(measurement);

        var values = [
          Value('Name', ValueType.id, (ValueType t, String s) {
            measurement.name = s;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, String s) {
            measurement.description = removeQuotes(s);
          }),
          Value('Datatype', ValueType.text, (ValueType t, String s) {
            measurement.datatype = dataTypeFromString(s);
          }),
          Value('Conversion', ValueType.text, (ValueType t, String s) {
            measurement.conversionMethod = s;
          }),
          Value('Resolution', ValueType.integer, (ValueType t, String s) {
            measurement.resolution = int.parse(s);
          }),
          Value('Accuracy', ValueType.floating, (ValueType t, String s) {
            measurement.accuracy = double.parse(s);
          }),
          Value('LowerLimit', ValueType.floating, (ValueType t, String s) {
            measurement.lowerLimit = double.parse(s);
          }),
          Value('UpperLimit', ValueType.floating, (ValueType t, String s) {
            measurement.upperLimit = double.parse(s);
          })
        ];

        var optional = <A2LElement>[
          NamedValue('ARRAY_SIZE', [
            Value('size', ValueType.integer, (ValueType t, String s) {
              measurement.arraySize = int.parse(s);
            })
          ], optional: true),
          NamedValue('BIT_MASK', [
            Value('mask', ValueType.integer, (ValueType t, String s) {
              measurement.bitMask = int.parse(s);
            })
          ], optional: true),
          NamedValue('BYTE_ORDER', [
            Value('order', ValueType.text, (ValueType t, String s) {
              measurement.endianess = byteOrderFromString(s);
            })
          ], optional: true),
          NamedValue('DISPLAY_IDENTIFIER', [
            Value('id', ValueType.text, (ValueType t, String s) {
              measurement.displayIdentifier = removeQuotes(s);
            })
          ], optional: true),
          NamedValue('ECU_ADDRESS', [
            Value('address', ValueType.integer, (ValueType t, String s) {
              measurement.address = int.parse(s);
            })
          ], optional: true),
          NamedValue('ECU_ADDRESS_EXTENSION', [
            Value('address extension', ValueType.integer, (ValueType t, String s) {
              measurement.addressExtension = int.parse(s);
            })
          ], optional: true),
          NamedValue('ERROR_MASK', [
            Value('error mask', ValueType.integer, (ValueType t, String s) {
              measurement.errorMask = int.parse(s);
            })
          ], optional: true),
          NamedValue('FORMAT', [
            Value('format', ValueType.text, (ValueType t, String s) {
              measurement.format = removeQuotes(s);
            })
          ], optional: true),
          NamedValue('LAYOUT', [
            Value('layout', ValueType.text, (ValueType t, String s) {
              measurement.layout = indexModeFromString(s);
            })
          ], optional: true),
          NamedValue('PHYS_UNIT', [
            Value('unit', ValueType.text, (ValueType t, String s) {
              measurement.unit = removeQuotes(s);
            })
          ], optional: true),
          NamedValue('REF_MEMORY_SEGMENT', [
            Value('segment', ValueType.text, (ValueType t, String s) {
              measurement.memorySegment = s;
            })
          ], optional: true)
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


  BlockElement createComputeMethod() {
    return BlockElement('COMPU_METHOD', (s, p) {
      if (p is Module) {
        var comp = ComputeMethod();
        p.computeMethods.add(comp);

        var values = [
          Value('Name', ValueType.id, (ValueType t, String s) {
            comp.name = s;
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, String s) {
            comp.description = removeQuotes(s);
          }),
          Value('ConversionType', ValueType.text, (ValueType t, String s) {
            comp.type = computeMethodTypeFromSting(s);
          }),
          Value('Format', ValueType.text, (ValueType t, String s) {
            comp.format = removeQuotes(s);
          }),
          Value('Unit', ValueType.text, (ValueType t, String s) {
            comp.unit = removeQuotes(s);
          }),
        ];

        var optional = <A2LElement>[
          NamedValue('COEFFS', [
            Value('a', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_a = double.parse(s);
            }),
            Value('b', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_b = double.parse(s);
            }),
            Value('c', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_c = double.parse(s);
            }),
            Value('d', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_d = double.parse(s);
            }),
            Value('e', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_e = double.parse(s);
            }),
            Value('f', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_f = double.parse(s);
            }),
          ], optional: true),
          NamedValue('COEFFS_LINEAR', [
            Value('a', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_a = double.parse(s);
            }),
            Value('b', ValueType.integer, (ValueType t, String s) {
              comp.coefficient_b = double.parse(s);
            }),
          ], optional: true),
          NamedValue('COMPU_TAB_REF', [
            Value('format', ValueType.id, (ValueType t, String s) {
              comp.referenced_table = s;
            })
          ], optional: true),
          NamedValue('FORMULA', [
            Value('forumla', ValueType.text, (ValueType t, String s) {
              comp.formula = removeQuotes(s);
            })
          ], optional: true),
          NamedValue('REF_UNIT', [
            Value('unit', ValueType.id, (ValueType t, String s) {
              comp.referenced_unit = s;
            })
          ], optional: true),
          NamedValue('STATUS_STRING_REF', [
            Value('segment', ValueType.id, (ValueType t, String s) {
              comp.referenced_statusString = s;
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
}
