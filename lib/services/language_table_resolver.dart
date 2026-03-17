class LanguageTableResolver {
  static const Set<String> _supportedLanguages = {'fr', 'en', 'es'};
  static String _currentLanguage = 'fr';

  static String get language => _currentLanguage;

  static void setLanguage(String? language) {
    final normalized = (language ?? '').trim().toLowerCase();
    _currentLanguage = _supportedLanguages.contains(normalized) ? normalized : 'fr';
  }

  static void reset() {
    _currentLanguage = 'fr';
  }

  static String table(String baseTableName) {
    return '${_currentLanguage}_$baseTableName';
  }
}
