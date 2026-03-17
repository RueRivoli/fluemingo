import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';


const List<String> REFERENCE_LANGUAGE_CODES = [
  'en',
  'fr',
  'es',
  'de',
  'nl',
  'it',
  'pt',
  'ja',
];

const List<String> TARGET_LANGUAGE_CODES = [
  'en',
  'fr',
];

/// Returns the localized display name for a language code.
String getLanguageName(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context)!;
  switch (code) {
    case 'en':
      return l10n.languageEn;
    case 'fr':
      return l10n.languageFr;
    case 'es':
      return l10n.languageEs;
    case 'de':
      return l10n.languageDe;
    case 'nl':
      return l10n.languageNl;
    case 'it':
      return l10n.languageIt;
    case 'pt':
      return l10n.languagePt;
    case 'ja':
      return l10n.languageJa;
    default:
      return code;
  }
}

  String languageNameFromCode(String code) {
    switch (code.trim().toLowerCase()) {
      case 'fr':
        return 'French';
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'nl':
        return 'Dutch';
      case 'ja':
        return 'Japanese';
      default:
        return code.toUpperCase();
    }
  }


List<Map<String, String>> getReferenceLanguages(BuildContext context) {
  return REFERENCE_LANGUAGE_CODES
      .map((code) => {'code': code, 'name': getLanguageName(context, code)})
      .toList();
}

List<Map<String, String>> getTargetLanguages(BuildContext context) {
  return TARGET_LANGUAGE_CODES
      .map((code) => {'code': code, 'name': getLanguageName(context, code)})
      .toList();
}

String getLanguageIconPath(String code) {
  switch (code) {
    case 'en':
      return 'assets/images/languages/english.svg';
    case 'fr':
      return 'assets/images/languages/french.svg';
    case 'es':
      return 'assets/images/languages/spanish.svg';
    case 'pt':
      return 'assets/images/languages/portuguese.svg';
    case 'de':
      return 'assets/images/languages/german.svg';
    case 'ja':
      return 'assets/images/languages/japanese.svg';
    case 'nl':
      return 'assets/images/languages/dutch.svg';
    case 'it':
      return 'assets/images/languages/italian.svg';
    default:
      return 'assets/images/languages/english.svg';
  }
}
