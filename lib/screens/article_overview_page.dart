import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../constants/app_colors.dart';
import '../services/article_service.dart';
import 'article_reading_page.dart';
import '../widgets/vocabulary_item_card.dart';

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

  @override
  void initState() {
    super.initState();
    vocabulary = widget.article.vocabulary;
    _articleService = ArticleService(Supabase.instance.client);
    _loadFullArticle();
  }

  Future<void> _loadFullArticle() async {
    setState(() {
      _isLoadingVocabulary = true;
    });

    try {
      final fullArticle = await _articleService.getArticleById(widget.article.id);
      if (fullArticle != null) {
        setState(() {
          _fullArticle = fullArticle;
          vocabulary = fullArticle.vocabulary;
          mainVocabulary = fullArticle.mainVocabularyItems;
          addedByUserVocabulary = fullArticle.addedByUserVocabularyItems;
          _isLoadingVocabulary = false;
        });
      } else {
        setState(() {
          _isLoadingVocabulary = false;
        });
      }
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
                              Icons.chevron_left,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                          ),
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
                        // Title with chevron
                        Row(
                          children: [
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
                      Icons.chevron_right,
                      size: 28,
                      color: AppColors.textPrimary,
                    ),
                  ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tags
                        Row(
                          children: [
                            // Level tag with dotted border
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutral,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.article.level,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Category tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.article.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
                        const Text(
                          'Vocabulary',
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
                                      'No vocabulary items found',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Main vocabulary items
                                      if (mainVocabulary.isNotEmpty) ...[
                                        ...mainVocabulary.map((item) {
                                          return _buildVocabularyItem(item);
                                        }),
                                      ],
                                      // Personal vocabulary section
                                      if (addedByUserVocabulary.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        Text(
                                          'Personal',
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
                                    ],
                                  ),

                        const SizedBox(height: 24),

                        // Grammar Points Section
                      if (_fullArticle?.grammarPoints.isNotEmpty ?? false)
                        const Text(
                          'Grammar Points',
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
                          'Download for Offline Access',
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Let's Read It!",
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
        // Card handles state toggle internally
        // TODO: Add Supabase save here if needed
      },
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

