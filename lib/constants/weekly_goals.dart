/// Daily practice goal options: intensity label, duration label, XP reward,
/// and FontAwesome icon name (e.g. 'feather', 'dumbbell', 'bolt', 'fire').
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Map<String, dynamic>> DAILY_PRACTICE_GOALS = [
  {'intensity': 'light', 'duration': 'fiveMinutesADay', 'xp': 30, 'icon': 'feather'},
  {'intensity': 'regular', 'duration': 'fifteenMinutesADay', 'xp': 70, 'icon': 'dumbbell'},
  {'intensity': 'high', 'duration': 'thirtyMinutesADay', 'xp': 120, 'icon': 'bolt'},
  {'intensity': 'extreme', 'duration': 'oneHourADay', 'xp': 200, 'icon': 'fire'},
];

/// Returns FontAwesome IconData for a goal icon key from [DAILY_PRACTICE_GOALS].
IconData goalIconData(String iconKey) {
  switch (iconKey) {
    case 'feather':
      return FontAwesomeIcons.feather;
    case 'dumbbell':
      return FontAwesomeIcons.dumbbell;
    case 'bolt':
      return FontAwesomeIcons.bolt;
    case 'fire':
      return FontAwesomeIcons.fire;
    default:
      return FontAwesomeIcons.bolt;
  }
}
