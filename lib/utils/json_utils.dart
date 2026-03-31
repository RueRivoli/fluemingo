/// Shared JSON parsing helpers used across services.
class JsonUtils {
  /// Read a boolean `is_new` / `isNew` value from a map, coercing from
  /// `bool`, `num`, or `String` representations.
  static bool readIsNew(Map<dynamic, dynamic> source) {
    final value = source['is_new'] ?? source['isNew'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }
}
