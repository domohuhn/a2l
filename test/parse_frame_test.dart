import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/a2l_tree/base_types.dart';
import 'prepare_test_data.dart';
import 'package:test/test.dart';

void main() {

  var parser = TokenParser();
  group('Parse frames mandatory', (){
    test('one', (){
      prepareTestData(parser, ['/begin','FRAME','TEST.FRAME', '"This is a test frame"', '3', '2', '/end', 'FRAME']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var frames = file.project.modules[0].frames;
      expect(frames.length, 1);
      expect(frames[0].name, 'TEST.FRAME');
      expect(frames[0].description, 'This is a test frame');
      expect(frames[0].scalingUnit, MaxRefreshUnit.time_1msec);
      expect(frames[0].rate, 2);
      expect(frames[0].measurements.length, 0);
    });

    test('multiple', (){
      prepareTestData(parser, ['/begin','FRAME','TEST.FRAME', '"This is a test frame"', '3', '2', '/end', 'FRAME',
      '/begin','FRAME','TEST.FRAME2', '"This is a test frame2"', '3', '4', '/end', 'FRAME']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var frames = file.project.modules[0].frames;
      expect(frames.length, 2);
      expect(frames[0].name, 'TEST.FRAME');
      expect(frames[0].description, 'This is a test frame');
      expect(frames[0].scalingUnit, MaxRefreshUnit.time_1msec);
      expect(frames[0].rate, 2);
      expect(frames[0].measurements.length, 0);

      expect(frames[1].name, 'TEST.FRAME2');
      expect(frames[1].description, 'This is a test frame2');
      expect(frames[1].scalingUnit, MaxRefreshUnit.time_1msec);
      expect(frames[1].rate, 4);
      expect(frames[1].measurements.length, 0);
    });

  });

  
  group('Parse frames optional', (){
    test('FRAME_MEASUREMENT', (){
      prepareTestData(parser, ['/begin','FRAME','TEST.FRAME', '"This is a test frame"', '3', '2',
        'FRAME_MEASUREMENT', 'AAA', 'BBB', 'CCC', '/end', 'FRAME']);
      var file = parser.parse();
      expect(file.project.modules.length, 1);
      var frames = file.project.modules[0].frames;
      expect(frames.length, 1);
      expect(frames[0].name, 'TEST.FRAME');
      expect(frames[0].description, 'This is a test frame');
      expect(frames[0].scalingUnit, MaxRefreshUnit.time_1msec);
      expect(frames[0].rate, 2);
      expect(frames[0].measurements.length, 3);
      expect(frames[0].measurements[0], 'AAA');
      expect(frames[0].measurements[1], 'BBB');
      expect(frames[0].measurements[2], 'CCC');
    });
  });
}
