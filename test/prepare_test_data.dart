import 'package:a2l/src/a2l_parser.dart';
import 'package:a2l/src/token.dart';

/// Prepares test data by resetting the [parser] position and inserting the [data] block into a valid module.
/// 
void prepareTestData(TokenParser parser, List<String> data) {
  parser.currentIndex = 0;
  parser.tokens = convertStringsToTokens(['ASAP2_VERSION', '1', '63', 'A2ML_VERSION', '2', '20', '/begin', 'PROJECT', 'Moo', '"MooProject"',  '/begin', 'MODULE', 'Test.Module', '"This is a test module"']);
  parser.tokens.addAll(convertStringsToTokens(data));
  parser.tokens.addAll(convertStringsToTokens(['/end', 'MODULE','/end', 'PROJECT']));
}


/// Converts [data] to tokens.
List<Token> convertStringsToTokens(List<String> data) {
  var rv = <Token>[];
  for(var d in data) {
    rv.add(Token(d, 1, 2, 3));
  }
  return rv;
}




