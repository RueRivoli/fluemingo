import 'package:flutter/material.dart';

final List<String> LEVELS = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

/// Color identity for each CEFR level. Used on level badges and chips so users
/// can recognize the level at a glance.
const Map<String, Color> kLevelColors = {
  'A1': Color(0xFF10B981), // green
  'A2': Color(0xFF06B6D4), // cyan / turquoise
  'B1': Color(0xFF3B82F6), // blue
  'B2': Color(0xFF8B5CF6), // violet
  'C1': Color(0xFFEC4899), // pink / magenta
};

Color levelColor(String level, {Color fallback = const Color(0xFF8A8BDE)}) {
  return kLevelColors[level] ?? fallback;
}
