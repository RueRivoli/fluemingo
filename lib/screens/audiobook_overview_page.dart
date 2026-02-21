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
import '../models/audiobook.dart';
import '../services/audiobook_service.dart';
import '../services/profile_service.dart';
import 'article_overview_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/audiobooks_themes.dart';
import '../l10n/app_localizations.dart';

class AudiobookOverviewPage extends StatefulWidget {
  final Audiobook audiobook;

  const AudiobookOverviewPage({super.key, required this.audiobook});

  @override
  State<AudiobookOverviewPage> createState() => _AudiobookOverviewPageState();
}

class _AudiobookOverviewPageState extends State<AudiobookOverviewPage> {
  Audiobook? _audiobook;
  late final AudiobookService _audiobookService;
  late final ProfileService _profileService;
  bool _isLoadingAudiobook = true;
  String? _referenceLanguage;

  @override
  void initState() {
    super.initState();
    _audiobookService = AudiobookService(Supabase.instance.client);
    _profileService = ProfileService(Supabase.instance.client);
    _loadFullAudiobook();
    _loadProfileForReferenceLanguage();
  }

  Future<void> _loadProfileForReferenceLanguage() async {
    try {
      final profileData = await _profileService.getProfileData();
      if (mounted) {
        setState(() {
          _referenceLanguage = profileData['native_language']?.toString();
        });
      }
    } catch (_) {
      // User may not be logged in; keep _referenceLanguage null
    }
  }

  Future<void> _loadFullAudiobook() async {
    setState(() {
      _isLoadingAudiobook = true;
    });

    try {
      final audioBook = await _audiobookService.getAudiobookById(widget.audiobook.id);
      if (audioBook != null) {
        setState(() {
          _audiobook = audioBook;
          _isLoadingAudiobook = false;
        });
      } else {
        setState(() {
          _isLoadingAudiobook = false;
        });
      }
    } catch (e) {
      print('Error loading audiobbok: $e');
      setState(() {
        _isLoadingAudiobook = false;
      });
    }
  }

  /// Format duration in seconds to MM:SS format
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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

  /// Description in the user's reference (native) language when available, otherwise default.
  String _getDescriptionForDisplay(Audiobook? book) {
    if (book == null) return widget.audiobook.description;
    final ref = _referenceLanguage?.toLowerCase();
    if (ref == 'en' && book.descriptionRef != null && book.descriptionRef!.isNotEmpty) {
      return book.descriptionRef!;
    }
    return book.description;
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
                        _audiobook?.imageUrl ?? '',
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
                      // Status badge bottom left
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: ContentStatusBadge(
                          status: _audiobook?.readingStatus ?? null,
                          compact: false,
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
                                widget.audiobook.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Author
                        Text(
                          _audiobook?.author ?? widget.audiobook.author,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
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
                            // Category tags (only when they have content)
                            if (_audiobook?.category1?.isNotEmpty ?? false) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  audiobookTypeLabel(context, widget.audiobook.category1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ),
                            ],
                            if (widget.audiobook.category2 != null && widget.audiobook.category2!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  audiobookThemeLabel(context, widget.audiobook.category2!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ),
                            ],
                            if (widget.audiobook.category3 != null && widget.audiobook.category3!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  audiobookThemeLabel(context, widget.audiobook.category3!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description (in reference language when available)
                        Text(
                          _getDescriptionForDisplay(_audiobook),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Chapters section
                        if (_audiobook != null && _audiobook!.chapters.isNotEmpty) ...[
                          Text(
                            AppLocalizations.of(context)!.chapters,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...(_audiobook!.chapters.asMap().entries.map((entry) {
                            final chapterIndex = entry.key;
                            final chapter = entry.value;
                            final chapterNumber = chapterIndex + 1;
                            final numberIcon = _numberToFontAwesomeIcon(chapterNumber);
                            return GestureDetector(
                              onTap: () async {
                                await _audiobookService.editAudiobookStatus(widget.audiobook, 'started');
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleOverviewPage(article: chapter),
                                  ),
                                );
                              },
                              child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (numberIcon != null)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(numberIcon, size: 12, color: AppColors.textPrimary),
                                                Text(
                                                  '.',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Text(
                                              '$chapterNumber.',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            chapter.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
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
                                  ),
                                ],
                              ),
                            ));
                          })),
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

