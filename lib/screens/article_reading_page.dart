import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/article_content.dart';
import '../constants/app_colors.dart';
import '../widgets/vocabulary_item_card.dart';

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
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _repeatMode = false;
  
  // Highlighting state for audio synchronization
  int? _currentHighlightedIndex;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _contentKeys = {};
  
  double _fontSize = 16.0;
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
    
    // Initialize audio player
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing != _isPlaying) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
      // Reset playing state when audio completes
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentHighlightedIndex = null;
        });
      }
    });
    
    // Listen to audio position for word highlighting
    _audioPlayer.positionStream.listen((position) {
      _updateHighlightedSegment(position);
    });
    
    // Initialize content keys for scrolling
    for (int i = 0; i < widget.article.content.length; i++) {
      _contentKeys[i] = GlobalKey();
    }
    
    // Load audio if available
    _loadAudio();
  }
  
  // Update highlighted segment based on audio position
  void _updateHighlightedSegment(Duration position) {
    if (!_isPlaying) return;
    
    final positionSeconds = position.inMilliseconds / 1000.0;
    int? newHighlightedIndex;
    
    // Find the content segment that matches the current audio position
    for (int i = 0; i < widget.article.content.length; i++) {
      final content = widget.article.content[i];
      if (content.startTime != null && content.endTime != null) {
        if (positionSeconds >= content.startTime! && 
            positionSeconds < content.endTime!) {
          newHighlightedIndex = i;
          break;
        }
      }
    }
    
    // Update highlight if it changed
    if (newHighlightedIndex != _currentHighlightedIndex) {
      setState(() {
        _currentHighlightedIndex = newHighlightedIndex;
      });
      
      // Auto-scroll to keep highlighted content visible
      if (newHighlightedIndex != null) {
        _scrollToContent(newHighlightedIndex);
      }
    }
  }
  
  // Scroll to a specific content segment
  void _scrollToContent(int index) {
    final key = _contentKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }
  
  Future<void> _loadAudio() async {
    if (widget.article.audioUrl != null && widget.article.audioUrl!.isNotEmpty) {
      try {
        await _audioPlayer.setUrl(widget.article.audioUrl!);
        await _updatePlaybackSpeed();
        if (_repeatMode) {
          await _audioPlayer.setLoopMode(LoopMode.one);
        }
      } catch (e) {
        print('Error loading audio: $e');
      }
    }
  }
  
  Future<void> _updatePlaybackSpeed() async {
    try {
      await _audioPlayer.setSpeed(_playbackSpeed);
    } catch (e) {
      print('Error updating playback speed: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
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
            if (_selectedTabIndex == 0) _buildPlaybackControls(),
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
    final content = widget.article.content;
    if (content.isEmpty) {
      return const Center(
        child: Text('No content available'),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.asMap().entries.map((entry) {
          return _buildContent(entry.value, entry.key);
        }).toList(),
      ),
    );
  }

  Widget _buildContent(ArticleContent content, int index) {
    final isHighlighted = _currentHighlightedIndex == index;
    
    return AnimatedContainer(
      key: _contentKeys[index],
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: 24,
        left: isHighlighted ? 8 : 0,
        right: isHighlighted ? 8 : 0,
        top: isHighlighted ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? AppColors.primary.withOpacity(0.15) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted 
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original text (e.g., French)
          Text(
            content.originalText,
            style: TextStyle(
              fontSize: _fontSize,
              color: AppColors.textPrimary,
              height: 1.6,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
          // Translation text (e.g., English)
          if (_showTranslation)
            Text(
              content.translationText,
              style: TextStyle(
                fontSize: _fontSize,
                color: isHighlighted 
                    ? AppColors.textPrimary.withOpacity(0.7) 
                    : AppColors.textSecondary,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVocabularyContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: widget.article.vocabulary.map((item) {
      return VocabularyItemCard(
        item: item,
        onBookmarkToggle: () {
          setState(() {
            item.isSaved = !item.isSaved;
          });
        },
      );
    }).toList(),
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
              onTap: () async {
                if (widget.article.audioUrl == null || widget.article.audioUrl!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No audio available for this article')),
                  );
                  return;
                }
                
                try {
                  if (_isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    // Check if audio has completed - if so, restart from beginning
                    final processingState = _audioPlayer.processingState;
                    if (processingState == ProcessingState.completed) {
                      await _audioPlayer.seek(Duration.zero);
                    }
                    
                    // Ensure audio is loaded before playing
                    if (processingState == ProcessingState.idle ||
                        processingState == ProcessingState.loading) {
                      await _loadAudio();
                    }
                    
                    // Ensure speed is set before playing
                    await _updatePlaybackSpeed();
                    await _audioPlayer.play();
                  }
                } catch (e) {
                  print('Error toggling playback: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error playing audio: $e')),
                  );
                }
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
              onTap: () async {
                setState(() {
                  _repeatMode = !_repeatMode;
                });
                // Toggle repeat mode
                try {
                  await _audioPlayer.setLoopMode(
                    _repeatMode ? LoopMode.one : LoopMode.off,
                  );
                } catch (e) {
                  print('Error setting repeat mode: $e');
                }
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
              ...([0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
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
                  onTap: () async {
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    // Update playback speed
                    await _updatePlaybackSpeed();
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
