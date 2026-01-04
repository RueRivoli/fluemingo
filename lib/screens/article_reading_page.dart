import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/article_paragraph.dart';
import '../constants/app_colors.dart';

class ArticleReadingPage extends StatefulWidget {
  final Article article;

  const ArticleReadingPage({super.key, required this.article});

  @override
  State<ArticleReadingPage> createState() => _ArticleReadingPageState();
}

class _ArticleReadingPageState extends State<ArticleReadingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  // Audio playback state
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _repeatMode = false;
  
  // Font size state
  double _fontSize = 16.0;
  
  // Settings
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (_selectedTabIndex) {
      case 0: // Article
        return AppColors.background;
      case 1: // Vocabulary
        return AppColors.secondary;
      case 2: // Quiz
        return AppColors.primary;
      default:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            _buildTopBar(),
            
            // Tab navigation
            _buildTabBar(),
            
            // Action buttons
            if (_selectedTabIndex == 0) _buildActionButtons(),
            
            // Content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildArticleContent(),
                  _buildVocabularyContent(),
                  _buildQuizContent(),
                ],
              ),
            ),
            
            // Bottom playback controls
            _buildPlaybackControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'Article',
              0,
              AppColors.secondary,
              AppColors.black,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'Vocabulary',
              1,
              AppColors.primary,
              AppColors.white,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'Quiz',
              2,
              AppColors.white,
            AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, Color selectedColor, Color? textColor) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: isSelected ? Border.all(
                  color: AppColors.borderBlack,
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor != null && isSelected ? textColor : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.translate, () {
            setState(() {
              _showTranslation = !_showTranslation;
            });
          }),
          _buildActionButton(Icons.bookmark_border, () {
            // TODO: Toggle bookmark
          }),
          _buildActionButton(Icons.text_fields, () {
            _showFontSizeDialog();
          }),
          _buildActionButton(Icons.more_vert, () {
            // TODO: Show settings
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    final paragraphs = widget.article.paragraphs;
    if (paragraphs.isEmpty) {
      return const Center(
        child: Text('No content available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: paragraphs.map((paragraph) {
          return _buildParagraph(paragraph);
        }).toList(),
      ),
    );
  }

  Widget _buildParagraph(ArticleParagraph paragraph) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original text (e.g., French)
          _buildHighlightedText(paragraph.originalText),
          const SizedBox(height: 12),
          // Translation text (e.g., English)
          if (_showTranslation)
            Text(
              paragraph.translationText,
              style: TextStyle(
                fontSize: _fontSize,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    // Extract dates and highlight them (handles "Le 17 décembre 2025" and "On December 17, 2025")
    final datePattern = RegExp(r'(Le\s+|On\s+)?\d{1,2}[,\s]+\w+\s+\d{4}', caseSensitive: false);
    final matches = datePattern.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: _fontSize,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      );
    }

    // Build text spans with highlighted dates
    final textSpans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > lastEnd) {
        textSpans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            fontSize: _fontSize,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ));
      }

      // Add highlighted date
      textSpans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          fontSize: _fontSize,
          color: const Color(0xFF6B5CE6), // Darker purple for dates
          fontWeight: FontWeight.w600,
          height: 1.6,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          fontSize: _fontSize,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }

  Widget _buildVocabularyContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: widget.article.vocabulary.map((item) {
        return _buildVocabularyItem(item);
      }).toList(),
    );
  }

  Widget _buildVocabularyItem(VocabularyItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isSaved ? AppColors.primary : AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Word and translation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '(${item.type}) ${item.translation}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Bookmark button
          GestureDetector(
            onTap: () {
              setState(() {
                item.isSaved = !item.isSaved;
              });
            },
            child: Icon(
              item.isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 26,
              color: item.isSaved ? AppColors.primary : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Quiz coming soon',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Play button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
                // TODO: Toggle audio playback
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            // Speed button
            GestureDetector(
              onTap: _showSpeedDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'x$_playbackSpeed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Repeat button
            GestureDetector(
              onTap: () {
                setState(() {
                  _repeatMode = !_repeatMode;
                });
                // TODO: Toggle repeat mode
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _repeatMode ? AppColors.primary : AppColors.neutral,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.repeat,
                  color: _repeatMode ? Colors.white : AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Playback Speed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...([0.75, 1.0, 1.25, 1.5].map((speed) {
                final isSelected = _playbackSpeed == speed;
                return ListTile(
                  title: Text(
                    'x$speed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    Navigator.pop(context);
                  },
                );
              })),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Slider(
                        value: _fontSize,
                        min: 14,
                        max: 24,
                        divisions: 10,
                        label: _fontSize.toStringAsFixed(0),
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                          this.setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '14',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _fontSize.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '24',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

