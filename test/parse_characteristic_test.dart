import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/characteristic.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse characteristic', (){
    test('Parse mandatory', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].stepSize, null);
    });

    test('Parse multiple', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', '/end', 'CHARACTERISTIC',
        '/begin','CHARACTERISTIC','TEST.CHAR2', '"This is a test char2"', 'VALUE', '0xCAFEBABE',
        'RL.MOO2', '100.25', 'CM_moo2', '-40.5', '66.5', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 2);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);
      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);
      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      
      expect(chara[1].name, 'TEST.CHAR2');
      expect(chara[1].description, 'This is a test char2');
      expect(chara[1].type, CharacteristicType.VALUE);
      expect(chara[1].address, 0xCAFEBABE);
      expect(chara[1].recordLayout, 'RL.MOO2');
      expect(chara[1].maxDiff, 100.25);
      expect(chara[1].conversionMethod, 'CM_moo2');
      expect(chara[1].lowerLimit, -40.5);
      expect(chara[1].upperLimit, 66.5);
      expect(chara[1].addressExtension, null);
      expect(chara[1].bitMask, null);
      expect(chara[1].displayIdentifier, null);
      expect(chara[1].endianess, null);
      expect(chara[1].format, null);
      expect(chara[1].memorySegment, null);
      expect(chara[1].discrete, false);
      expect(chara[1].readWrite, true);
      expect(chara[1].unit, null);
      expect(chara[1].matrixDim, null);
      expect(chara[1].maxRefresh, null);
      expect(chara[1].symbolLink, null);
      expect(chara[1].calibrationAccess, null);
      expect(chara[1].comparisionQuantity, null);
      expect(chara[1].dependentCharacteristics, null);
      expect(chara[1].extendedLimits, null);
      expect(chara[1].guardRails, false);
      expect(chara[1].mapList.length, 0);
      expect(chara[1].number, null);
      expect(chara[1].virtualCharacteristics, null);
    });

    test('Parse optional ECU_ADDRESS_EXTENSION', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'ECU_ADDRESS_EXTENSION', '25', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, 25);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });

    test('Parse optional BIT_MASK', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'BIT_MASK', '0xFFFFFFFF', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, 0xFFFFFFFF);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });

    test('Parse optional DISPLAY_IDENTIFIER', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'DISPLAY_IDENTIFIER', 'SOME.ID', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, 'SOME.ID');
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });

    test('Parse optional BYTE_ORDER', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'BYTE_ORDER', 'MSB_FIRST', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, ByteOrder.MSB_FIRST);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });



    test('Parse optional FORMAT', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'FORMAT', '"%7.3"', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, '%7.3');
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });

    test('Parse optional REF_MEMORY_SEGMENT', (){
     prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'REF_MEMORY_SEGMENT', 'Some.Segment', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, 'Some.Segment');
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });


    test('Parse optional DISCRETE', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'DISCRETE', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, true);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });

    
    test('Parse optional READ_ONLY', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'READ_ONLY', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, false);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });


    test('Parse optional PHYS_UNIT', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'PHYS_UNIT', '"[m]"', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, '[m]');
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
    });

    test('Parse optional ANNOTATION', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        '/begin', 'ANNOTATION', '/begin', 'ANNOTATION_TEXT', '"AA\\n"', '"BB\\n"', '"CC\\n"', '/end', 'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN', '"some origin"', 'ANNOTATION_LABEL', '"some label"', '/end', 'ANNOTATION', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      final annotations = chara[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
    });

    test('Parse optional STEP_SIZE', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 'STEP_SIZE', '3.5', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].stepSize, 3.5);
    });

    test('Parse optional NUMBER', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 'NUMBER', '12', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, 12);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].stepSize, null);
    });
    test('Parse optional COMPARISON_QUANTITY', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 'COMPARISON_QUANTITY', 'SomeQuant', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, 'SomeQuant');
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].stepSize, null);
    });

    test('Parse optional CALIBRATION_ACCESS', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 'CALIBRATION_ACCESS', 'CALIBRATION', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, CalibrationAccess.CALIBRATION);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].stepSize, null);
    });

    test('Parse optional EXTENDED_LIMITS', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 'EXTENDED_LIMITS', '0.5', '22.5', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, isNot(equals(null)));
      expect(chara[0].extendedLimits!.lowerLimit, 0.5);
      expect(chara[0].extendedLimits!.upperLimit, 22.5);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].stepSize, null);
    });

  //  [-> MAP_LIST]
    
    test('Parse optional VIRTUAL_CHARACTERISTIC', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        '/begin', 'VIRTUAL_CHARACTERISTIC', '"X1 + X2 + X3"', 'AAA', 'BBB', 'VVV', '/end', 'VIRTUAL_CHARACTERISTIC', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, isNot(equals(null)));
      expect(chara[0].virtualCharacteristics!.formula, 'X1 + X2 + X3');
      expect(chara[0].virtualCharacteristics!.characteristics.length, 3);
      expect(chara[0].virtualCharacteristics!.characteristics[0], 'AAA');
      expect(chara[0].virtualCharacteristics!.characteristics[1], 'BBB');
      expect(chara[0].virtualCharacteristics!.characteristics[2], 'VVV');
    });

    
    test('Parse optional DEPENDENT_CHARACTERISTIC', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        '/begin', 'DEPENDENT_CHARACTERISTIC', '"X1 + X2 + X3"', 'AAA', 'BBB', 'VVV', '/end', 'DEPENDENT_CHARACTERISTIC', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].dependentCharacteristics, isNot(equals(null)));
      expect(chara[0].dependentCharacteristics!.formula, 'X1 + X2 + X3');
      expect(chara[0].dependentCharacteristics!.characteristics.length, 3);
      expect(chara[0].dependentCharacteristics!.characteristics[0], 'AAA');
      expect(chara[0].dependentCharacteristics!.characteristics[1], 'BBB');
      expect(chara[0].dependentCharacteristics!.characteristics[2], 'VVV');
    });

    test('Parse optional FUNCTION_LIST', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        '/begin', 'FUNCTION_LIST', 'AAA', 'BBB', 'VVV', '/end', 'FUNCTION_LIST', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].functions.length, 3);
      expect(chara[0].functions[0], 'AAA');
      expect(chara[0].functions[1], 'BBB');
      expect(chara[0].functions[2], 'VVV');
    });


    test('Parse optional GUARD_RAILS', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'GUARD_RAILS', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, true);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].functions.length, 0);
    });

    test('Parse optional MATRIX_DIM', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'MATRIX_DIM', '2', '3', '4', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, isNot(equals(null)));
      expect(chara[0].matrixDim!.x, 2);
      expect(chara[0].matrixDim!.y, 3);
      expect(chara[0].matrixDim!.z, 4);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].functions.length, 0);
    });

    test('Parse optional MAX_REFRESH', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'MAX_REFRESH', '0', '2', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, isNot(equals(null)));
      expect(chara[0].maxRefresh!.scalingUnit, MaxRefreshUnit.time_1usec);
      expect(chara[0].maxRefresh!.rate, 2);
      expect(chara[0].symbolLink, null);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].functions.length, 0);
    });

    
    test('Parse optional SYMBOL_LINK', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF',
        'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5',
        'SYMBOL_LINK', '"_SYMBOL"', '42', '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].name, 'TEST.CHAR');
      expect(chara[0].description, 'This is a test char');
      expect(chara[0].type, CharacteristicType.ASCII);
      expect(chara[0].address, 0xDEADBEEF);
      expect(chara[0].recordLayout, 'RL.MOO');
      expect(chara[0].maxDiff, 110.25);
      expect(chara[0].conversionMethod, 'CM_moo');
      expect(chara[0].lowerLimit, -42.5);
      expect(chara[0].upperLimit, 54.5);

      expect(chara[0].addressExtension, null);
      expect(chara[0].bitMask, null);
      expect(chara[0].displayIdentifier, null);
      expect(chara[0].endianess, null);
      expect(chara[0].format, null);
      expect(chara[0].memorySegment, null);
      expect(chara[0].discrete, false);
      expect(chara[0].readWrite, true);
      expect(chara[0].unit, null);
      expect(chara[0].matrixDim, null);
      expect(chara[0].maxRefresh, null);
      expect(chara[0].symbolLink, isNot(equals(null)));
      expect(chara[0].symbolLink!.name, '_SYMBOL');
      expect(chara[0].symbolLink!.offset, 42);

      expect(chara[0].calibrationAccess, null);
      expect(chara[0].comparisionQuantity, null);
      expect(chara[0].dependentCharacteristics, null);
      expect(chara[0].extendedLimits, null);
      expect(chara[0].guardRails, false);
      expect(chara[0].mapList.length, 0);
      expect(chara[0].number, null);
      expect(chara[0].virtualCharacteristics, null);
      expect(chara[0].functions.length, 0);
    });

  });
}
