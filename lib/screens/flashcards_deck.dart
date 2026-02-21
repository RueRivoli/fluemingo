import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';
import '../utils/flashcards.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlashcardsDeckPage extends StatefulWidget {
  final List<VocabularyItem> flashcards;  
  final String categoryName;

  const FlashcardsDeckPage({
    super.key,
    required this.flashcards,
    required this.categoryName,
  });

  @override
  State<FlashcardsDeckPage> createState() => _FlashcardsDeckPageState();
}

class _FlashcardsDeckPageState extends State<FlashcardsDeckPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AudioPlayer _audioPlayer;
  late final FlashcardService flashcardService;
  bool _isPlaying = false;
  double _dragOffset = 0.0;
  late List<VocabularyItem> _flashcards;

  static const _transitionDuration = Duration(milliseconds: 280);
  late AnimationController _transitionController;
  late Animation<double> _transitionAnimation;
  int _transitionDirection = 0; // 0 none, 1 next, -1 previous
  double _dragOffsetAtTransitionStart = 0.0;

  @override
  void initState() {
    super.initState();
    flashcardService = FlashcardService(Supabase.instance.client);
    _audioPlayer = AudioPlayer();
    _flashcards = List.from(widget.flashcards);
    _transitionController = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    );
    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    );
    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex += _transitionDirection;
          _transitionDirection = 0;
          _dragOffset = 0.0;
          _transitionController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

    Color getColorPlayIcon(String? status) {
      switch (status) {
        case 'saved':
          return AppColors.primary;
        case 'difficult':
          return AppColors.error;
        case 'training':
          return AppColors.secondary;
        case 'mastered':
          return AppColors.success;
        default:
          return Colors.black;
      }
    return Colors.black;
  }


  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio available')),
      );
      return;
    }

    try {
      setState(() {
        _isPlaying = true;
      });

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  void _moveToNext() {
    if (_currentIndex < _flashcards.length - 1 && _transitionDirection == 0) {
      setState(() {
        _transitionDirection = 1;
        _dragOffsetAtTransitionStart = _dragOffset;
        _transitionController.forward(from: 0.0);
      });
    } else if (_currentIndex == _flashcards.length - 1 && _transitionDirection == 0) {
      setState(() {
        _currentIndex++;
        _dragOffset = 0.0;
      });
    }
  }

  void _moveToPrevious() {
    if (_currentIndex > 0 && _transitionDirection == 0) {
      setState(() {
        _transitionDirection = -1;
        _dragOffsetAtTransitionStart = _dragOffset;
        _transitionController.forward(from: 0.0);
      });
    }
  }

  Color getCardBorderColor() {
        switch (widget.categoryName) {
          case 'saved':
            return AppColors.primary.withOpacity(0.2);
          case 'difficult':
            return AppColors.error.withOpacity(0.2);
          case 'training':
            return AppColors.secondary.withOpacity(0.2);
          case 'mastered':
            return AppColors.success.withOpacity(0.2);
          default:
            return Colors.black.withOpacity(0.2);
      }
    }

  Future<void> _updateStatusAndNext(VocabularyItem card, String status) async {
    try {
      if (card.flashcardId != null) {
        await flashcardService.updateFlashcardStatus(card.flashcardId!, status);
      }
    } catch (e) {
      print('Error updating flashcard status: $e');
    } finally {
      _moveToNext();
    }
  }

  String _getPartOfSpeech(String type) {
    // Convert type abbreviations to full names
    final typeMap = {
      'n': 'NOUN',
      'v': 'VERB',
      'adj': 'ADJECTIVE',
      'adv': 'ADVERB',
      'prep': 'PREPOSITION',
      'pron': 'PRONOUN',
      'conj': 'CONJUNCTION',
      'interj': 'INTERJECTION',
    };
    return typeMap[type.toLowerCase()] ?? type.toUpperCase();
  }


  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: widget.categoryName == 'saved' ? AppColors.primary : widget.categoryName == 'difficult' ? AppColors.error : widget.categoryName == 'training' ? AppColors.secondary : widget.categoryName == 'mastered' ? AppColors.success : AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No flashcards available',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Check if we've gone through all cards
    if (_currentIndex >= _flashcards.length) {
      return Scaffold(
                backgroundColor: widget.categoryName == 'saved' ? AppColors.primary : widget.categoryName == 'difficult' ? AppColors.error : widget.categoryName == 'training' ? AppColors.secondary : widget.categoryName == 'mastered' ? AppColors.success : AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar with back button and title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Centered title
                    Center(
                      child: Text(
                        '${widget.categoryName.isNotEmpty ? "${widget.categoryName[0].toUpperCase()}${widget.categoryName.substring(1)}" : widget.categoryName} Flashcards',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Empty placeholder
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.badgeCheck,
                        size: 80,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'All done!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You\'ve reviewed all ${_flashcards.length} flashcards',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _flashcards[_currentIndex];

    return Scaffold(
      backgroundColor: widget.categoryName == 'saved' ? AppColors.primary : widget.categoryName == 'difficult' ? AppColors.error : widget.categoryName == 'training' ? AppColors.secondary : widget.categoryName == 'mastered' ? AppColors.success : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button, title, and progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Centered title
                  Center(
                    child: Text(
                      '${widget.categoryName.isNotEmpty ? "${widget.categoryName[0].toUpperCase()}${widget.categoryName.substring(1)}" : widget.categoryName} Flashcards',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // Progress indicator on the right
                  Positioned(
                    right: 0,
                    child: Text(
                      '${_currentIndex + 1} / ${_flashcards.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Flashcard area with stacked cards
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (_transitionDirection == 0) {
                    setState(() {
                      _dragOffset += details.delta.dx;
                    });
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (_transitionDirection != 0) return;
                  if (_dragOffset > 100 && _currentIndex > 0) {
                    _moveToPrevious();
                  } else if (_dragOffset < -100 && _currentIndex < _flashcards.length - 1) {
                    _moveToNext();
                  } else if (_currentIndex == _flashcards.length - 1 && _dragOffset < -100) {
                    _moveToNext(); // go to "all done"
                  } else {
                    setState(() {
                      _dragOffset = 0.0;
                    });
                  }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    if (_transitionDirection != 0) {
                      return AnimatedBuilder(
                        animation: _transitionAnimation,
                        builder: (context, _) {
                          final t = _transitionAnimation.value;
                          final targetFromOffset = screenWidth * _transitionDirection;
                          final fromOffset = _dragOffsetAtTransitionStart + (targetFromOffset - _dragOffsetAtTransitionStart) * t;
                          final toOffset = screenWidth * _transitionDirection * (1 - t);
                          final toIndex = _currentIndex + _transitionDirection;
                          return Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              // "To" card (slides in)
                              if (toIndex >= 0 && toIndex < _flashcards.length)
                                _buildStackedCardWithOffset(
                                  _flashcards[toIndex],
                                  0,
                                  toOffset,
                                  showDelete: false,
                                ),
                              // "From" card (slides out) with slight fade
                              Opacity(
                                opacity: 1.0 - (t * 0.2),
                                child: _buildStackedCardWithOffset(
                                  _flashcards[_currentIndex],
                                  0,
                                  fromOffset,
                                  showDelete: true,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        for (int i = 4; i >= 0; i--)
                          if (_currentIndex + i < _flashcards.length)
                            _buildStackedCard(_flashcards[_currentIndex + i], i),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Peek amount in px: how much of the next card is visible at the top (deck effect).
  static const double _deckPeekAmount = 14.0;
  /// Horizontal step per card in the stack (slight fan so the deck edge is visible).
  static const double _deckStepX = 6.0;

  Widget _buildStackedCard(VocabularyItem card, int stackIndex) {
    // Deck effect: next cards sit slightly higher so a strip peeks at the top; slight horizontal step
    final horizontalOffset = _dragOffset * (stackIndex == 0 ? 1.0 : 0.0) + (stackIndex * _deckStepX);
    final verticalOffset = stackIndex == 0 ? 0.0 : -(stackIndex * _deckPeekAmount);
    final scale = 1.0 - (stackIndex * 0.04);
    final opacity = stackIndex == 0 ? 1.0 : (1.0 - stackIndex * 0.12);
    return _buildStackedCardInner(card, stackIndex, horizontalOffset, verticalOffset, scale, opacity, showDelete: stackIndex == 0);
  }

  Widget _buildStackedCardWithOffset(VocabularyItem card, int stackIndex, double horizontalOffset, {bool showDelete = true}) {
    final verticalOffset = stackIndex * 25.0; // keep simple when used for transition
    return _buildStackedCardInner(card, stackIndex, horizontalOffset, verticalOffset, 1.0, 1.0, showDelete: showDelete);
  }

  Widget _buildStackedCardInner(VocabularyItem card, int stackIndex, double horizontalOffset, double verticalOffset, double scale, double opacity, {bool showDelete = true}) {
    final isTopCard = stackIndex == 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth - 40;
    final cardHeight = screenHeight * 0.65; // Make cards taller (65% of screen height)

    return Transform.translate(
      offset: Offset(horizontalOffset, 20 + verticalOffset), // Position cards higher with top overlap
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: cardWidth - (stackIndex * 10),
            height: cardHeight - (stackIndex * 20), // More size difference for stacked cards
            padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25 * (1 - stackIndex * 0.1)),
                    blurRadius: 25 - (stackIndex * 4),
                    offset: Offset(0, 6 + stackIndex * 3),
                    spreadRadius: stackIndex * 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                // Bookmark section in top-left, delete icon in top-right
                Builder(
                  builder: (context) {
                    final statusEnum = card.status != null 
                        ? FlashcardStatus.fromString(card.status) 
                        : null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => (),
                              child: Icon(
                                card.status == 'saved' ? FontAwesomeIcons.solidFloppyDisk :  card.status == 'difficult' ? FontAwesomeIcons.solidTriangleExclamation : card.status == 'training' ? FontAwesomeIcons.solidDumbbell : card.status == 'mastered' ? FontAwesomeIcons.solidBadgeCheck : Icons.bookmark_border,
                                size: 22,
                                color: widget.categoryName == 'saved' ? AppColors.primary : widget.categoryName == 'difficult' ? AppColors.error : widget.categoryName == 'training' ? AppColors.secondary : widget.categoryName == 'mastered' ? AppColors.success : Colors.white,
                              ),
                            ),
                            if (statusEnum != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                flashcardStatusToText(statusEnum),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: widget.categoryName == 'saved' ? AppColors.primary : widget.categoryName == 'difficult' ? AppColors.error : widget.categoryName == 'training' ? AppColors.secondary : widget.categoryName == 'mastered' ? AppColors.success : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (showDelete && isTopCard && card.flashcardId != null)
                          GestureDetector(
                            onTap: () async {
                              try {
                                await flashcardService.deleteFlashcard(card.flashcardId!);
                                setState(() {
                                  _flashcards.removeAt(_currentIndex);
                                  if (_currentIndex >= _flashcards.length && _currentIndex > 0) {
                                    _currentIndex--;
                                  }
                                });
                              } catch (e) {
                                debugPrint('Error deleting flashcard: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting flashcard: $e')),
                                  );
                                }
                              }
                            },
                            child: FaIcon(
                              FontAwesomeIcons.xmark,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Part of speech label
                Text(
                  _getPartOfSpeech(card.type),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // French word with yellow highlight, speaker icon, and translation aligned vertically
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _playAudio(card.audioUrl),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                              shape: BoxShape.circle,
                             border: Border.all(
                  color: getCardBorderColor(),
                  width: 1,
                ),
                          ),
                          child: Icon(
                            _isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.solidPlayCircle,
                            size: 36,
                            color: getColorPlayIcon(card.status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.word,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FontAwesomeIcons.language, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Text(
                            card.translation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
                // Example sentence in French
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(FontAwesomeIcons.quoteLeft, size: 14, color: AppColors.textPrimary),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        card.exampleSentence ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(FontAwesomeIcons.quoteRight, size: 14, color: AppColors.textPrimary),
                  ],
                ),
                const SizedBox(height: 12),
                // Example sentence in English
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    Icon(FontAwesomeIcons.quoteLeft, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    card.exampleTranslation ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(FontAwesomeIcons.quoteRight, size: 14, color: AppColors.textSecondary),
                  ],
                ),
                const Spacer(), // Push buttons to bottom
                const SizedBox(height: 24),
                // Four status buttons: Saved, Difficult, Training, Mastered (icon only; current disabled)
                Text('Change Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatusIconButton(
                      status: 'saved',
                      label: 'Saved',
                      icon: FontAwesomeIcons.floppyDisk,
                      color: AppColors.primary,
                      isCurrent: (card.status ?? widget.categoryName) == 'saved',
                      onTap: () => _updateStatusAndNext(card, 'saved'),
                    ),
                    const SizedBox(width: 8),
                    _StatusIconButton(
                      status: 'difficult',
                      label: 'Difficult',
                      icon: FontAwesomeIcons.triangleExclamation,
                      color: AppColors.error,
                      isCurrent: (card.status ?? widget.categoryName) == 'difficult',
                      onTap: () => _updateStatusAndNext(card, 'difficult'),
                    ),
                    const SizedBox(width: 8),
                    _StatusIconButton(
                      status: 'training',
                      label: 'Training',
                      icon: FontAwesomeIcons.dumbbell,
                      color: AppColors.secondary,
                      isCurrent: (card.status ?? widget.categoryName) == 'training',
                      onTap: () => _updateStatusAndNext(card, 'training'),
                    ),
                    const SizedBox(width: 8),
                    _StatusIconButton(
                      status: 'mastered',
                      label: 'Mastered',
                      icon: FontAwesomeIcons.badgeCheck,
                      color: AppColors.success,
                      isCurrent: (card.status ?? widget.categoryName) == 'mastered',
                      onTap: () => _updateStatusAndNext(card, 'mastered'),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _StatusIconButton extends StatefulWidget {
  final String status;
  final String label;
  final IconData icon;
  final Color color;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _StatusIconButton({
    required this.status,
    required this.label,
    required this.icon,
    required this.color,
    required this.isCurrent,
    this.onTap,
  });

  @override
  State<_StatusIconButton> createState() => _StatusIconButtonState();
}

class _StatusIconButtonState extends State<_StatusIconButton> {
  double _pressScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.isCurrent ? AppColors.textGrey : widget.color;
    final borderColor = widget.isCurrent
        ? AppColors.textGrey.withOpacity(0.5)
        : widget.color.withOpacity(0.7);

    return Expanded(
      child: GestureDetector(
        onTapDown: widget.isCurrent ? null : (_) => setState(() => _pressScale = 0.92),
        onTapUp: widget.isCurrent ? null : (_) => setState(() => _pressScale = 1.0),
        onTapCancel: () => setState(() => _pressScale = 1.0),
        onTap: widget.isCurrent ? null : widget.onTap,
        child: AnimatedScale(
          scale: _pressScale,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isCurrent
                      ? AppColors.textGrey.withOpacity(0.2)
                      : widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Center(
                  child: FaIcon(widget.icon, size: 22, color: effectiveColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}