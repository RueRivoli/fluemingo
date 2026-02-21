import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

final List<String> THEMES = [
  'Cinema', 'Culture', 'Education', 
  'Health', 'History', 'Languages', 'Literature',
  'Music', 'News', 'People',
  'Science',
  'Sports', 'Technology', 'Travel', 'Watersports', 'Yoga'
];


final List<String> LONG_TERM_THEMES = [
  'Adventure', 'Animals', 'Art', 'Business', 'Cinema', 'Comedy Shows',
  'Culture', 'Economy', 'Education', 'Environment', 'Fashion', 'Festivals',
  'Finance', 'Food', 'Health', 'History', 'Languages', 'Law', 'Literature',
  'Music', 'Nature', 'News', 'People',
  'Philosophy', 'Politics', 'Psychology', 'Religion', 'Science',
  'Sports', 'Technology', 'Travel', 'Video Games', 'Watersports', 'Yoga'
];

/// Returns the localized label for a theme name (e.g. THEMES / LONG_TERM_THEMES).
/// If the theme is already localized (e.g. "All levels") or unknown, returns [theme] as-is.
String themeLabel(BuildContext context, String theme) {
  final l10n = AppLocalizations.of(context)!;
  switch (theme) {
    case 'Cinema':
      return l10n.cinema;
    case 'Culture':
      return l10n.culture;
    case 'Education':
      return l10n.education;
    case 'Health':
      return l10n.health;
    case 'History':
      return l10n.history;
    case 'Languages':
      return l10n.languages;
    case 'Literature':
      return l10n.literature;
    case 'Music':
      return l10n.music;
    case 'News':
      return l10n.news;
    case 'People':
      return l10n.people;
    case 'Science':
      return l10n.science;
    case 'Sports':
      return l10n.sport;
    case 'Technology':
      return l10n.technology;
    case 'Travel':
      return l10n.travel;
    case 'Watersports':
      return l10n.watersports;
    case 'Yoga':
      return l10n.yoga;
    case 'Art':
      return l10n.art;
    case 'Fashion':
      return l10n.fashion;
    case 'Gastronomy':
      return l10n.gastronomy;
    case 'Food':
      return l10n.gastronomy;
    default:
      return theme;
  }
}