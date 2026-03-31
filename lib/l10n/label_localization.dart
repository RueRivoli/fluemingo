import 'package:flutter/material.dart';

import 'app_localizations.dart';

/// Generic dynamic lookup for simple label IDs backed by generated l10n getters.
///
/// Unknown keys return the original [label].
String getTranslatedLabel(BuildContext context, String label) {
  final l10n = AppLocalizations.of(context)!;
  final key = label.trim().toLowerCase();
  final resolver = _labelLookup[key];
  if (resolver == null) return label;
  return resolver(l10n);
}

final Map<String, String Function(AppLocalizations)> _labelLookup = {
  'art': (l) => l.art,
  'cinema': (l) => l.cinema,
  'culture': (l) => l.culture,
  'education': (l) => l.education,
  'fashion': (l) => l.fashion,
  'gastronomy': (l) => l.gastronomy,
  'health': (l) => l.health,
  'history': (l) => l.history,
  'languages': (l) => l.languages,
  'literature': (l) => l.literature,
  'music': (l) => l.music,
  'news': (l) => l.news,
  'fiction': (l) => l.fiction,
  'people': (l) => l.people,
  'philosophy': (l) => l.philosophy,
  'psychology': (l) => l.psychology,
  'science': (l) => l.science,
  'society': (l) => l.society,
  'space': (l) => l.space,
  'sport': (l) => l.sport,
  'sports': (l) => l.sport,
  'technology': (l) => l.technology,
  'travel': (l) => l.travel,
  'watersports': (l) => l.watersports,
  'yoga': (l) => l.yoga,
  'food': (l) => l.gastronomy,
};
