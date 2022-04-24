import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Describes the memory types.
enum MemoryLayoutType {
  /// Program code
  PRG_CODE,

  /// data segement
  PRG_DATA,

  /// something else
  PRG_RESERVED
}

/// Converts the token [t] to the corresponding enum or throws an exception.
MemoryLayoutType memoryLayoutTypeFromString(Token t) {
  switch (t.text) {
    case 'PRG_CODE':
      return MemoryLayoutType.PRG_CODE;
    case 'PRG_DATA':
      return MemoryLayoutType.PRG_DATA;
    case 'PRG_RESERVED':
      return MemoryLayoutType.PRG_RESERVED;
    default:
      throw ParsingException('Unknown program type', t);
  }
}

/// Converts the enum [e] to the corresponding a2l string or throws an exception.
String memoryLayoutTypeToString(MemoryLayoutType e) {
  switch (e) {
    case MemoryLayoutType.PRG_CODE:
      return 'PRG_CODE';
    case MemoryLayoutType.PRG_DATA:
      return 'PRG_DATA';
    case MemoryLayoutType.PRG_RESERVED:
      return 'PRG_RESERVED';
    default:
      throw ValidationError('Unknown program type $e');
  }
}

/// Base data describing a memory segment.
class SegmentData {
  SegmentData() : offsets = [-1, -1, -1, -1, -1];

  /// Initial address of the segment
  int address = 0;

  /// Size of the segment
  int size = 0;

  /// Offsets to mirrored segments (if larger than 0)
  /// Add the offsets to the initial address to get a mirrored segment.
  /// Changes made in the first segment must be mirrored to these offsets.
  /// Must have length 5!
  List<int> offsets;

  bool get isValid => offsets.length == 5;

  /// Converts the shared data to the a2l string representation with [depth].
  String sharedDataToFileContents(int depth) {
    if (!isValid) {
      throw ValidationError('MemoryLayout at $address is not valid! It needs exactly 5 offsets!');
    }
    var rv = indent('0x${address.toRadixString(16).padLeft(8, "0")} 0x${size.toRadixString(16).padLeft(8, "0")}', depth);
    for (final v in offsets) {
      if (v >= 0) {
        rv += indent('0x${v.toRadixString(16).padLeft(8, "0")}', depth);
      } else {
        rv += indent('-1', depth);
      }
    }
    return rv;
  }
}

/// The object is used to describe how the memory is divided into
/// segments on the ECU.
///
/// This keyword/object is deprecated and should not be used.
/// MemorySegment is the replacement.
class MemoryLayout extends SegmentData {
  /// Type of the segment
  MemoryLayoutType type = MemoryLayoutType.PRG_CODE;

  // optional
  // TODO IF_DATA

  /// Converts the object to a part of an a2l file with indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin MEMORY_LAYOUT', depth);
    rv += indent(memoryLayoutTypeToString(type), depth + 1);
    rv += sharedDataToFileContents(depth + 1);
    rv += indent('/end MEMORY_LAYOUT\n\n', depth);
    return rv;
  }
}
