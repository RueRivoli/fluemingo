import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../constants/app_colors.dart';
import '../services/article_service.dart';
import 'article_reading_page.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/content_status_badge.dart';
import '../services/flashcard_service.dart';
import '../utils/vocabulary_items.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../constants/library_themes.dart';

class ArticleOverviewPage extends StatefulWidget {
  final Article article;

  const ArticleOverviewPage({super.key, required this.article});

  @override
  State<ArticleOverviewPage> createState() => _ArticleOverviewPageState();
}

class _ArticleOverviewPageState extends State<ArticleOverviewPage> {
  late List<VocabularyItem> vocabulary;
  late List<VocabularyItem> mainVocabulary;
  late List<VocabularyItem> addedByUserVocabulary;
  bool _isLoadingVocabulary = true;
  Article? _fullArticle;
  late final ArticleService _articleService;
  late final FlashcardService _flashcardService;

  @override
  void initState() {
    super.initState();
    vocabulary = widget.article.vocabulary;
    _articleService = ArticleService(Supabase.instance.client);
     _flashcardService = FlashcardService(Supabase.instance.client);
    _loadFullArticle();
  }

  /// Font Awesome icon for digits 0-9; null for 10+ (use text instead).
  IconData? _numberToFontAwesomeIcon(int n) {
    switch (n) {
      case 0: return FontAwesomeIcons.zero;
      case 1: return FontAwesomeIcons.one;
      case 2: return FontAwesomeIcons.two;
      case 3: return FontAwesomeIcons.three;
      case 4: return FontAwesomeIcons.four;
      case 5: return FontAwesomeIcons.five;
      case 6: return FontAwesomeIcons.six;
      case 7: return FontAwesomeIcons.seven;
      case 8: return FontAwesomeIcons.eight;
      case 9: return FontAwesomeIcons.nine;
      default: return null;
    }
  }

  Future<void> _loadFullArticle() async {
    setState(() {
      _isLoadingVocabulary = true;
    });

    try {
      final fullArticle = widget.article.contentType == 1 ? await _articleService.getArticleById(widget.article.id) : await _articleService.getChapterById(widget.article.id.toString() ?? '', widget.article.chapterId ?? '');
      setState(() {
        _fullArticle = fullArticle;
        _isLoadingVocabulary = false;
       vocabulary = fullArticle?.vocabulary ?? [];
       mainVocabulary = fullArticle?.mainVocabularyItems ?? [];
       addedByUserVocabulary = fullArticle?.addedByUserVocabularyItems ?? [];
      });
    } catch (e) {
      print('Error loading full article: $e');
      setState(() {
        _isLoadingVocabulary = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image
                  Stack(
                    children: [
                      Image.network(
                        widget.article.imageUrl,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 280,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FontAwesomeIcons.chevronLeft,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Status badge (with menu on overview)
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: ContentStatusBadge(
                          status: _fullArticle?.readingStatus,
                          compact: false,
                          showStatusMenu: true,
                          onStatusChange: (newStatus) async {
                            final article = _fullArticle ?? widget.article;
                            if (widget.article.contentType == 1) await _articleService.editArticleStatus(article, newStatus);
                            await _loadFullArticle();
                          },
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with chevron (and chapter number icon for audiobook chapters)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final isAudiobookChapter = widget.article.contentType == 2;
                                      final orderId = widget.article.orderId ?? 0;
                                      final numberIcon = isAudiobookChapter ? _numberToFontAwesomeIcon(orderId) : null;
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (isAudiobookChapter) ...[
                                            if (numberIcon != null)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(numberIcon, size: 24, color: AppColors.textPrimary),
                                                    Text(
                                                      '.',
                                                      style: const TextStyle(
                                                        fontSize: 28,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Text(
                                                  '$orderId.',
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ),
                                          ],
                                          Expanded(
                                            child: Text(
                                              widget.article.title,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          widget.article.level,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8E8E8),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          themeLabel(context, widget.article.category1),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (widget.article.category2 != null && widget.article.category2!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8E8E8),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            themeLabel(context, widget.article.category2!),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF4A4A4A),
                                            ),
                                          ),
                                        ),
                                      if (widget.article.category3 != null && widget.article.category3!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8E8E8),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            themeLabel(context, widget.article.category3!),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF4A4A4A),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleReadingPage(
                                      article: _fullArticle ?? widget.article,
                                    ),
                                  ),
                                );
                                // Force rebuild to reflect any vocabulary status changes
                                setState(() {
                                  final currentArticle = _fullArticle ?? widget.article;
                                  vocabulary = currentArticle.vocabulary;
                                  mainVocabulary = currentArticle.mainVocabularyItems;
                                  addedByUserVocabulary = currentArticle.addedByUserVocabularyItems;
                                });
                              },
                              child: const Icon(
                                FontAwesomeIcons.chevronRight,
                                size: 28,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.article.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Vocabulary Section
                        Text(
                          AppLocalizations.of(context)!.vocabulary,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Vocabulary items
                        _isLoadingVocabulary
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : vocabulary.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      AppLocalizations.of(context)!.noVocabularyItemsFound,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                                            // Personal vocabulary section
                                      if (addedByUserVocabulary.isNotEmpty) ...[
                                        Text(
                                          AppLocalizations.of(context)!.yourPersonalVocabulary,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ...addedByUserVocabulary.map((item) {
                                          return _buildVocabularyItem(item);
                                        }),
                                      ],
                                      // Main vocabulary items
                                      if (mainVocabulary.isNotEmpty) ...[
                                        Text(
                                          AppLocalizations.of(context)!.mainVocabulary,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ...mainVocabulary.map((item) {
                                          return _buildVocabularyItem(item);
                                        }),
                                      ],
                                    ],
                                  ),

                        const SizedBox(height: 24),

                        // Grammar Points Section
                      if (_fullArticle?.grammarPoints.isNotEmpty ?? false)
                        Text(
                          AppLocalizations.of(context)!.grammarPoints,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Grammar items
                        ...(_fullArticle?.grammarPoints ?? widget.article.grammarPoints).map((point) {
                          return _buildGrammarItem(point);
                        }),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Download button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.downloadForOfflineAccess,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Let's Read It button
                  GestureDetector(
                    onTap: () async {
                      if (widget.article.contentType == 1) await _articleService.editArticleStatus(widget.article, 'started');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleReadingPage(
                            article: _fullArticle ?? widget.article,
                          ),
                        ),
                      );
                      // Force rebuild to reflect any vocabulary status changes
                      setState(() {
                        final currentArticle = _fullArticle ?? widget.article;
                        vocabulary = currentArticle.vocabulary;
                        mainVocabulary = currentArticle.mainVocabularyItems;
                        addedByUserVocabulary = currentArticle.addedByUserVocabularyItems;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.bookOpen,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.startToRead,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyItem(VocabularyItem item) {
    return VocabularyItemCard(
      item: item,
      onIconToggle: () async {
        print('item.status: ${item.status}');
        if (item.status == null) {
          print('Deleting flashcard ${item.flashcardId}');
          if (item.flashcardId != null) await _flashcardService.deleteFlashcard(item.flashcardId!);
          // setState(() {
          //   item.status = null;
          //   });
        } else {
            print('Adding flashcard');
        await _flashcardService.addFlashcard(item, int.parse(widget.article.id), widget.article.chapterId != null ? int.parse(widget.article.chapterId!) : null);
      }
      }
  );
  }

  Widget _buildGrammarItem(GrammarPoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            point.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            point.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

