import 'package:a2l/src/a2l_parser.dart';

/// Prepares test data by resetting the [parser] position and inserting the [data] block into a valid module.
/// 
void prepareTestData(TokenParser parser, List<String> data) {
  parser.currentIndex = 0;
  parser.tokens = ['ASAP2_VERSION', '1', '63', 'A2ML_VERSION', '2', '20', '/begin', 'PROJECT', 'Moo', '"MooProject"',  '/begin', 'MODULE', 'Test.Module', '"This is a test module"'];
  parser.tokens.addAll(data);
  parser.tokens.addAll(['/end', 'MODULE','/end', 'PROJECT']);
}








