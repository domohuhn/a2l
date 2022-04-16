import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/record_layout.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse record layouts mandatory', (){
    test('Parse mandatory', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL', '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
      expect(rls[0].staticRecordLayout, false);
      expect(rls[0].reserved.length, 0);
    });

    test('Parse mandatory multiple', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL', '/end', 'RECORD_LAYOUT',
      '/begin','RECORD_LAYOUT','TEST.RL2', '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 2);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
      
      expect(rls[1].name, 'TEST.RL2');
      expect(rls[1].aligmentFloat32, null);
      expect(rls[1].aligmentFloat64, null);
      expect(rls[1].aligmentInt8, null);
      expect(rls[1].aligmentInt16, null);
      expect(rls[1].aligmentInt32, null);
      expect(rls[1].aligmentInt64, null);
      expect(rls[1].values, null);
    });
  });

  group('Parse record layouts optional', (){
    test('Parse optional FNC_VALUES', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'FNC_VALUES', '1', 'SWORD', 'ROW_DIR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, isNot(equals(null)));
      expect(rls[0].values!.position, 1);
      expect(rls[0].values!.type, Datatype.int16);
      expect(rls[0].values!.mode, IndexMode.ROW_DIR);
      expect(rls[0].values!.addressType, AddressType.DIRECT);
    });

    
    test('Parse optional ALIGNMENT_BYTE', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'ALIGNMENT_BYTE', '11',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, 11);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
    });

    test('Parse optional ALIGNMENT_LONG', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'ALIGNMENT_LONG', '11',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, 11);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
    });

    test('Parse optional ALIGNMENT_WORD', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'ALIGNMENT_WORD', '11',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, 11);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
    });

    test('Parse optional ALIGNMENT_INT64', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'ALIGNMENT_INT64', '13',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, 13);
      expect(rls[0].values, null);
    });

    test('Parse optional ALIGNMENT_FLOAT32_IEEE', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'ALIGNMENT_FLOAT32_IEEE', '5',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, 5);
      expect(rls[0].aligmentFloat64, null);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
    });

    test('Parse optional ALIGNMENT_INT64', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'ALIGNMENT_FLOAT64_IEEE', '7',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].aligmentFloat32, null);
      expect(rls[0].aligmentFloat64, 7);
      expect(rls[0].aligmentInt8, null);
      expect(rls[0].aligmentInt16, null);
      expect(rls[0].aligmentInt32, null);
      expect(rls[0].aligmentInt64, null);
      expect(rls[0].values, null);
    });

    test('Parse optional AXIS_PTS_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_PTS_X', '7', 'SWORD', 'INDEX_INCR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisPointsX!.position, 7);
      expect(rls[0].axisPointsX!.type, Datatype.int16);
      expect(rls[0].axisPointsX!.addressType, AddressType.DIRECT);
      expect(rls[0].axisPointsX!.order, IndexOrder.INDEX_INCR);
    });

    test('Parse optional AXIS_PTS_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_PTS_Y', '2', 'SLONG', 'INDEX_DECR', 'PLONG',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisPointsY!.position, 2);
      expect(rls[0].axisPointsY!.type, Datatype.int32);
      expect(rls[0].axisPointsY!.addressType, AddressType.PLONG);
      expect(rls[0].axisPointsY!.order, IndexOrder.INDEX_DECR);
    });

    test('Parse optional AXIS_PTS_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_PTS_Z', '2', 'SLONG', 'INDEX_DECR', 'PWORD',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisPointsZ!.position, 2);
      expect(rls[0].axisPointsZ!.type, Datatype.int32);
      expect(rls[0].axisPointsZ!.addressType, AddressType.PWORD);
      expect(rls[0].axisPointsZ!.order, IndexOrder.INDEX_DECR);
    });

    test('Parse optional AXIS_PTS_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_PTS_4', '2', 'SBYTE', 'INDEX_DECR', 'PBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisPoints4!.position, 2);
      expect(rls[0].axisPoints4!.type, Datatype.int8);
      expect(rls[0].axisPoints4!.addressType, AddressType.PBYTE);
      expect(rls[0].axisPoints4!.order, IndexOrder.INDEX_DECR);
    });

    test('Parse optional AXIS_PTS_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_PTS_5', '2', 'A_INT64', 'INDEX_DECR', 'PLONG',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisPoints5!.position, 2);
      expect(rls[0].axisPoints5!.type, Datatype.int64);
      expect(rls[0].axisPoints5!.addressType, AddressType.PLONG);
      expect(rls[0].axisPoints5!.order, IndexOrder.INDEX_DECR);
    });

    test('Parse optional AXIS_RESCALE_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_RESCALE_X', '3', 'UBYTE', '5', 'INDEX_INCR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisRescaleX!.position, 3);
      expect(rls[0].axisRescaleX!.type, Datatype.uint8);
      expect(rls[0].axisRescaleX!.maxNumberOfPairs, 5);
      expect(rls[0].axisRescaleX!.order, IndexOrder.INDEX_INCR);
      expect(rls[0].axisRescaleX!.addressType, AddressType.DIRECT);
    });

    test('Parse optional AXIS_RESCALE_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_RESCALE_Y', '3', 'UWORD', '5', 'INDEX_INCR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisRescaleY!.position, 3);
      expect(rls[0].axisRescaleY!.type, Datatype.uint16);
      expect(rls[0].axisRescaleY!.maxNumberOfPairs, 5);
      expect(rls[0].axisRescaleY!.order, IndexOrder.INDEX_INCR);
      expect(rls[0].axisRescaleY!.addressType, AddressType.DIRECT);
    });

    test('Parse optional AXIS_RESCALE_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_RESCALE_Z', '3', 'ULONG', '5', 'INDEX_INCR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisRescaleZ!.position, 3);
      expect(rls[0].axisRescaleZ!.type, Datatype.uint32);
      expect(rls[0].axisRescaleZ!.maxNumberOfPairs, 5);
      expect(rls[0].axisRescaleZ!.order, IndexOrder.INDEX_INCR);
      expect(rls[0].axisRescaleZ!.addressType, AddressType.DIRECT);
    });

    test('Parse optional AXIS_RESCALE_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_RESCALE_4', '3', 'A_UINT64', '5', 'INDEX_INCR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisRescale4!.position, 3);
      expect(rls[0].axisRescale4!.type, Datatype.uint64);
      expect(rls[0].axisRescale4!.maxNumberOfPairs, 5);
      expect(rls[0].axisRescale4!.order, IndexOrder.INDEX_INCR);
      expect(rls[0].axisRescale4!.addressType, AddressType.DIRECT);
    });

    test('Parse optional AXIS_RESCALE_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'AXIS_RESCALE_5', '3', 'A_UINT64', '5', 'INDEX_INCR', 'DIRECT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].axisRescale5!.position, 3);
      expect(rls[0].axisRescale5!.type, Datatype.uint64);
      expect(rls[0].axisRescale5!.maxNumberOfPairs, 5);
      expect(rls[0].axisRescale5!.order, IndexOrder.INDEX_INCR);
      expect(rls[0].axisRescale5!.addressType, AddressType.DIRECT);
    });

    test('Parse optional DIST_OP_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'DIST_OP_X', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].distanceX!.position, 3);
      expect(rls[0].distanceX!.type, Datatype.uint8);
    });

    test('Parse optional DIST_OP_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'DIST_OP_Y', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].distanceY!.position, 3);
      expect(rls[0].distanceY!.type, Datatype.uint8);
    });

    test('Parse optional DIST_OP_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'DIST_OP_Z', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].distanceZ!.position, 3);
      expect(rls[0].distanceZ!.type, Datatype.uint8);
    });

    test('Parse optional DIST_OP_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'DIST_OP_4', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].distance4!.position, 3);
      expect(rls[0].distance4!.type, Datatype.uint8);
    });

    test('Parse optional DIST_OP_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'DIST_OP_5', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].distance5!.position, 3);
      expect(rls[0].distance5!.type, Datatype.uint8);
    });

    test('Parse optional FIX_NO_AXIS_PTS_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'FIX_NO_AXIS_PTS_X', '3',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].fixedNumberOfAxisPointsX, 3);
    });

    test('Parse optional FIX_NO_AXIS_PTS_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'FIX_NO_AXIS_PTS_Y', '3',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].fixedNumberOfAxisPointsY, 3);
    });

    test('Parse optional FIX_NO_AXIS_PTS_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'FIX_NO_AXIS_PTS_Z', '3',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].fixedNumberOfAxisPointsZ, 3);
    });

    test('Parse optional FIX_NO_AXIS_PTS_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'FIX_NO_AXIS_PTS_4', '3',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].fixedNumberOfAxisPoints4, 3);
    });
  
    test('Parse optional FIX_NO_AXIS_PTS_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'FIX_NO_AXIS_PTS_5', '3',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].fixedNumberOfAxisPoints5, 3);
    });

    test('Parse optional IDENTIFICATION', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'IDENTIFICATION', '2', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].identification!.position, 2);
      expect(rls[0].identification!.type, Datatype.uint8);
    });

    test('Parse optional NO_RESCALE_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'NO_RESCALE_X', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].numberOfRescalePointsX!.position, 3);
      expect(rls[0].numberOfRescalePointsX!.type, Datatype.uint8);
    });

    test('Parse optional NO_RESCALE_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'NO_RESCALE_Y', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].numberOfRescalePointsY!.position, 3);
      expect(rls[0].numberOfRescalePointsY!.type, Datatype.uint8);
    });

    test('Parse optional NO_RESCALE_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'NO_RESCALE_Z', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].numberOfRescalePointsZ!.position, 3);
      expect(rls[0].numberOfRescalePointsZ!.type, Datatype.uint8);
    });

    test('Parse optional NO_RESCALE_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'NO_RESCALE_4', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].numberOfRescalePoints4!.position, 3);
      expect(rls[0].numberOfRescalePoints4!.type, Datatype.uint8);
    });

    test('Parse optional NO_RESCALE_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'NO_RESCALE_5', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].numberOfRescalePoints5!.position, 3);
      expect(rls[0].numberOfRescalePoints5!.type, Datatype.uint8);
    });

    test('Parse optional OFFSET_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'OFFSET_X', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].offsetX!.position, 3);
      expect(rls[0].offsetX!.type, Datatype.uint8);
    });

    test('Parse optional OFFSET_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'OFFSET_Y', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].offsetY!.position, 3);
      expect(rls[0].offsetY!.type, Datatype.uint8);
    });

    test('Parse optional OFFSET_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'OFFSET_Z', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].offsetZ!.position, 3);
      expect(rls[0].offsetZ!.type, Datatype.uint8);
    });

    test('Parse optional OFFSET_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'OFFSET_4', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].offset4!.position, 3);
      expect(rls[0].offset4!.type, Datatype.uint8);
    });

    test('Parse optional OFFSET_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'OFFSET_5', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].offset5!.position, 3);
      expect(rls[0].offset5!.type, Datatype.uint8);
    });

    test('Parse optional RIP_ADDR_W', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RIP_ADDR_W', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].output!.position, 3);
      expect(rls[0].output!.type, Datatype.uint8);
    });

    test('Parse optional RIP_ADDR_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RIP_ADDR_X', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].intermediateX!.position, 3);
      expect(rls[0].intermediateX!.type, Datatype.uint8);
    });

    test('Parse optional RIP_ADDR_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RIP_ADDR_Y', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].intermediateY!.position, 3);
      expect(rls[0].intermediateY!.type, Datatype.uint8);
    });

    test('Parse optional RIP_ADDR_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RIP_ADDR_Z', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].intermediateZ!.position, 3);
      expect(rls[0].intermediateZ!.type, Datatype.uint8);
    });

    test('Parse optional RIP_ADDR_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RIP_ADDR_4', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].intermediate4!.position, 3);
      expect(rls[0].intermediate4!.type, Datatype.uint8);
    });

    test('Parse optional RIP_ADDR_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RIP_ADDR_5', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].intermediate5!.position, 3);
      expect(rls[0].intermediate5!.type, Datatype.uint8);
    });

    test('Parse optional SRC_ADDR_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SRC_ADDR_X', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].inputX!.position, 3);
      expect(rls[0].inputX!.type, Datatype.uint8);
    });

    test('Parse optional SRC_ADDR_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SRC_ADDR_Y', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].inputY!.position, 3);
      expect(rls[0].inputY!.type, Datatype.uint8);
    });

    test('Parse optional SRC_ADDR_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SRC_ADDR_Z', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].inputZ!.position, 3);
      expect(rls[0].inputZ!.type, Datatype.uint8);
    });

    test('Parse optional SRC_ADDR_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SRC_ADDR_4', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].input4!.position, 3);
      expect(rls[0].input4!.type, Datatype.uint8);
    });

    test('Parse optional SRC_ADDR_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SRC_ADDR_5', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].input5!.position, 3);
      expect(rls[0].input5!.type, Datatype.uint8);
    });

    test('Parse optional SHIFT_OP_X', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SHIFT_OP_X', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].shiftX!.position, 3);
      expect(rls[0].shiftX!.type, Datatype.uint8);
    });

    test('Parse optional SHIFT_OP_Y', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SHIFT_OP_Y', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].shiftY!.position, 3);
      expect(rls[0].shiftY!.type, Datatype.uint8);
    });

    test('Parse optional SHIFT_OP_Z', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SHIFT_OP_Z', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].shiftZ!.position, 3);
      expect(rls[0].shiftZ!.type, Datatype.uint8);
    });

    test('Parse optional SHIFT_OP_4', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SHIFT_OP_4', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].shift4!.position, 3);
      expect(rls[0].shift4!.type, Datatype.uint8);
    });

    test('Parse optional SHIFT_OP_5', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'SHIFT_OP_5', '3', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].shift5!.position, 3);
      expect(rls[0].shift5!.type, Datatype.uint8);
    });

    test('Parse optional STATIC_RECORD_LAYOUT', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'STATIC_RECORD_LAYOUT',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].staticRecordLayout, true);
    });

    test('Parse optional RESERVED', (){
      prepareTestData(parser, ['/begin','RECORD_LAYOUT','TEST.RL',
       'RESERVED', '1', 'UBYTE',
       'RESERVED', '2', 'UBYTE',
       '/end', 'RECORD_LAYOUT']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var rls = file.project.modules[0].recordLayouts;
      expect(rls.length, 1);
      expect(rls[0].name, 'TEST.RL');
      expect(rls[0].reserved.length, 2);
      expect(rls[0].reserved[0].position, 1);
      expect(rls[0].reserved[0].type, Datatype.uint8);
      expect(rls[0].reserved[1].position, 2);
      expect(rls[0].reserved[1].type, Datatype.uint8);
    });
  });

}
