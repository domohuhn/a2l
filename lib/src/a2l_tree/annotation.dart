import 'package:a2l/src/utility.dart';

/// Represents an annotation/comment in the a2l file.
class Annotation {
  String? label;
  String? origin;
  List<String> text;

  Annotation() : text = [];

  /// Converts the annotation to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin ANNOTATION', depth);
    if (label != null) {
      rv += indent('ANNOTATION_LABEL "$label"', depth + 1);
    }
    if (origin != null) {
      rv += indent('ANNOTATION_ORIGIN "$origin"', depth + 1);
    }
    if (text.isNotEmpty) {
      rv += indent('/begin ANNOTATION_TEXT', depth + 1);
      for (final t in text) {
        rv += indent('"$t"', depth + 2);
      }
      rv += indent('/end ANNOTATION_TEXT', depth + 1);
    }
    rv += indent('/end ANNOTATION', depth);
    return rv;
  }
}

/// Represents multiple annotations/comments in the a2l file below one element.
class AnnotationContainer {
  List<Annotation> annotations;
  AnnotationContainer() : annotations = [];

  /// Converts the annotation to an a2l file with the given indentation [depth].
  String annotationsToFileContents(int depth) {
    var rv = '';
    for (final a in annotations) {
      rv += a.toFileContents(depth);
    }
    return rv;
  }
}
