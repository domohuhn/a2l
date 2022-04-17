
/// A token parsed from the file.
class Token {
  /// Token text
  String text;
  /// line inside the file
  final int line;
  /// column in the line
  final int column;
  /// total file offset
  final int offset;

  /// Constructor
  Token(this.text, this.line, this.column, this.offset);

  @override 
  String toString() {
    return 'Token "$text" at line $line($column)';
  }
}


