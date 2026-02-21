import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

final List<String> TYPES = [
    'Fiction', 'Biography', 'Literature', 'Poetry', 'Travel', 'Tale'
];

final List<String> THEMES = [
  'Art', 'Education', 'Fashion', 'Gastronomy', 'History', 'Space', 'Society'
];

final List<String> LONG_TERM_THEMES = [
  'Adventure', 'Animals', 'Art', 'Business', 'Cinema', 'Comedy Shows',
  'Culture', 'Economy', 'Education', 'Environment', 'Fashion', 'Festivals',
  'Finance', 'Food', 'Gastronomy', 'Health', 'History', 'Languages', 'Law', 'Literature',
  'Music', 'Nature', 'News', 'People',
  'Philosophy', 'Politics', 'Psychology', 'Religion', 'Science', 'Space', 'Society'
  'Sports', 'Technology', 'Travel', 'Video Games', 'Watersports'
];

String audiobookTypeLabel(BuildContext context, String type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case 'Fiction':
      return l10n.fiction;
    case 'Biography':
      return l10n.biography;
    case 'Literature':
      return l10n.literature;
    case 'Poetry':
      return l10n.poetry;
    case 'Travel':
      return l10n.travel;
    case 'Tale':
      return l10n.tale;
    default:
      return type;
  }
}

String audiobookThemeLabel(BuildContext context, String theme) {
  final l10n = AppLocalizations.of(context)!;
  switch (theme) {
    case 'Art':
      return l10n.art;
    case 'Education':
      return l10n.education;
    case 'Fashion':
      return l10n.fashion;
    case 'Gastronomy':
      return l10n.gastronomy;
    case 'History':
      return l10n.history;
    case 'Space':
      return l10n.space;
    case 'Society':
      return l10n.society;
    default:
      return theme;
  }
}