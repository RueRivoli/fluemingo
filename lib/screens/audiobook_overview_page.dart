import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/revenue_cat_config.dart';
import '../constants/app_colors.dart';
import '../widgets/content_header_image.dart';
import '../widgets/content_category_chip.dart';
import '../widgets/favorite_toggle_button.dart';
import '../models/article.dart';
import '../models/audiobook.dart';
import '../services/audiobook_service.dart';
import 'article_overview_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../constants/number_icons.dart';
import '../stores/profile_store.dart';
import '../widgets/chapter_list_skeleton.dart';

class AudiobookOverviewPage extends StatefulWidget {
  final Audiobook audiobook;
  final bool showLocker;
  final VoidCallback onFavoriteToggle;

  const AudiobookOverviewPage(
      {super.key,
      required this.audiobook,
      this.showLocker = false,
      required this.onFavoriteToggle});

  @override
  State<AudiobookOverviewPage> createState() => _AudiobookOverviewPageState();
}

class _AudiobookOverviewPageState extends State<AudiobookOverviewPage> {
  Audiobook? _audiobook;
  late final AudiobookService _audiobookService;

  @override
  void initState() {
    super.initState();
    _audiobookService = AudiobookService(Supabase.instance.client);
    _loadFullAudiobook();
  }

  Future<void> _loadFullAudiobook() async {
    try {
      final audioBook =
          await _audiobookService.getAudiobookById(widget.audiobook.id);
      if (audioBook != null && mounted) {
        setState(() {
          _audiobook = audioBook;
        });
      }
    } catch (_) {}
  }

  /// Format duration in seconds to MM:SS format
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleStatusChange(String newStatus) async {
    final audiobook = _audiobook ?? widget.audiobook;
    await _audiobookService.editAudiobookStatus(audiobook, newStatus);
    await _loadFullAudiobook();
  }

  Widget _buildTitle() {
    return Text(
      widget.audiobook.title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildAuthor() {
    return Text(
      _audiobook?.author ?? widget.audiobook.author,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildChipsWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.audiobook.level,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        if (_audiobook?.category1.isNotEmpty ?? false)
          ContentCategoryChip(
            category: widget.audiobook.category1,
            useAudiobookTypeLabel: true,
            horizontalPadding: 14,
            verticalPadding: 8,
            borderRadius: 6,
          ),
        if (widget.audiobook.category2 != null &&
            widget.audiobook.category2!.isNotEmpty)
          ContentCategoryChip(
            category: widget.audiobook.category2!,
            horizontalPadding: 14,
            verticalPadding: 8,
            borderRadius: 6,
          ),
        if (widget.audiobook.category3 != null &&
            widget.audiobook.category3!.isNotEmpty)
          ContentCategoryChip(
            category: widget.audiobook.category3!,
            horizontalPadding: 14,
            verticalPadding: 8,
            borderRadius: 6,
          ),
        FavoriteToggleButton(
          isFavorite: _audiobook?.isFavorite ?? false,
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
              if (_audiobook == null) return;
              _audiobook!.isFavorite = !_audiobook!.isFavorite;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChapterTile({
    required Article chapter,
    required int chapterNumber,
    required bool isTablet,
  }) {
    final numberIcon = figureToFontAwesomeIcon(chapterNumber);
    final isFinished =
        chapter.readingStatus?.toLowerCase().trim() == 'finished';

    final numberWidget = numberIcon != null
        ? Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(numberIcon, size: 12, color: AppColors.textPrimary),
                const Text(
                  '.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$chapterNumber.',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          );

    final titleText = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: chapter.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          if (isFinished)
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  FontAwesomeIcons.badgeCheck,
                  fontWeight: FontWeight.w500,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );

    final durationBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        _formatDuration(chapter.duration ?? 0),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );

    final rowContent = isTablet
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              numberWidget,
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: titleText,
              ),
              const SizedBox(width: 24),
              durationBadge,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    numberWidget,
                    Expanded(child: titleText),
                  ],
                ),
              ),
              durationBadge,
            ],
          );

    final box = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: rowContent,
    );

    final tappable = GestureDetector(
      onTap: () async {
        if (widget.showLocker) {
          await presentPaywall();
          if (mounted) {
            ProfileStoreScope.of(context).load();
          }
          return;
        }
        await _audiobookService.editAudiobookStatus(
            widget.audiobook, 'started');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleOverviewPage(
                article: chapter,
                showLocker: false,
                onFavoriteToggle: () {}),
          ),
        );
      },
      child: box,
    );

    return isTablet
        ? Align(alignment: Alignment.centerLeft, child: tappable)
        : tappable;
  }

  Widget _buildTabletBackButton(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                FontAwesomeIcons.chevronLeft,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final imageUrl = _audiobook?.imageUrl ?? widget.audiobook.imageUrl;
    final status =
        _audiobook?.readingStatus ?? widget.audiobook.readingStatus;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (isTablet) _buildTabletBackButton(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image (mobile only — on tablet the image moves
                  // next to the info section below)
                  if (!isTablet)
                    ContentHeaderImage(
                      imageUrl: imageUrl,
                      status: status,
                      showStatusMenu: true,
                      onStatusChange: _handleStatusChange,
                    ),

                  // Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, isTablet ? 16 : 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildTitle(),
                                    const SizedBox(height: 8),
                                    _buildAuthor(),
                                    const SizedBox(height: 12),
                                    _buildChipsWrap(),
                                    const SizedBox(height: 16),
                                    Text(
                                      (_audiobook ?? widget.audiobook)
                                          .description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ContentSideImage(
                                imageUrl: imageUrl,
                                status: status,
                                showStatusMenu: true,
                                onStatusChange: _handleStatusChange,
                              ),
                            ],
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(child: _buildTitle()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildAuthor(),
                          const SizedBox(height: 12),
                          _buildChipsWrap(),
                          const SizedBox(height: 16),
                          Text(
                            (_audiobook ?? widget.audiobook).description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),

                        // Chapters section
                        Text(
                          AppLocalizations.of(context)!.chapters,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_audiobook == null)
                          const ChapterListSkeleton()
                        else if (_audiobook!.chapters.isNotEmpty) ...[
                          ..._audiobook!.chapters
                              .asMap()
                              .entries
                              .map((entry) => _buildChapterTile(
                                    chapter: entry.value,
                                    chapterNumber: entry.key + 1,
                                    isTablet: isTablet,
                                  )),
                        ],
                      ],
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
}
