import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/article_paragraph.dart';
import '../models/article_sentence.dart';
import '../models/unit.dart';
import '../constants/app_colors.dart';
import 'unit_chip.dart';

/// Scrollable view of article/chapter paragraphs with sentence highlighting,
/// per-word tap support, and optional inline/after-paragraph translation modes.
class ArticleParagraphsView extends StatelessWidget {
  final List<ArticleParagraph> paragraphs;
  final ScrollController scrollController;
  final Map<int, GlobalKey> sentenceKeys;
  final int? currentHighlightedSentenceIndex;
  final double fontSize;
  final bool showTranslation;
  final bool showUnitsAsChips;
  final bool showTranslationAfterParagraph;
  final void Function(Unit unit) onUnitTap;

  const ArticleParagraphsView({
    super.key,
    required this.paragraphs,
    required this.scrollController,
    required this.sentenceKeys,
    required this.currentHighlightedSentenceIndex,
    required this.fontSize,
    required this.showTranslation,
    required this.showUnitsAsChips,
    required this.showTranslationAfterParagraph,
    required this.onUnitTap,
  });

  @override
  Widget build(BuildContext context) {
    if (paragraphs.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noParagraphsAvailable));
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...paragraphs.asMap().entries.map((paragraphEntry) {
            final paragraphIndex = paragraphEntry.key;
            final paragraph = paragraphEntry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTranslationAfterParagraph)
                  _buildInlineParagraph(paragraph, paragraphIndex)
                else
                  ...paragraph.sentences.asMap().entries.map((sentenceEntry) {
                    final sentenceIndexInParagraph = sentenceEntry.key;
                    final sentence = sentenceEntry.value;

                    int globalSentenceIndex = 0;
                    for (int i = 0; i < paragraphIndex; i++) {
                      globalSentenceIndex += paragraphs[i].sentences.length;
                    }
                    globalSentenceIndex += sentenceIndexInParagraph;

                    return _buildSentenceWidget(sentence, globalSentenceIndex);
                  }),
                if (showTranslation && showTranslationAfterParagraph) ...[
                  const SizedBox(height: 16),
                  _buildTranslationBlock(
                    paragraph.sentences
                        .where((s) => s.translationText.isNotEmpty)
                        .map((s) => s.translationText)
                        .join(' '),
                  ),
                ],
                if (paragraphIndex < paragraphs.length - 1)
                  const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Renders all sentences of a paragraph as a single flowing RichText block.
  /// Used when [showTranslationAfterParagraph] is true.
  Widget _buildInlineParagraph(ArticleParagraph paragraph, int paragraphIndex) {
    int startingGlobalIndex = 0;
    for (int i = 0; i < paragraphIndex; i++) {
      startingGlobalIndex += paragraphs[i].sentences.length;
    }

    final textSpans = <InlineSpan>[];

    if (!showUnitsAsChips) {
      for (int i = 0; i < paragraph.sentences.length; i++) {
        final sentence = paragraph.sentences[i];
        final globalIndex = startingGlobalIndex + i;
        final isHighlighted = currentHighlightedSentenceIndex == globalIndex;
        final isLastSentence = i == paragraph.sentences.length - 1;

        textSpans.add(
          TextSpan(
            text: sentence.originalText + (isLastSentence ? '' : ' '),
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.textPrimary,
              height: 1.8,
              backgroundColor: isHighlighted
                  ? AppColors.primary.withValues(alpha: 0.30)
                  : Colors.transparent,
            ),
          ),
        );
      }

      return Container(
        key: sentenceKeys[startingGlobalIndex],
        child: RichText(text: TextSpan(children: textSpans)),
      );
    }

    for (int i = 0; i < paragraph.sentences.length; i++) {
      final sentence = paragraph.sentences[i];
      final globalIndex = startingGlobalIndex + i;
      final isHighlighted = currentHighlightedSentenceIndex == globalIndex;
      final isLastSentence = i == paragraph.sentences.length - 1;

      for (int j = 0; j < sentence.units.length; j++) {
        final unit = sentence.units[j];
        final isLastUnitInSentence = j == sentence.units.length - 1;
        final joinToNextSentence = isLastUnitInSentence && !isLastSentence;

        textSpans.add(WidgetSpan(
          child: UnitChip(
            unit: unit,
            isHighlighted: isHighlighted,
            fontSize: fontSize,
            rightMargin: joinToNextSentence ? 0 : 4,
            trailingText: joinToNextSentence ? ' ' : '',
            onTap: () => onUnitTap(unit),
          ),
        ));
      }
    }

    return Container(
      key: sentenceKeys[startingGlobalIndex],
      child: RichText(text: TextSpan(children: textSpans)),
    );
  }

  /// Renders a single sentence with its units and optional per-sentence translation.
  Widget _buildSentenceWidget(ArticleSentence sentence, int globalIndex) {
    final isHighlighted = currentHighlightedSentenceIndex == globalIndex;
    final translation = showTranslation ? sentence.translationText : null;

    final Widget originalTextWidget;
    if (showUnitsAsChips) {
      final unitSpans = <InlineSpan>[];
      for (int i = 0; i < sentence.units.length; i++) {
        final unit = sentence.units[i];
        final isLastUnit = i == sentence.units.length - 1;

        unitSpans.add(WidgetSpan(
          child: UnitChip(
            unit: unit,
            isHighlighted: isHighlighted,
            fontSize: fontSize,
            rightMargin: isLastUnit ? 0 : 4,
            trailingText: isLastUnit ? '' : ' ',
            onTap: () => onUnitTap(unit),
          ),
        ));
      }
      originalTextWidget = RichText(text: TextSpan(children: unitSpans));
    } else {
      originalTextWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: 0.30)
              : Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          sentence.originalText,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.normal,
            height: 1.8,
          ),
        ),
      );
    }

    return Container(
      key: sentenceKeys[globalIndex],
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          originalTextWidget,
          if (translation != null && !showTranslationAfterParagraph) ...[
            _buildTranslationBlock(translation, topPadding: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationBlock(String text, {double topPadding = 0}) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        constraints: BoxConstraints(minHeight: fontSize * 2.1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textSecondary,
            height: 1.8,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
