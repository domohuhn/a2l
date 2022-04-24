import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/utility.dart';

/// When someone logs into the calibration system, they receive a user id.
/// Only the referenced entries of the listed groups are visible to the user.
/// If set to read only, then no values can be changed.
class UserRights {
  UserRights() : groups = [];

  /// the user id /user group
  String userId = '';

  // optional
  /// if all values should be treated as read only
  bool readOnly = false;

  /// the visible groups
  List<String> groups;

  /// Converts the compute method to an a2l file with the given indentation [depth].
  String toFileContents(int depth) {
    if (userId.isEmpty || userId.contains(' ')) {
      throw ValidationError('UserRights: Identifiers must not be empty and cannot contain spaces! Got "$userId"');
    }
    var rv = indent('/begin USER_RIGHTS $userId', depth);
    if (readOnly) {
      rv += indent('READ_ONLY', depth + 1);
    }
    if (groups.isNotEmpty) {
      rv += indent('/begin REF_GROUP', depth + 1);
      for (final data in groups) {
        rv += indent(data, depth + 2);
      }
      rv += indent('/end REF_GROUP', depth + 1);
    }
    rv += indent('/end USER_RIGHTS\n\n', depth);
    return rv;
  }
}
