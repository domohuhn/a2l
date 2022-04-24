import 'package:a2l/src/parsing_exception.dart';
import 'package:a2l/src/token.dart';
import 'package:a2l/src/utility.dart';

/// Naming scheme for variants
enum VariantNaming { ALPHA, NUMERIC }

/// Converts an a2l token [s] to the VariantNaming enum
VariantNaming variantNamingFromString(Token s) {
  switch (s.text) {
    case 'ALPHA':
      return VariantNaming.ALPHA;
    case 'NUMERIC':
      return VariantNaming.NUMERIC;
    default:
      throw ParsingException('Unknown VariantNaming scheme', s);
  }
}

/// Converts an a2l token [s] to the VariantNaming enum
String variantNamingToString(VariantNaming s) {
  switch (s) {
    case VariantNaming.ALPHA:
      return 'ALPHA';
    case VariantNaming.NUMERIC:
      return 'NUMERIC';
    default:
      throw ValidationError('Unknown VariantNaming scheme $s');
  }
}

/// A name value pair as string
class NameValuePair {
  NameValuePair(this.name, this.value);

  /// name
  String name;

  /// value
  String value;
}

/// Forbidden combination of variants
class ForbiddenCombination {
  ForbiddenCombination() : comibination = [];

  /// the list of forbidden combinations
  List<NameValuePair> comibination;

  /// Converts the object to an a2l string with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin VAR_FORBIDDEN_COMB', depth);
    for (final comb in comibination) {
      rv += indent('${comb.name} ${comb.value}', depth + 2);
    }
    rv += indent('/end VAR_FORBIDDEN_COMB', depth);
    return rv;
  }
}

/// Represents possible variant enumerations.
class VariantEnumeration {
  VariantEnumeration() : values = [];

  /// name of the enum
  String name = '';

  /// Description for the coding enumeration
  String description = '';

  /// enum values
  List<String> values;

  // optional
  /// the measurement object to read the enum from the ECU
  String? measurement;

  /// the calibration object to change the coding on the ECU
  String? characteristic;

  /// Converts the object to an a2l string with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin VAR_CRITERION $name', depth);
    rv += indent('"$description"', depth + 1);
    for (final v in values) {
      rv += indent(v, depth + 1);
    }
    if (measurement != null) {
      if (measurement!.isEmpty || measurement!.contains(' ')) {
        throw ValidationError(
            'Identifiers must not be empty or conatin spaces! VAR_MEASUREMENT "$measurement" in VariantEnumeration $name');
      }
      rv += indent('VAR_MEASUREMENT $measurement', depth + 1);
    }
    if (characteristic != null) {
      if (characteristic!.isEmpty || characteristic!.contains(' ')) {
        throw ValidationError(
            'Identifiers must not be empty or conatin spaces! VAR_SELECTION_CHARACTERISTIC "$measurement" in VariantEnumeration $name');
      }
      rv += indent('VAR_SELECTION_CHARACTERISTIC $characteristic', depth + 1);
    }
    rv += indent('/end VAR_CRITERION', depth);
    return rv;
  }
}

/// Represent a characteristic that is modified by the coding.
///
/// Can refer to CHARACTERISTIC or AXIS_PTS.
class VariantCharacteristic {
  VariantCharacteristic()
      : enumerations = [],
        address = [];

  /// name of the caracteristic
  String name = '';

  /// the relevant enumerations and the index order.
  List<String> enumerations;

  // optional
  /// list of addresses matching the combinations of enumerations minus the forbidden combinations.
  List<int> address;

  /// Converts the object to an a2l string with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin VAR_CHARACTERISTIC $name', depth);
    for (final v in enumerations) {
      rv += indent(v, depth + 1);
    }
    if (address.isNotEmpty) {
      rv += indent('/begin VAR_ADDRESS', depth + 1);
      for (final v in address) {
        rv += indent('0x${v.toRadixString(16).padLeft(8, "0")}', depth + 2);
      }
      rv += indent('/end VAR_ADDRESS', depth + 1);
    }
    rv += indent('/end VAR_CHARACTERISTIC', depth);
    return rv;
  }
}

/// Represents adjustable objects that change their addresses depending on the coded variant.
/// The class also describes how the addresses of the objects change depending on the variants.
///
/// Variant combinations are counted by incrementing the enum mentionted last in the characteristic first.
/// E.g. Enums A, B, C. Characteristic uses C B A in document order. Then var address will be indexed via:
/// final index = index(A) + count(A)*index(B) + count(A)*count(B)*index(C)
/// However, forbidden combinations are omitted in the address list.
class VariantCoding {
  VariantCoding()
      : enumerations = [],
        forbidden = [],
        characteristics = [];

  // optional
  /// if variants are referenced numcerically or alphabetically
  VariantNaming namingScheme = VariantNaming.NUMERIC;

  /// separator between characteristics and the variant index
  String separator = '.';

  /// the enumeration values for the coding
  List<VariantEnumeration> enumerations;

  /// forbidden combinations of the enumerations
  List<ForbiddenCombination> forbidden;

  /// the CHARACTERISTIC or AXIS_PTS affected by coding together with the changed addresses.
  List<VariantCharacteristic> characteristics;

  /// Converts the object to an a2l string with the given indentation [depth].
  String toFileContents(int depth) {
    var rv = indent('/begin VARIANT_CODING', depth);
    rv += indent('VAR_NAMING ${variantNamingToString(namingScheme)}', depth + 1);
    rv += indent('VAR_SEPARATOR "$separator"', depth + 1);
    for (final e in enumerations) {
      rv += e.toFileContents(depth + 1);
    }
    for (final f in forbidden) {
      rv += f.toFileContents(depth + 1);
    }
    for (final c in characteristics) {
      rv += c.toFileContents(depth + 1);
    }
    rv += indent('/end VARIANT_CODING\n\n', depth);
    return rv;
  }
}
