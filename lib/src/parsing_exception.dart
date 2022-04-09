


class ParsingException implements Exception {
  String cause;
  String text;
  int character;
  ParsingException(this.cause, this.text, this.character);

  @override
  String toString() {
    return '$cause at $character';
  }
}

