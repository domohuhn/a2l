import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/axis_descr.dart';
import 'package:a2l/src/a2l_tree/axis_pts.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {
  // WARNING: TESTS in this file depend on the characteristics tests!

  var parser = TokenParser();
  group('Parse axis descr mandatory', (){
    test('one', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0','/end', 'AXIS_DESCR',
        '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].axisDescription.length, 1);
      final desc = chara[0].axisDescription[0];
      expect(desc.type, AxisType.standard);
      expect(desc.inputQuantity, 'QTY.IN');
      expect(desc.conversionMethod, 'CONV_AX');
      expect(desc.maxAxisPoints, 14);
      expect(desc.lowerLimit, 0.0);
      expect(desc.upperLimit, 5800.0);
      // optional defaults:
      expect(desc.annotations.length, 0);
      expect(desc.axisPoints, null);
      expect(desc.endianess, null);
      expect(desc.rescaleAxisPoints, null);
      expect(desc.depositMode, null);
      expect(desc.extendedLimits, null);
      expect(desc.fixedAxisPoints1, null);
      expect(desc.fixedAxisPoints2, null);
      expect(desc.ecuAxisPoints.length, 0);
      expect(desc.format, null);
      expect(desc.maxGradient, null);
      expect(desc.monotony, null);
      expect(desc.unit, null);
      expect(desc.readWrite, true);
      expect(desc.stepSize, null);
    });

    test('multiple', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0','/end', 'AXIS_DESCR',
        '/begin', 'AXIS_DESCR', 'CURVE_AXIS','QTY.IN2','CONV_AX2','15','1.0','5801.0','/end', 'AXIS_DESCR',
        '/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var chara = file.project.modules[0].characteristics;
      expect(chara.length, 1);
      expect(chara[0].axisDescription.length, 2);
      final desc = chara[0].axisDescription[0];
      expect(desc.type, AxisType.standard);
      expect(desc.inputQuantity, 'QTY.IN');
      expect(desc.conversionMethod, 'CONV_AX');
      expect(desc.maxAxisPoints, 14);
      expect(desc.lowerLimit, 0.0);
      expect(desc.upperLimit, 5800.0);
      
      final desc2 = chara[0].axisDescription[1];
      expect(desc2.type, AxisType.curve);
      expect(desc2.inputQuantity, 'QTY.IN2');
      expect(desc2.conversionMethod, 'CONV_AX2');
      expect(desc2.maxAxisPoints, 15);
      expect(desc2.lowerLimit, 1.0);
      expect(desc2.upperLimit, 5801.0);
    });
  });

  
  group('Parse axis descr optional', (){
    test('ANNOTATION', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        '/begin', 'ANNOTATION', '/begin', 'ANNOTATION_TEXT', '"AA\\n"', '"BB\\n"', '"CC\\n"', '/end', 'ANNOTATION_TEXT',
        'ANNOTATION_ORIGIN', '"some origin"', 'ANNOTATION_LABEL', '"some label"', '/end', 'ANNOTATION',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      final annotations = desc.annotations;
      expect(annotations.length, 1);
      expect(annotations[0].label, 'some label');
      expect(annotations[0].origin, 'some origin');
      expect(annotations[0].text.length, 3);
      expect(annotations[0].text[0], 'AA\\n');
      expect(annotations[0].text[1], 'BB\\n');
      expect(annotations[0].text[2], 'CC\\n');
    });

    test('AXIS_PTS_REF', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'AXIS_PTS_REF', 'CR_REF',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.axisPoints, 'CR_REF');
    });

    test('BYTE_ORDER', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'BYTE_ORDER', 'MSB_LAST',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.endianess, ByteOrder.MSB_LAST);
    });

    test('CURVE_AXIS_REF', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'CURVE_AXIS_REF', 'CR_REF',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.rescaleAxisPoints, 'CR_REF');
    });

    test('DEPOSIT', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'DEPOSIT', 'ABSOLUTE',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.depositMode, Deposit.ABSOLUTE);
    });

    test('EXTENDED_LIMITS', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'EXTENDED_LIMITS', '-500.0', '500.0',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.extendedLimits!.lowerLimit, -500.0);
      expect(desc.extendedLimits!.upperLimit, 500.0);
    });

    test('FIX_AXIS_PAR', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'FIX_AXIS_PAR', '8', '4', '7',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.fixedAxisPoints1!.p0, 8.0);
      expect(desc.fixedAxisPoints1!.p1, 16.0);
      expect(desc.fixedAxisPoints1!.max, 7);
    });

    test('FIX_AXIS_PAR_DIST', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'FIX_AXIS_PAR_DIST', '8', '16', '7',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.fixedAxisPoints2!.p0, 8.0);
      expect(desc.fixedAxisPoints2!.p1, 16.0);
      expect(desc.fixedAxisPoints2!.max, 7);
    });

    test('FIX_AXIS_PAR_LIST', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        '/begin', 'FIX_AXIS_PAR_LIST', '5.0', '225.0', '12780.0', '/end', 'FIX_AXIS_PAR_LIST',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.ecuAxisPoints.length, 3);
      expect(desc.ecuAxisPoints[0], 5.0);
      expect(desc.ecuAxisPoints[1], 225.0);
      expect(desc.ecuAxisPoints[2], 12780.0);
    });

    test('FORMAT', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'FORMAT', '"%9.7"',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.format, '%9.7');
    });

    test('MAX_GRAD', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'MAX_GRAD', '15.5',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.maxGradient, 15.5);
    });

    test('MONOTONY', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'MONOTONY', 'STRICT_DECREASE',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.monotony, Monotony.strictly_decreasing);
    });
    
    test('PHYS_UNIT', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'PHYS_UNIT', '"[m]"',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.unit, '[m]');
    });

    test('READ_ONLY', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'READ_ONLY',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.readWrite, false);
    });

    test('STEP_SIZE', (){
      prepareTestData(parser, ['/begin','CHARACTERISTIC','TEST.CHAR', '"This is a test char"', 'ASCII', '0xDEADBEEF', 'RL.MOO', '110.25', 'CM_moo', '-42.5', '54.5', 
        '/begin', 'AXIS_DESCR', 'STD_AXIS','QTY.IN','CONV_AX','14','0.0','5800.0',
        'STEP_SIZE', '0.5',
        '/end', 'AXIS_DESCR','/end', 'CHARACTERISTIC']);
      var file = parser.parse();
      final desc = file.project.modules[0].characteristics[0].axisDescription[0];
      expect(desc.stepSize, 0.5);
    });
  });
}
