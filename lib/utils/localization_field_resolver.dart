/// Shared utilities for resolving localised field values from maps keyed by
/// language code suffixes (e.g. `text_en`, `text_fr`).
class LocalizationFieldResolver {
  /// Normalise a language code to lowercase, trimmed form.
  static String normalizeReferenceLanguageCode(String? code) {
    return (code ?? '').trim().toLowerCase();
  }

  /// Return the list of alias codes to try for a given language code.
  static List<String> referenceLanguageAliases(String? code) {
    final normalized = normalizeReferenceLanguageCode(code);
    return normalized.isEmpty ? const [] : [normalized];
  }

  /// Read the first non-empty value from [source] using an ordered list of
  /// candidate keys.  Falls back to a case-insensitive lookup when an exact
  /// match is not found.
  static String readFirstNonEmptyFromMap(
      Map<dynamic, dynamic> source, List<String> candidates) {
    for (final key in candidates) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    if (source.keys.any((key) => key is String)) {
      final lowerCaseIndex = <String, dynamic>{};
      for (final entry in source.entries) {
        final key = entry.key;
        if (key is String) {
          lowerCaseIndex[key.toLowerCase()] = entry.value;
        }
      }
      for (final key in candidates) {
        final value = lowerCaseIndex[key.toLowerCase()];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    return '';
  }

  /// Resolve a vocabulary field (e.g. `text`, `example`) to its localised
  /// value using `{baseField}_{languageCode}` suffixes.
  static String localizedVocabularyFieldValue({
    required Map<dynamic, dynamic> source,
    required String baseField,
    required String referenceLanguageCode,
  }) {
    final aliases = referenceLanguageAliases(referenceLanguageCode);
    final candidates = <String>[
      ...aliases.map((code) => '${baseField}_$code'),
      ...aliases.map((code) => '${baseField}_${code.toUpperCase()}'),
      '${baseField}_en',
      '${baseField}_EN',
    ];
    return readFirstNonEmptyFromMap(source, candidates);
  }
}
