import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/revenue_cat_config.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../constants/app_colors.dart';
import '../services/article_service.dart';
import 'article_reading_page.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/content_header_image.dart';
import '../widgets/content_category_chip.dart';
import '../widgets/favorite_toggle_button.dart';
import '../services/flashcard_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../constants/number_icons.dart';
import '../stores/profile_store.dart';
import '../services/app_review_service.dart';
import '../services/offline_content_service.dart';
import '../services/feedback_service.dart';
import '../widgets/xp_reward_bottom_sheet.dart';
import '../services/week_progress_service.dart';
import '../utils/flashcard_snackbar.dart';
import '../widgets/vocabulary_item_skeleton.dart';

class ArticleOverviewPage extends StatefulWidget {
  final Article article;
  final bool showLocker;
  final VoidCallback onFavoriteToggle;

  static void _noOp() {}

  const ArticleOverviewPage({
    super.key,
    required this.article,
    this.showLocker = false,
    VoidCallback? onFavoriteToggle,
  }) : onFavoriteToggle = onFavoriteToggle ?? _noOp;

  @override
  State<ArticleOverviewPage> createState() => _ArticleOverviewPageState();
}

class _ArticleOverviewPageState extends State<ArticleOverviewPage> {
  late List<VocabularyItem> vocabulary;
  late List<VocabularyItem> vocabularyList;
  late List<VocabularyItem> addedByUserVocabulary;
  bool _showPersonalVocabularyOnly = false;
  bool _isLoadingVocabulary = true;
  Article? _fullArticle;
  late final ArticleService _articleService;
  late final FlashcardService _flashcardService;
  late final OfflineContentService _offlineContentService;
  bool _isDownloadingOffline = false;
  bool _isOfflineAvailable = false;
  Timer? _audioPollTimer;
  int _audioPollAttempts = 0;
  static const int _audioPollMaxAttempts = 10; // 10 * 3s = 30s
  bool _isOpeningReader = false;

  @override
  void initState() {
    super.initState();
    vocabulary = widget.article.vocabulary;
    vocabularyList = widget.article.mainVocabularyItems;
    addedByUserVocabulary = widget.article.addedByUserVocabularyItems;
    _articleService = ArticleService(Supabase.instance.client);
    _flashcardService = FlashcardService(Supabase.instance.client);
    _offlineContentService = OfflineContentService();
    _loadFullArticle();
    _refreshOfflineAvailability();
  }

  Future<void> _loadFullArticle() async {
    setState(() {
      _isLoadingVocabulary = true;
    });

    try {
      final fullArticle = widget.article.contentType == 1
          ? await _articleService.getArticleById(widget.article.id)
          : await _articleService.getChapterById(
              widget.article.id, widget.article.chapterId ?? '',
              parentTitle: widget.article.parentTitle);
      setState(() {
        _fullArticle = fullArticle;
        _isLoadingVocabulary = false;
        vocabulary = fullArticle?.vocabulary ?? [];
        vocabularyList = fullArticle?.mainVocabularyItems ?? [];
        addedByUserVocabulary = fullArticle?.addedByUserVocabularyItems ?? [];
      });
      _maybeStartAudioPoll();
      await _refreshOfflineAvailability();
    } catch (e) {
      debugPrint('Error loading full article: $e');
      setState(() {
        _isLoadingVocabulary = false;
      });
      await _refreshOfflineAvailability();
    }
  }

  bool _hasMissingAudio() {
    return vocabulary.any((v) =>
        (v.isAddedByUser ?? false) == true && v.audioUrl.isEmpty);
  }

  void _maybeStartAudioPoll() {
    if (_audioPollTimer != null) return;
    if (!_hasMissingAudio()) return;
    _audioPollAttempts = 0;
    _audioPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      _audioPollAttempts++;
      try {
        final refreshed = widget.article.contentType == 1
            ? await _articleService.getArticleById(widget.article.id)
            : await _articleService.getChapterById(
                widget.article.id, widget.article.chapterId ?? '',
                parentTitle: widget.article.parentTitle);
        if (!mounted) return;
        if (refreshed != null) {
          setState(() {
            _fullArticle = refreshed;
            vocabulary = refreshed.vocabulary;
            vocabularyList = refreshed.mainVocabularyItems;
            addedByUserVocabulary = refreshed.addedByUserVocabularyItems;
          });
        }
      } catch (e) {
        debugPrint('Audio poll refresh failed: $e');
      }
      if (!_hasMissingAudio() || _audioPollAttempts >= _audioPollMaxAttempts) {
        _audioPollTimer?.cancel();
        if (mounted) setState(() => _audioPollTimer = null);
      }
    });
  }

  @override
  void dispose() {
    _audioPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshOfflineAvailability() async {
    final article = _fullArticle ?? widget.article;
    final chapterId = article.contentType == 2
        ? (article.chapterId ?? widget.article.chapterId)
        : null;
    final isCached = await _offlineContentService.isArticleCached(
      contentType: article.contentType,
      contentId: article.id,
      chapterId: chapterId,
    );
    if (!mounted) return;
    setState(() {
      _isOfflineAvailable = isCached;
    });
  }

  Future<void> _downloadForOffline() async {
    if (_isDownloadingOffline) return;
    setState(() {
      _isDownloadingOffline = true;
    });

    try {
      Article? articleToCache = _fullArticle;
      if (articleToCache == null) {
        articleToCache = widget.article.contentType == 1
            ? await _articleService.getArticleById(widget.article.id)
            : await _articleService.getChapterById(
                widget.article.id,
                widget.article.chapterId ?? '',
              );
      }
      if (articleToCache == null) {
        throw Exception('Unable to load content before download.');
      }

      final cached = await _offlineContentService.cacheArticle(articleToCache);
      if (!mounted) return;
      setState(() {
        _fullArticle = cached;
        vocabulary = cached.vocabulary;
        vocabularyList = cached.mainVocabularyItems;
        addedByUserVocabulary = cached.addedByUserVocabularyItems;
        _isOfflineAvailable = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.downloadedForOfflineAccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.downloadFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingOffline = false;
        });
      }
    }
  }

  void _showFlashcardAddedSnackBar() {
    FlashcardSnackbar.show(context, 'added');
  }

  @override
  Widget build(BuildContext context) {
    final displayArticle = _fullArticle ?? widget.article;
    final rawHeaderImagePath = displayArticle.imageUrl.isNotEmpty
        ? displayArticle.imageUrl
        : widget.article.imageUrl;

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
                  ContentHeaderImage(
                    imageUrl: rawHeaderImagePath,
                    status: _fullArticle?.readingStatus,
                    showStatusMenu: true,
                    onStatusChange: (newStatus) async {
                      final article = _fullArticle ?? widget.article;
                      if (widget.article.contentType == 1) {
                        await _articleService.editArticleStatus(
                          article,
                          newStatus,
                        );
                      } else if (widget.article.contentType == 2) {
                        final audiobookId =
                            _fullArticle?.id ?? widget.article.id;
                        final chapterId = widget.article.chapterId ??
                            _fullArticle?.chapterId;
                        if (chapterId != null && chapterId.isNotEmpty) {
                          await _articleService.editChapterStatus(
                            audiobookId: audiobookId,
                            chapterId: chapterId,
                            status: newStatus,
                          );
                        }
                      }
                      await _loadFullArticle();
                      if (newStatus == 'finished' && mounted) {
                        final xp = widget.article.contentType == 1
                            ? XP_PER_ARTICLE
                            : XP_PER_AUDIOBOOK_CHAPTER;
                        FeedbackService.instance.playSuccess();
                        await XpRewardBottomSheet.show(context, xp: xp);
                      }
                    },
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row (arrow centered on title only)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final isAudiobookChapter =
                                      widget.article.contentType == 2;
                                  final orderId = widget.article.orderId ?? 0;
                                  final numberIcon = isAudiobookChapter
                                      ? figureToFontAwesomeIcon(orderId)
                                      : null;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (isAudiobookChapter) ...[
                                        if (numberIcon != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(numberIcon,
                                                    size: 24,
                                                    color:
                                                        AppColors.textPrimary),
                                                Text(
                                                  '.',
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
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
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            if (_fullArticle?.contentType == 1 ||
                                widget.showLocker) ...[
                              const SizedBox(width: 8),
                              FavoriteToggleButton(
                                isFavorite: _fullArticle?.isFavorite ?? false,
                                showLocker: widget.showLocker,
                                onTap: () async {
                                  if (widget.showLocker) {
                                    await presentPaywall();
                                    if (mounted) {
                                      ProfileStoreScope.of(context).load();
                                    }
                                    return;
                                  }
                                  widget.onFavoriteToggle();
                                  setState(() {
                                    if (_fullArticle == null) return;
                                    _fullArticle!.isFavorite =
                                        !_fullArticle!.isFavorite;
                                  });
                                },
                              ),
                            ],
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                if (_isOpeningReader) return;
                                if (widget.showLocker) {
                                  await presentPaywall();
                                  if (mounted) {
                                    ProfileStoreScope.of(context).load();
                                  }
                                  return;
                                }
                                _isOpeningReader = true;
                                try {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleReadingPage(
                                        article:
                                            _fullArticle ?? widget.article,
                                      ),
                                    ),
                                  );
                                } finally {
                                  _isOpeningReader = false;
                                }
                                // After returning from reading: refresh vocabulary and maybe ask for review
                                if (mounted) {
                                  setState(() {
                                    final currentArticle =
                                        _fullArticle ?? widget.article;
                                    vocabulary = currentArticle.vocabulary;
                                    vocabularyList = currentArticle
                                        .orderedListOfVocabularyItems;
                                    addedByUserVocabulary = currentArticle
                                        .addedByUserVocabularyItems;
                                  });
                                  AppReviewService.instance
                                      .requestReviewIfAppropriate();
                                }
                              },
                              child: const Icon(
                                FontAwesomeIcons.chevronRight,
                                size: 28,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
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
                            ContentCategoryChip(
                              category: widget.article.category1,
                              maxWidth: MediaQuery.of(context).size.width - 80,
                              maxLines: 2,
                              horizontalPadding: 10,
                              verticalPadding: 6,
                              borderRadius: 6,
                            ),
                            if (widget.article.category2 != null &&
                                widget.article.category2!.isNotEmpty)
                              ContentCategoryChip(
                                category: widget.article.category2!,
                                maxWidth:
                                    MediaQuery.of(context).size.width - 80,
                                maxLines: 2,
                                horizontalPadding: 10,
                                verticalPadding: 6,
                                borderRadius: 6,
                              ),
                            if (widget.article.category3 != null &&
                                widget.article.category3!.isNotEmpty)
                              ContentCategoryChip(
                                category: widget.article.category3!,
                                maxWidth:
                                    MediaQuery.of(context).size.width - 80,
                                maxLines: 2,
                                horizontalPadding: 10,
                                verticalPadding: 6,
                                borderRadius: 6,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.vocabulary,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!_showPersonalVocabularyOnly) return;
                                setState(() {
                                  _showPersonalVocabularyOnly = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Text(
                                  AppLocalizations.of(context)!.all,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    decoration: !_showPersonalVocabularyOnly
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                if (_showPersonalVocabularyOnly) return;
                                setState(() {
                                  _showPersonalVocabularyOnly = true;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .yourPersonalVocabulary,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    decoration: _showPersonalVocabularyOnly
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Vocabulary items
                        _isLoadingVocabulary
                            ? const VocabularyListSkeleton()
                            : (_showPersonalVocabularyOnly
                                        ? addedByUserVocabulary
                                        : vocabularyList)
                                    .isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .noVocabularyItemsFound,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...(_showPersonalVocabularyOnly
                                              ? addedByUserVocabulary
                                              : vocabularyList)
                                          .map((item) {
                                        return _buildVocabularyItem(item);
                                      }),
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
                        ...(_fullArticle?.grammarPoints ??
                                widget.article.grammarPoints)
                            .map((point) {
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
                  GestureDetector(
                    onTap: _isDownloadingOffline ? null : _downloadForOffline,
                    child: Container(
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
                            _isDownloadingOffline
                                ? Icons.downloading
                                : (_isOfflineAvailable
                                    ? Icons.check_circle_outline
                                    : Icons.download_outlined),
                            size: 20,
                            color: _isOfflineAvailable
                                ? AppColors.success
                                : Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDownloadingOffline
                                ? AppLocalizations.of(context)!.downloading
                                : (_isOfflineAvailable
                                    ? AppLocalizations.of(context)!.availableOffline
                                    : AppLocalizations.of(context)!
                                        .downloadForOfflineAccess),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _isOfflineAvailable
                                  ? AppColors.success
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Let's Read It button
                  GestureDetector(
                    onTap: () async {
                      if (_isOpeningReader) return;
                      if (widget.showLocker &&
                          widget.article.contentType == 1 &&
                          !widget.article.isFree) {
                        await presentPaywall();
                        if (mounted) {
                          ProfileStoreScope.of(context).load();
                        }
                        return;
                      }
                      _isOpeningReader = true;
                      try {
                        if (widget.article.contentType == 1) {
                          await _articleService.editArticleStatus(
                              widget.article, 'started');
                          if (!mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleReadingPage(
                                article: _fullArticle ?? widget.article,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {
                            final currentArticle =
                                _fullArticle ?? widget.article;
                            vocabulary = currentArticle.vocabulary;
                            vocabularyList =
                                currentArticle.mainVocabularyItems;
                            addedByUserVocabulary =
                                currentArticle.addedByUserVocabularyItems;
                          });
                        } else if (widget.article.contentType == 2) {
                          final audiobookId =
                              _fullArticle?.id ?? widget.article.id;
                          final chapterId = widget.article.chapterId ??
                              _fullArticle?.chapterId;
                          if (chapterId != null && chapterId.isNotEmpty) {
                            await _articleService.editChapterStatus(
                              audiobookId: audiobookId,
                              chapterId: chapterId,
                              status: 'started',
                            );
                          }
                          if (!mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleReadingPage(
                                article: _fullArticle ?? widget.article,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          await _loadFullArticle();
                        }
                      } finally {
                        _isOpeningReader = false;
                      }
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
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.startToRead,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
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
        isAudioPending: false,
        onIconToggle: () async {
          if (item.status == null) {
            if (item.flashcardId != null) {
              await _flashcardService.deleteFlashcard(item.flashcardId!);
              item.flashcardId = null;
            }
          } else {
            final createdFlashcard = await _flashcardService.addFlashcard(
                item,
                int.parse(widget.article.id),
                widget.article.chapterId != null
                    ? int.parse(widget.article.chapterId!)
                    : null);
            if (createdFlashcard != null) {
              item.flashcardId = createdFlashcard['id'] as int?;
              _showFlashcardAddedSnackBar();
            }
          }
        });
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
