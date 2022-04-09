import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/a2l_file.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';
import 'package:a2l/src/a2l_tree/annotation.dart';

void main() {

  var parser = TokenParser();
  group('Parse measurements', (){
    test('Parse mandatory', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension, null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse multiple', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767', '/end', 'MEASUREMENT',
      '/begin','MEASUREMENT','test_measure2', '"This is a test measurement2"', 'UWORD', 'CM_moo2', '13', '2', '-32767', '32766', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 2);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension, null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);

      
      expect(file.project.modules[0].measurements[1].name, 'test_measure2');
      expect(file.project.modules[0].measurements[1].description, 'This is a test measurement2');
      expect(file.project.modules[0].measurements[1].datatype, Datatype.uint16);
      expect(file.project.modules[0].measurements[1].conversionMethod, 'CM_moo2');
      expect(file.project.modules[0].measurements[1].resolution, 13);
      expect(file.project.modules[0].measurements[1].accuracy, 2.0);
      expect(file.project.modules[0].measurements[1].lowerLimit, -32767);
      expect(file.project.modules[0].measurements[1].upperLimit, 32766);
      expect(file.project.modules[0].measurements[1].address, null);
      expect(file.project.modules[0].measurements[1].addressExtension, null);
      expect(file.project.modules[0].measurements[1].arraySize, null);
      expect(file.project.modules[0].measurements[1].bitMask, null);
      expect(file.project.modules[0].measurements[1].displayIdentifier, null);
      expect(file.project.modules[0].measurements[1].endianess, null);
      expect(file.project.modules[0].measurements[1].errorMask, null);
      expect(file.project.modules[0].measurements[1].format, null);
      expect(file.project.modules[0].measurements[1].layout, null);
      expect(file.project.modules[0].measurements[1].memorySegment, null);
      expect(file.project.modules[0].measurements[1].unit, null);
    });

    test('Parse optional ECU_ADDRESS', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'ECU_ADDRESS', '0x00000042', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, 0x42);
      expect(file.project.modules[0].measurements[0].addressExtension, null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional ECU_ADDRESS_EXTENSION', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'ECU_ADDRESS_EXTENSION', '0x00000042', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  0x42);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional ARRAY_SIZE', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'ARRAY_SIZE', '10', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, 10);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional BIT_MASK', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'BIT_MASK', '0xFFFFFFFF', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, 0xFFFFFFFF);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    


    test('Parse optional BYTE_ORDER', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'BYTE_ORDER', 'MSB_LAST', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, ByteOrder.MSB_LAST);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional ERROR_MASK', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'ERROR_MASK', '0xFFFFFFFF', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, 0xFFFFFFFF);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional FORMAT', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'FORMAT', '"%9.4"', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, '%9.4');
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional LAYOUT', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'LAYOUT', 'COLUMN_DIR', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, IndexMode.COLUMN_DIR);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional PHYS_UNIT', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'PHYS_UNIT', '"[m]"', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, '[m]');
    });

    test('Parse optional REF_MEMORY_SEGMENT', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        'REF_MEMORY_SEGMENT', 'Some.Segment', '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, 'Some.Segment');
      expect(file.project.modules[0].measurements[0].unit, null);
    });

    test('Parse optional ANNOTATION empty', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        '/begin', 'ANNOTATION', '/end', 'ANNOTATION',
        '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
      final annotations = file.project.modules[0].measurements[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, null);
      expect(annotations[0].origin, null);
      expect(annotations[0].text.length, 0);
    });

    test('Parse optional ANNOTATION', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        '/begin', 'ANNOTATION', '/begin', 'ANNOTATION_TEXT', '"AA\\n"', '"BB\\n"', '"CC\\n"', '/end', 'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN', '"some origin"', 'ANNOTATION_LABEL', '"some label"', '/end', 'ANNOTATION',
        '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
      final annotations = file.project.modules[0].measurements[0].annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
    });
    
    test('Parse optional ANNOTATION multiple', (){
      prepareTestData(parser, ['/begin','MEASUREMENT','test_measure', '"This is a test measurement"', 'SWORD', 'CM_moo', '12', '1', '-32768', '32767',
        '/begin', 'ANNOTATION', '/begin', 'ANNOTATION_TEXT', '"AA\\n"', '"BB\\n"', '"CC\\n"', '/end', 'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN', '"some origin"', 'ANNOTATION_LABEL', '"some label"', '/end', 'ANNOTATION',
        '/begin', 'ANNOTATION', 'ANNOTATION_LABEL', '"some label2"', '/begin', 'ANNOTATION_TEXT', '"AA2\\n"', '"BB2\\n"', '/end', 'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN', '"some origin2"',  '/end', 'ANNOTATION',
        '/end', 'MEASUREMENT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      expect(file.project.modules[0].measurements.length, 1);
      expect(file.project.modules[0].measurements[0].name, 'test_measure');
      expect(file.project.modules[0].measurements[0].description, 'This is a test measurement');
      expect(file.project.modules[0].measurements[0].datatype, Datatype.int16);
      expect(file.project.modules[0].measurements[0].conversionMethod, 'CM_moo');
      expect(file.project.modules[0].measurements[0].resolution, 12);
      expect(file.project.modules[0].measurements[0].accuracy, 1.0);
      expect(file.project.modules[0].measurements[0].lowerLimit, -32768);
      expect(file.project.modules[0].measurements[0].upperLimit, 32767);
      expect(file.project.modules[0].measurements[0].address, null);
      expect(file.project.modules[0].measurements[0].addressExtension,  null);
      expect(file.project.modules[0].measurements[0].arraySize, null);
      expect(file.project.modules[0].measurements[0].bitMask, null);
      expect(file.project.modules[0].measurements[0].displayIdentifier, null);
      expect(file.project.modules[0].measurements[0].endianess, null);
      expect(file.project.modules[0].measurements[0].errorMask, null);
      expect(file.project.modules[0].measurements[0].format, null);
      expect(file.project.modules[0].measurements[0].layout, null);
      expect(file.project.modules[0].measurements[0].memorySegment, null);
      expect(file.project.modules[0].measurements[0].unit, null);
      final annotations = file.project.modules[0].measurements[0].annotations;
      expect(annotations.length, 2);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
      
      expect(annotations[1].label, 'some label2');
      expect(annotations[1].origin, 'some origin2');
      expect(annotations[1].text.length, 2);
      expect(annotations[1].text[0], 'AA2\\n');
      expect(annotations[1].text[1], 'BB2\\n');
    });

  });
}
