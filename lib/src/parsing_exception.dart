

import 'package:a2l/src/token.dart';

/// An exception during the conversion stage from tokens to the A2L file.
class ParsingException implements Exception {
  String cause;
  Token token;
  ParsingException(this.cause, this.token);

  @override
  String toString() {
    return '$cause\nat $token';
  }
}


/// An exception during the validation stage.
class ValidationError implements Exception {
  String cause;
  ValidationError(this.cause);

  @override
  String toString() {
    return 'ValidationError: $cause';
  }
}
