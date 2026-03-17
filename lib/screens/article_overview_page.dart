import 'dart:io';

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
import '../widgets/content_status_badge.dart';
import '../widgets/content_category_chip.dart';
import '../services/flashcard_service.dart';
import '../utils/vocabulary_items.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../constants/number_icons.dart';
import '../stores/profile_store.dart';
import '../services/app_review_service.dart';
import '../services/offline_content_service.dart';

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
              widget.article.id, widget.article.chapterId ?? '');
      setState(() {
        _fullArticle = fullArticle;
        _isLoadingVocabulary = false;
        vocabulary = fullArticle?.vocabulary ?? [];
        vocabularyList = fullArticle?.mainVocabularyItems ?? [];
        addedByUserVocabulary = fullArticle?.addedByUserVocabularyItems ?? [];
      });
      await _refreshOfflineAvailability();
    } catch (e) {
      print('Error loading full article: $e');
      setState(() {
        _isLoadingVocabulary = false;
      });
      await _refreshOfflineAvailability();
    }
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
        const SnackBar(content: Text('Downloaded for offline access')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
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
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.thinCardsBlank,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.expressionAddedToFlashcards,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayArticle = _fullArticle ?? widget.article;
    final rawHeaderImagePath = displayArticle.imageUrl.isNotEmpty
        ? displayArticle.imageUrl
        : widget.article.imageUrl;
    final normalizedHeaderImagePath = rawHeaderImagePath.startsWith('file://')
        ? rawHeaderImagePath.replaceFirst('file://', '')
        : rawHeaderImagePath;
    final isLocalHeaderImage = normalizedHeaderImagePath.startsWith('/');

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
                      isLocalHeaderImage
                          ? Image.file(
                              File(normalizedHeaderImagePath),
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
                            )
                          : Image.network(
                              normalizedHeaderImagePath,
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
                          },
                        ),
                      ),
                    ],
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
                              GestureDetector(
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
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    widget.showLocker
                                        ? FontAwesomeIcons.lock
                                        : (_fullArticle?.isFavorite ?? false
                                            ? FontAwesomeIcons.solidHeart
                                            : FontAwesomeIcons.lightHeart),
                                    size: 20,
                                    color: widget.showLocker
                                        ? Colors.white
                                        : (_fullArticle?.isFavorite ?? false
                                            ? AppColors.secondary
                                            : Colors.white),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                if (widget.showLocker) {
                                  await presentPaywall();
                                  if (mounted) {
                                    ProfileStoreScope.of(context).load();
                                  }
                                  return;
                                }
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleReadingPage(
                                      article: _fullArticle ?? widget.article,
                                    ),
                                  ),
                                );
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
                                horizontalPadding: 14,
                                verticalPadding: 8,
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
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
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
                                ? 'Downloading...'
                                : (_isOfflineAvailable
                                    ? 'Available offline'
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
                      if (widget.showLocker &&
                          widget.article.contentType == 1 &&
                          !widget.article.isFree) {
                        await presentPaywall();
                        if (mounted) {
                          ProfileStoreScope.of(context).load();
                        }
                        return;
                      } else if (widget.article.contentType == 1) {
                        await _articleService.editArticleStatus(
                            widget.article, 'started');
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
                          vocabularyList = currentArticle.mainVocabularyItems;
                          addedByUserVocabulary =
                              currentArticle.addedByUserVocabularyItems;
                        });
                      } else if (widget.article.contentType == 2) {
                        final audiobookId =
                            _fullArticle?.id ?? widget.article.id;
                        final chapterId =
                            widget.article.chapterId ?? _fullArticle?.chapterId;
                        if (chapterId != null && chapterId.isNotEmpty) {
                          await _articleService.editChapterStatus(
                            audiobookId: audiobookId,
                            chapterId: chapterId,
                            status: 'started',
                          );
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleReadingPage(
                              article: _fullArticle ?? widget.article,
                            ),
                          ),
                        );
                        await _loadFullArticle();
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
