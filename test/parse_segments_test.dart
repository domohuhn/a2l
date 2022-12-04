import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/memory_layout.dart';
import 'package:a2l/src/a2l_tree/memory_segment.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  var parser = TokenParser();
  group('Parse mandatory memory layout', () {
    test('Parse one', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_PAR',
        '"Description of pars module pars"',
        '/begin',
        'MEMORY_LAYOUT',
        'PRG_DATA',
        '0x42',
        '0x10',
        '1',
        '2',
        '3',
        '4',
        '0x100',
        '/begin', 'IF_DATA', 'somedata', '/end', 'IF_DATA',
        '/end', 'MEMORY_LAYOUT',
        '/end', 'MOD_PAR'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.memoryLayouts.length, 1);
      var data = pars.memoryLayouts;
      expect(data[0].type, MemoryLayoutType.PRG_DATA);
      expect(data[0].address, 0x42);
      expect(data[0].size, 0x10);
      expect(data[0].isValid, true);
      expect(data[0].offsets.length, 5);
      expect(data[0].offsets[0], 1);
      expect(data[0].offsets[1], 2);
      expect(data[0].offsets[2], 3);
      expect(data[0].offsets[3], 4);
      expect(data[0].offsets[4], 0x100);
      expect(data[0].interfaceData.length, 1);
      expect(data[0].interfaceData[0], 'somedata');
      expect(data[0].toFileContents(0).contains('/begin IF_DATA'), true);
    });

    test('Parse multiple', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_PAR',
        '"Description of pars module pars"',
        '/begin',
        'MEMORY_LAYOUT',
        'PRG_CODE',
        '0x42',
        '0x10',
        '-1',
        '-1',
        '-1',
        '-1',
        '-1',
        '/end',
        'MEMORY_LAYOUT',
        '/begin',
        'MEMORY_LAYOUT',
        'PRG_RESERVED',
        '0x84',
        '0x20',
        '-1',
        '-1',
        '-1',
        '-1',
        '-1',
        '/end',
        'MEMORY_LAYOUT',
        '/end',
        'MOD_PAR'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.memoryLayouts.length, 2);
      var data = pars.memoryLayouts;
      expect(data[0].type, MemoryLayoutType.PRG_CODE);
      expect(data[0].address, 0x42);
      expect(data[0].size, 0x10);
      expect(data[0].isValid, true);
      expect(data[0].offsets.length, 5);
      expect(data[0].offsets[0], -1);
      expect(data[0].offsets[1], -1);
      expect(data[0].offsets[2], -1);
      expect(data[0].offsets[3], -1);
      expect(data[0].offsets[4], -1);
      expect(data[0].toFileContents(0).contains('/begin IF_DATA'), false);

      expect(data[1].type, MemoryLayoutType.PRG_RESERVED);
      expect(data[1].address, 0x84);
      expect(data[1].size, 0x20);
      expect(data[1].isValid, true);
      expect(data[1].offsets.length, 5);
      expect(data[1].offsets[0], -1);
      expect(data[1].offsets[1], -1);
      expect(data[1].offsets[2], -1);
      expect(data[1].offsets[3], -1);
      expect(data[1].offsets[4], -1);
    });
  });

  group('Parse mandatory memory segment', () {
    test('Parse one', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_PAR',
        '"Description of pars module pars"',
        '/begin',
        'MEMORY_SEGMENT',
        'SEG',
        '"This is a description"',
        'OFFLINE_DATA',
        'RAM',
        'INTERN',
        '0x42',
        '0x10',
        '1',
        '2',
        '3',
        '4',
        '0x100',
        '/begin', 'IF_DATA', 'somedata', '/end', 'IF_DATA',
        '/end',
        'MEMORY_SEGMENT',
        '/end',
        'MOD_PAR'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.memorySegments.length, 1);
      var data = pars.memorySegments;
      expect(data[0].name, 'SEG');
      expect(data[0].description, 'This is a description');
      expect(data[0].type, SegmentType.OFFLINE_DATA);
      expect(data[0].memoryType, MemoryType.RAM);
      expect(data[0].attribute, SegmentAttribute.INTERN);
      expect(data[0].address, 0x42);
      expect(data[0].size, 0x10);
      expect(data[0].isValid, true);
      expect(data[0].offsets.length, 5);
      expect(data[0].offsets[0], 1);
      expect(data[0].offsets[1], 2);
      expect(data[0].offsets[2], 3);
      expect(data[0].offsets[3], 4);
      expect(data[0].offsets[4], 0x100);
      expect(data[0].interfaceData.length, 1);
      expect(data[0].interfaceData[0], 'somedata');
      expect(data[0].toFileContents(0).contains('/begin IF_DATA'), true);
    });

    test('Parse multiple', () {
      prepareTestData(parser, [
        '/begin',
        'MOD_PAR',
        '"Description of pars module pars"',
        '/begin',
        'MEMORY_SEGMENT',
        'SEG',
        '"This is a description"',
        'DATA',
        'EPROM',
        'INTERN',
        '0x42',
        '0x10',
        '-1',
        '-1',
        '-1',
        '-1',
        '-1',
        '/end',
        'MEMORY_SEGMENT',
        '/begin',
        'MEMORY_SEGMENT',
        'SEG2',
        '"This is a description2"',
        'CODE',
        'FLASH',
        'EXTERN',
        '0x84',
        '0x20',
        '-1',
        '-1',
        '-1',
        '-1',
        '-1',
        '/end',
        'MEMORY_SEGMENT',
        '/end',
        'MOD_PAR'
      ]);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var pars = file.project.modules[0].parameters!;
      expect(pars.memorySegments.length, 2);
      var data = pars.memorySegments;
      expect(data[0].name, 'SEG');
      expect(data[0].description, 'This is a description');
      expect(data[0].type, SegmentType.DATA);
      expect(data[0].memoryType, MemoryType.EPROM);
      expect(data[0].attribute, SegmentAttribute.INTERN);
      expect(data[0].address, 0x42);
      expect(data[0].size, 0x10);
      expect(data[0].isValid, true);
      expect(data[0].offsets.length, 5);
      expect(data[0].offsets[0], -1);
      expect(data[0].offsets[1], -1);
      expect(data[0].offsets[2], -1);
      expect(data[0].offsets[3], -1);
      expect(data[0].offsets[4], -1);
      expect(data[0].toFileContents(0).contains('/begin IF_DATA'), false);

      expect(data[1].name, 'SEG2');
      expect(data[1].description, 'This is a description2');
      expect(data[1].type, SegmentType.CODE);
      expect(data[1].memoryType, MemoryType.FLASH);
      expect(data[1].attribute, SegmentAttribute.EXTERN);
      expect(data[1].address, 0x84);
      expect(data[1].size, 0x20);
      expect(data[1].isValid, true);
      expect(data[1].offsets.length, 5);
      expect(data[1].offsets[0], -1);
      expect(data[1].offsets[1], -1);
      expect(data[1].offsets[2], -1);
      expect(data[1].offsets[3], -1);
      expect(data[1].offsets[4], -1);
    });
  });
}
