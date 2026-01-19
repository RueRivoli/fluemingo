import 'unit.dart';

class ArticleSentence {
  final String originalText; // Text in the target language (e.g., French)
  final String translationText; // Translation (e.g., English)
  final List<Unit> units; // List of units
  final double? startTime; // Start timestamp in seconds
  final double? endTime; // End timestamp in seconds

  ArticleSentence({
    required this.originalText,
    required this.translationText,
    required this.units,
    this.startTime,
    this.endTime,
  });
}


