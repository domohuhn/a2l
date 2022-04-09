import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'package:a2l/src/a2l_tree/record_layout.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse record layouts', (){
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

  });
}
