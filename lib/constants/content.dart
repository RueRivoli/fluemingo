import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<String> AUDIOBOOK_TYPES = [
    'Fiction', 'Biography', 'Literature', 'Poetry', 'Travel', 'Tale'
];

/// A theme option with a stable [id] (for l10n/storage) and optional [icon].
class ThemeItem {
  const ThemeItem({required this.id, this.icon});
  final String id;
  final IconData? icon;
}

/// Returns the icon registered in [THEMES] for the given theme id, or null
/// if the id is unknown (e.g. pseudo-themes like "All"). Single source of
/// truth for icon resolution across the app.
IconData? themeIconFor(String themeId) =>
    THEMES.where((e) => e.id == themeId).firstOrNull?.icon;

final List<ThemeItem> THEMES = [
  ThemeItem(id: 'art', icon: FontAwesomeIcons.palette),
  ThemeItem(id: 'cinema', icon: FontAwesomeIcons.film),
  ThemeItem(id: 'culture', icon: FontAwesomeIcons.globe),
  ThemeItem(id: 'education', icon: FontAwesomeIcons.graduationCap),
  ThemeItem(id: 'fashion', icon: FontAwesomeIcons.shirt),
  ThemeItem(id: 'fiction', icon: FontAwesomeIcons.bookOpen),
  ThemeItem(id: 'gastronomy', icon: FontAwesomeIcons.utensils),
  ThemeItem(id: 'health', icon: FontAwesomeIcons.heartPulse),
  ThemeItem(id: 'history', icon: FontAwesomeIcons.clockRotateLeft),
  ThemeItem(id: 'languages', icon: FontAwesomeIcons.language),
  ThemeItem(id: 'literature', icon: FontAwesomeIcons.bookOpen),
  ThemeItem(id: 'music', icon: FontAwesomeIcons.music),
  ThemeItem(id: 'news', icon: FontAwesomeIcons.newspaper),
  ThemeItem(id: 'people', icon: FontAwesomeIcons.users),
  ThemeItem(id: 'philosophy', icon: FontAwesomeIcons.bookOpen),
  ThemeItem(id: 'psychology', icon: FontAwesomeIcons.brain),
  ThemeItem(id: 'science', icon: FontAwesomeIcons.flask),
  ThemeItem(id: 'society', icon: FontAwesomeIcons.peopleGroup),
  ThemeItem(id: 'space', icon: FontAwesomeIcons.rocket),
  ThemeItem(id: 'sport', icon: FontAwesomeIcons.futbol),
  ThemeItem(id: 'technology', icon: FontAwesomeIcons.microchip),
  ThemeItem(id: 'travel', icon: FontAwesomeIcons.planeDeparture),
  ThemeItem(id: 'watersports', icon: FontAwesomeIcons.personSwimming),
  ThemeItem(id: 'yoga', icon: FontAwesomeIcons.spa),
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
