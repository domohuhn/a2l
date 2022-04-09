import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'package:a2l/src/a2l_tree/compute_method.dart';
import 'package:a2l/src/a2l_tree/compute_table.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';
import 'package:a2l/src/a2l_tree/group.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/measurement.dart';
import 'package:a2l/src/a2l_tree/record_layout.dart';

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

/// Empty function, nneded for default argument.
void doNothing()
{
}


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
  NamedValue(String name, this.values, {bool optional=false, bool unique=true, void Function() callback=doNothing}) 
  : _callback=callback,
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
    //print("RECURSING $start $end");
    for (var i=start; i<end; ++i) {
      currentIndex = i;
      //print("= Token ${tokens[i]}");
      if (tokens[i]=='/begin') {
        //print("begin ${tokens[i+1]}");
        var limit = findMatchingEndToken();
        var expected = findExpected(tokens[i+1]);
        //print("$expected");
        if(expected!=null) {
          //print("expected ${expected.name}");
          if(expected is BlockElement){
            //print("is block");
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
        //print("new index $currentIndex");
        continue;
      }
      for(final token in expectedTokens) {
        if(token.name != tokens[i]) {
          continue;
        }
        if(token is NamedValue) {
          //print("named value $token");
          currentIndex = i+1;
          token.keyFound();
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
       //print("${token.name} == $nm");
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
    //print("Parse $currentIndex to ${max} : ${tokens[currentIndex]} to ${tokens[max-1]}");

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
    //print("Parse all $currentIndex to ${max} : ${tokens[currentIndex]} to ${tokens[max-1]}");

    try {
      while (currentIndex + values[k].requiredTokens <= max) {
        //print("$currentIndex to ${currentIndex+values[k].requiredTokens} : ${tokens[currentIndex]} to ${tokens[currentIndex+values[k].requiredTokens]}");
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
        //print('setting comment to ${s[0]}');
        parsed.project.comment = removeQuotes(s[0]);
      })
    ], namedValues: [
      NamedValue(
          'VERSION',
          [
            Value('version number', ValueType.text, (ValueType t, List<String> s) {
        //print('setting version to ${s[0]}');
              parsed.project.version = s[0];
            })
          ],
          optional: true),
      NamedValue(
          'PROJECT_NO',
          [
            Value('project number', ValueType.text, (ValueType t, List<String> s) {
        //print('setting num to $s');
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
        //print("Setting name $s");
        module.name = s[0];
      }),
      Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
        //print("Setting desc $s");
        module.description = removeQuotes(s[0]);
      })
      ];
      return A2LElementParsingOptions(module,values , createModuleChildren());
    },optional: false, unique: false);

    return [header,module];
  }


  List<BlockElement> createModuleChildren() {
    return [_createUnit(),
     _createMeasurement(),
     _createCharacteristic(),
     _createComputeMethod(),
     _createComputeTable(),
     _createComputeVerbatimTable(),
     _createComputeVerbatimRangeTable(),
     _createGroups(),
     _createRecordLayout()];
  }
  
  BlockElement _createRecordLayout() {
    return BlockElement('RECORD_LAYOUT', (s, p) {
      if(p is Module) {
        var rl = RecordLayout();
        p.recordLayouts.add(rl);
        
        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            rl.name = s[0];
          })];
        
        var optional = <A2LElement>[
          NamedValue('ALIGNMENT_BYTE', [Value('alignment', ValueType.integer, (ValueType t, List<String> s) { rl.aligmentInt8 = int.parse(s[0]); }), ], optional: true),
          NamedValue('ALIGNMENT_WORD', [Value('alignment', ValueType.integer, (ValueType t, List<String> s) { rl.aligmentInt16 = int.parse(s[0]); }), ], optional: true),
          NamedValue('ALIGNMENT_LONG', [Value('alignment', ValueType.integer, (ValueType t, List<String> s) { rl.aligmentInt32 = int.parse(s[0]); }), ], optional: true),
          NamedValue('ALIGNMENT_INT64', [Value('alignment', ValueType.integer, (ValueType t, List<String> s) { rl.aligmentInt64 = int.parse(s[0]); }), ], optional: true),
          NamedValue('ALIGNMENT_FLOAT32_IEEE', [Value('alignment', ValueType.integer, (ValueType t, List<String> s) { rl.aligmentFloat32 = int.parse(s[0]); }), ], optional: true),
          NamedValue('ALIGNMENT_FLOAT64_IEEE', [Value('alignment', ValueType.integer, (ValueType t, List<String> s) { rl.aligmentFloat64 = int.parse(s[0]); }), ], optional: true),
          NamedValue('FNC_VALUES', [
            Value('Position', ValueType.integer, (ValueType t, List<String> s) { rl.values ??= LayoutData(); rl.values!.position = int.parse(s[0]); }), 
            Value('Datatype', ValueType.text, (ValueType t, List<String> s) { rl.values!.type = dataTypeFromString(s[0]); }), 
            Value('IndexMode', ValueType.text, (ValueType t, List<String> s) { rl.values!.mode = indexModeFromString(s[0]); }), 
            Value('Addresstype', ValueType.text, (ValueType t, List<String> s) { rl.values!.addressType = addressTypeFromString(s[0]); }), 
          ], optional: true),
          
        ];
        return A2LElementParsingOptions(rl, values, optional);
      } else {
        throw ParsingException('Parse tree built wrong, parent of RECORD_LAYOUT must be module!', '', 0);
      }
    }
    , optional: true, unique: false);
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

  List<Value> _createSharedValuesMeasurementCharacteristicStart(MeasurementCharacteristicBase base) {
    var values = <Value>[
      Value('Name', ValueType.id, (ValueType t, List<String> s) {
        base.name = s[0];
      }),
      Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
        base.description = removeQuotes(s[0]);
      })
    ];
    return values;
  }

  List<Value> _createSharedValuesMeasurementCharacteristicEnd(MeasurementCharacteristicBase base) {
    var values = <Value>[
      Value('LowerLimit', ValueType.floating, (ValueType t, List<String> s) {
        base.lowerLimit = double.parse(s[0]);
      }),
      Value('UpperLimit', ValueType.floating, (ValueType t, List<String> s) {
        base.upperLimit = double.parse(s[0]);
      })
    ];
    return values;
  }
  
  List<A2LElement> _createSharedOptionalsMeasurementCharacteristic(MeasurementCharacteristicBase base) {
    var values = <A2LElement>[
      NamedValue('BIT_MASK', [
        Value('mask', ValueType.integer, (ValueType t, List<String> s) {
          base.bitMask = int.parse(s[0]);
        })
      ], optional: true),
      NamedValue('BYTE_ORDER', [
        Value('order', ValueType.text, (ValueType t, List<String> s) {
          base.endianess = byteOrderFromString(s[0]);
        })
      ], optional: true),
      NamedValue('DISCRETE',[], callback: () {base.discrete = true;}, optional: true),
      NamedValue('DISPLAY_IDENTIFIER', [
        Value('id', ValueType.text, (ValueType t, List<String> s) {
          base.displayIdentifier = removeQuotes(s[0]);
        })
      ], optional: true),
      NamedValue('ECU_ADDRESS_EXTENSION', [
        Value('address extension', ValueType.integer, (ValueType t, List<String> s) {
          base.addressExtension = int.parse(s[0]);
        })
      ], optional: true),
      NamedValue('FORMAT', [
        Value('format', ValueType.text, (ValueType t, List<String> s) {
          base.format = removeQuotes(s[0]);
        })
      ], optional: true),
      NamedValue('PHYS_UNIT', [
        Value('unit', ValueType.text, (ValueType t, List<String> s) {
          base.unit = removeQuotes(s[0]);
        })
      ], optional: true),
      NamedValue('REF_MEMORY_SEGMENT', [
        Value('segment', ValueType.text, (ValueType t, List<String> s) {
          base.memorySegment = s[0];
        })
      ], optional: true),
      NamedValue('SYMBOL_LINK', [
        Value('SymbolName', ValueType.text, (ValueType t, List<String> s) {
          base.symbolLink ??= SymbolLink();
          base.symbolLink!.name = removeQuotes(s[0]);
        }),
        Value('Offset', ValueType.integer, (ValueType t, List<String> s) {
          base.symbolLink!.offset = int.parse(s[0]);
        }),
      ], optional: true),
      NamedValue('MATRIX_DIM', [
        Value('Dimensions', ValueType.integer, (ValueType t, List<String> s) {
          base.matrixDim ??= MatrixDim();
          base.matrixDim!.x = int.parse(s[0]);
          base.matrixDim!.y = int.parse(s[1]);
          base.matrixDim!.z = int.parse(s[2]);
        }, requiredTokens: 3),
      ], optional: true),
      NamedValue('MAX_REFRESH', [
        Value('ScalingUnit', ValueType.integer, (ValueType t, List<String> s) {
          base.maxRefresh ??= MaxRefresh();
          base.maxRefresh!.scalingUnit = maxRefreshUnitFromString(s[0]);
        }),
        Value('Rate', ValueType.integer, (ValueType t, List<String> s) {
          base.maxRefresh!.rate = int.parse(s[0]);
        }),
      ], optional: true),
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
        ]);
        values.addAll(_createSharedValuesMeasurementCharacteristicEnd(measurement));

        var optional = _createSharedOptionalsMeasurementCharacteristic(measurement);
        optional.addAll(<A2LElement>[
          NamedValue('ARRAY_SIZE', [
            Value('size', ValueType.integer, (ValueType t, List<String> s) {
              measurement.arraySize = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('ECU_ADDRESS', [
            Value('address', ValueType.integer, (ValueType t, List<String> s) {
              measurement.address = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('ERROR_MASK', [
            Value('error mask', ValueType.integer, (ValueType t, List<String> s) {
              measurement.errorMask = int.parse(s[0]);
            })
          ], optional: true),
          NamedValue('LAYOUT', [
            Value('layout', ValueType.text, (ValueType t, List<String> s) {
              measurement.layout = indexModeFromString(s[0]);
            })
          ], optional: true),
          NamedValue('READ_WRITE',[], callback: () {measurement.readWrite = true;}, optional: true),
          _createBitOperation(),
          _createAnnotation(),
          _createFunctionList(),
          _createMeasurementsList(key: 'VIRTUAL')
        ]);
        return A2LElementParsingOptions(measurement, values, optional);
      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
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
          Value('Type', ValueType.text, (ValueType t, List<String> s) {
            char.type = characteristicTypeFromString(s[0]);
          }),
          Value('Address', ValueType.integer, (ValueType t, List<String> s) {
            char.address = int.parse(s[0]);
          }),
          Value('Deposit', ValueType.id, (ValueType t, List<String> s) {
            char.recordLayout =s[0];
          }),
          Value('MaxDiff', ValueType.floating, (ValueType t, List<String> s) {
            char.maxDiff = double.parse(s[0]);
          }),
          Value('Conversion', ValueType.id, (ValueType t, List<String> s) {
            char.conversionMethod = s[0];
          }),
        ]);
        values.addAll(_createSharedValuesMeasurementCharacteristicEnd(char));

        var optional = _createSharedOptionalsMeasurementCharacteristic(char);
        optional.addAll(<A2LElement>[
          NamedValue('READ_ONLY',[], callback: () {char.readWrite = false;}, optional: true),
          NamedValue('GUARD_RAILS',[], callback: () {char.guardRails = true;}, optional: true),
          NamedValue('STEP_SIZE',[Value('Step size', ValueType.floating, (p0, p1) { char.stepSize = double.parse(p1[0]); })], optional: true),
          NamedValue('NUMBER',[Value('number', ValueType.integer, (p0, p1) { char.number = int.parse(p1[0]); })], optional: true),
          NamedValue('COMPARISON_QUANTITY',[Value('COMPARISON_QUANTITY', ValueType.id, (p0, p1) { char.comparisionQuantity = p1[0]; })], optional: true),
          NamedValue('CALIBRATION_ACCESS',[Value('CALIBRATION_ACCESS', ValueType.text, (p0, p1) { char.calibrationAccess = calibrationAccessFromString(p1[0]); })], optional: true),
          NamedValue('EXTENDED_LIMITS',[Value('EXTENDED_LIMITS', ValueType.floating, (p0, p1) {
            char.extendedLimits ??= ExtendedLimits();
            char.extendedLimits!.lowerLimit = double.parse(p1[0]); 
            char.extendedLimits!.upperLimit = double.parse(p1[1]); 
          },requiredTokens: 2)], optional: true),
          _createAnnotation(),
          _createFunctionList(),
          _createVirtualCharacteristics(),
          _createVirtualCharacteristics(key: 'DEPENDENT_CHARACTERISTIC', virtual: false)
        ]);
        return A2LElementParsingOptions(char, values, optional);
      } else {
        throw ParsingException(
            'Parse tree built wrong, parent of MEASUREMENT must be module!',
            '',
            0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createVirtualCharacteristics({String key='VIRTUAL_CHARACTERISTIC', bool virtual=true}) {
    return BlockElement(key, (s, p) {
      if (p is Characteristic) {
        return A2LElementParsingOptions(p, [
                Value('Formula', ValueType.text, (ValueType t, List<String> s) {
                  if(virtual) {
                    p.virtualCharacteristics ??= DependentCharacteristics();
                    p.virtualCharacteristics!.formula= removeQuotes(s[0]);
                  } else {
                    p.dependentCharacteristics ??= DependentCharacteristics();
                    p.dependentCharacteristics!.formula= removeQuotes(s[0]);
                  }
                }),
                Value('Characteristics id', ValueType.id, (ValueType t, List<String> s) {
                  if(virtual) {
                    p.virtualCharacteristics!.characteristics.add(s[0]);
                  } else {
                    p.dependentCharacteristics!.characteristics.add(s[0]);;
                  }
                }, multiplicity: -1)], []);
      } else {
        throw ParsingException('Parse tree built wrong, parent of $key must be derived from Characteristic!','', 0);
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

  BlockElement _createBitOperation() {
    return BlockElement('BIT_OPERATION', (s, p) {
      if (p is Measurement) {
        p.bitOperation = BitOperation();

        var optional = <A2LElement>[
          NamedValue('LEFT_SHIFT', [
            Value('LEFT_SHIFT', ValueType.text, (ValueType t, List<String> s) {
              p.bitOperation!.leftShift = int.parse(s[0]);
            }),
          ], optional: true),
          NamedValue('RIGHT_SHIFT', [
            Value('RIGHT_SHIFT', ValueType.text, (ValueType t, List<String> s) {
              p.bitOperation!.rightShift = int.parse(s[0]);
            }),
          ], optional: true),
          NamedValue('SIGN_EXTEND', [], callback: () => p.bitOperation!.signExtend = true, optional: true)
        ];
        return A2LElementParsingOptions(p, [], optional);
      } else {
        throw ParsingException('Parse tree built wrong, parent of ANNOTATION must be derived from AnnotationContainer!','', 0);
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

  
  BlockElement _createFunctionList() {
    return BlockElement('FUNCTION_LIST', (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
                Value('Function id', ValueType.text, (ValueType t, List<String> s) {
                  p.functions.add(s[0]);
                }, multiplicity: -1)], []);
      } else {
        throw ParsingException('Parse tree built wrong, parent of FUNCTION_LIST must be derived from DataContainer!','', 0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createCharacteristicsList({String key='REF_CHARACTERISTIC'}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
                Value('Characteristics id', ValueType.text, (ValueType t, List<String> s) {
                  p.characteristics.add(s[0]);
                }, multiplicity: -1)], []);
      } else {
        throw ParsingException('Parse tree built wrong, parent of $key must be derived from DataContainer!','', 0);
      }
    }, optional: true, unique: false);
  }
  
  BlockElement _createMeasurementsList({String key='REF_MEASUREMENT'}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
                Value('Measurements id', ValueType.text, (ValueType t, List<String> s) {
                  p.measurements.add(s[0]);
                }, multiplicity: -1)], []);
      } else {
        throw ParsingException('Parse tree built wrong, parent of $key must be derived from DataContainer!','', 0);
      }
    }, optional: true, unique: false);
  }

  BlockElement _createGroupList({String key='SUB_GROUP'}) {
    return BlockElement(key, (s, p) {
      if (p is DataContainer) {
        return A2LElementParsingOptions(p, [
                Value('Group id', ValueType.text, (ValueType t, List<String> s) {
                  p.groups.add(s[0]);
                }, multiplicity: -1)], []);
      } else {
        throw ParsingException('Parse tree built wrong, parent of $key must be derived from DataContainer!','', 0);
      }
    }, optional: true, unique: false);
  }
  
  BlockElement _createGroups() {
    return BlockElement('GROUP', (s, p) {
      if (p is Module) {
        var grp = Group();
        p.groups.add(grp);

        var values = [
          Value('Name', ValueType.id, (ValueType t, List<String> s) {
            grp.name = s[0];
          }),
          Value('LongIdentifier', ValueType.text, (ValueType t, List<String> s) {
            grp.description = removeQuotes(s[0]);
          })
        ];

        var optional = <A2LElement>[
          _createAnnotation(),
          _createFunctionList(),
          _createCharacteristicsList(),
          _createMeasurementsList(),
          _createGroupList(),
          NamedValue('ROOT', [], optional: true, unique: true, callback: (){grp.root = true;})
        ];
        return A2LElementParsingOptions(grp, values, optional);
      } else {
        throw ParsingException('Parse tree built wrong, parent of GROUP must be module!','', 0);
      }
    }, optional: true, unique: false);
  }
}
