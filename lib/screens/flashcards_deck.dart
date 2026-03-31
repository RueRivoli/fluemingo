import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/word_types.dart';
import '../l10n/app_localizations.dart';
import '../constants/number_icons.dart';
import '../utils/flashcard_snackbar.dart';
import '../services/feedback_service.dart';

class FlashcardsDeckPage extends StatefulWidget {
  final List<VocabularyItem> flashcards;
  final String categoryName;
  final bool hideMeanings;

  const FlashcardsDeckPage({
    super.key,
    required this.flashcards,
    required this.categoryName,
    this.hideMeanings = false,
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
  bool _isRevealed = false;
  bool _isRevealAnimating = false;
  double _revealTurns = 0.0;

  static const _transitionDuration = Duration(milliseconds: 280);
  static const _revealDuration = Duration(milliseconds: 650);
  late AnimationController _transitionController;
  late Animation<double> _transitionAnimation;
  int _transitionDirection = 0; // 0 none, 1 next, -1 previous
  double _dragOffsetAtTransitionStart = 0.0;

  void _showFlashcardCategoryUpdatedSnackBar(String status) =>
      FlashcardSnackbar.show(context, status, showAtTop: true);

  @override
  void initState() {
    super.initState();
    _isRevealed = !widget.hideMeanings;
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
          _isRevealed = !widget.hideMeanings;
          _isRevealAnimating = false;
          _revealTurns = 0.0;
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
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noAudioAvailable)),
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
    } else if (_currentIndex == _flashcards.length - 1 &&
        _transitionDirection == 0) {
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
    return Colors.transparent;
  }

  Color _categoryColor() {
    return widget.categoryName == 'saved'
        ? AppColors.primary
        : widget.categoryName == 'difficult'
            ? AppColors.error
            : widget.categoryName == 'training'
                ? AppColors.secondary
                : widget.categoryName == 'mastered'
                    ? AppColors.success
                    : AppColors.textSecondary;
  }

  Future<void> _updateStatusAndNext(VocabularyItem card, String status) async {
    try {
      if (card.flashcardId != null) {
        await flashcardService.updateFlashcardStatus(card.flashcardId!, status);
        _showFlashcardCategoryUpdatedSnackBar(status);
        if (status == 'mastered') {
          FeedbackService.instance.playSuccess();
        }
      }
    } catch (e) {
      debugPrint('Error updating flashcard status: $e');
    } finally {
      _moveToNext();
    }
  }

  Future<bool> _confirmDeleteFlashcard(VocabularyItem card) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteFlashcard),
        content: Text(l10n.areYouSureYouWantToDeleteWord(card.word)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return shouldDelete == true;
  }

  String _getPartOfSpeech(String type) {
    return WORD_TYPES_FR[type] ?? type;
  }

  Future<void> _revealHiddenValues() async {
    if (!widget.hideMeanings || _isRevealed || _isRevealAnimating) return;
    setState(() {
      _isRevealAnimating = true;
      _revealTurns += 0.5;
    });

    // Reveal content as soon as the card reaches the midpoint of the flip.
    await Future.delayed(Duration(milliseconds: _revealDuration.inMilliseconds ~/ 2));
    if (!mounted) return;
    setState(() {
      _isRevealed = true;
    });

    // Let the second half of the flip complete.
    await Future.delayed(Duration(milliseconds: _revealDuration.inMilliseconds ~/ 2));
    if (!mounted) return;
    setState(() {
      _isRevealAnimating = false;
    });
  }

  Widget _buildExampleBlock({
    required String title,
    required String text,
    required Color textColor,
    required bool emphasized,
  }) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final titleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: textColor.withValues(alpha: 0.7),
      letterSpacing: 0.5,
    );

    return Column(
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: emphasized ? FontWeight.w500 : FontWeight.w400,
                    fontStyle: emphasized ? FontStyle.normal : FontStyle.normal,
                    color: textColor,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: widget.categoryName == 'saved'
            ? AppColors.primary
            : widget.categoryName == 'difficult'
                ? AppColors.error
                : widget.categoryName == 'training'
                    ? AppColors.secondary
                    : widget.categoryName == 'mastered'
                        ? AppColors.success
                        : AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.noFlashcardsAvailable,
                  style: const TextStyle(
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
                  child: Text(AppLocalizations.of(context)!.goBack),
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
        backgroundColor: widget.categoryName == 'saved'
            ? AppColors.primary
            : widget.categoryName == 'difficult'
                ? AppColors.error
                : widget.categoryName == 'training'
                    ? AppColors.secondary
                    : widget.categoryName == 'mastered'
                        ? AppColors.success
                        : AppColors.background,
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
                        child: Text(
                          AppLocalizations.of(context)!.goBack,
                          style: const TextStyle(
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

    return Scaffold(
      backgroundColor: widget.categoryName == 'saved'
          ? AppColors.primary
          : widget.categoryName == 'difficult'
              ? AppColors.error
              : widget.categoryName == 'training'
                  ? AppColors.secondary
                  : widget.categoryName == 'mastered'
                      ? AppColors.success
                      : AppColors.background,
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
                        FontAwesomeIcons.arrowLeft,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // Progress indicator on the right
                  Positioned(
                    right: 0,
                    child: Row(
                      children: [
                        Icon(
                            figureToFontAwesomeIcon(_currentIndex + 1) ??
                                FontAwesomeIcons.hashtag,
                            size: 20,
                            color: Colors.white),
                        Text(
                          '/ ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                            figureToFontAwesomeIcon(_flashcards.length) ??
                                FontAwesomeIcons.hashtag,
                            size: 20,
                            color: Colors.white),
                      ],
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
                  } else if (_dragOffset < -100 &&
                      _currentIndex < _flashcards.length - 1) {
                    _moveToNext();
                  } else if (_currentIndex == _flashcards.length - 1 &&
                      _dragOffset < -100) {
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
                    final availableHeight = constraints.maxHeight;
                    if (_transitionDirection != 0) {
                      return AnimatedBuilder(
                        animation: _transitionAnimation,
                        builder: (context, _) {
                          final t = _transitionAnimation.value;
                          final targetFromOffset =
                              screenWidth * _transitionDirection;
                          final fromOffset = _dragOffsetAtTransitionStart +
                              (targetFromOffset -
                                      _dragOffsetAtTransitionStart) *
                                  t;
                          final toOffset =
                              screenWidth * _transitionDirection * (1 - t);
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
                                  availableHeight: availableHeight,
                                ),
                              // "From" card (slides out) with slight fade
                              Opacity(
                                opacity: 1.0 - (t * 0.2),
                                child: _buildStackedCardWithOffset(
                                  _flashcards[_currentIndex],
                                  0,
                                  fromOffset,
                                  showDelete: true,
                                  availableHeight: availableHeight,
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
                            _buildStackedCard(_flashcards[_currentIndex + i], i,
                                availableHeight),
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

  Widget _buildStackedCard(
      VocabularyItem card, int stackIndex, double availableHeight) {
    // Deck effect: next cards sit slightly higher so a strip peeks at the top; slight horizontal step
    final horizontalOffset =
        _dragOffset * (stackIndex == 0 ? 1.0 : 0.0) + (stackIndex * _deckStepX);
    final verticalOffset =
        stackIndex == 0 ? 0.0 : -(stackIndex * _deckPeekAmount);
    final scale = 1.0 - (stackIndex * 0.04);
    final opacity = stackIndex == 0 ? 1.0 : (1.0 - stackIndex * 0.12);
    return _buildStackedCardInner(
        card, stackIndex, horizontalOffset, verticalOffset, scale, opacity,
        availableHeight: availableHeight,
        showDelete: stackIndex == 0,
        enableRevealAnimation: stackIndex == 0 && _transitionDirection == 0);
  }

  Widget _buildStackedCardWithOffset(
      VocabularyItem card, int stackIndex, double horizontalOffset,
      {bool showDelete = true, required double availableHeight}) {
    final verticalOffset =
        stackIndex * 25.0; // keep simple when used for transition
    return _buildStackedCardInner(
        card, stackIndex, horizontalOffset, verticalOffset, 1.0, 1.0,
        availableHeight: availableHeight,
        showDelete: showDelete,
        enableRevealAnimation: false);
  }

  Widget _buildStackedCardInner(
      VocabularyItem card,
      int stackIndex,
      double horizontalOffset,
      double verticalOffset,
      double scale,
      double opacity,
      {bool showDelete = true,
      required double availableHeight,
      required bool enableRevealAnimation}) {
    final isTopCard = stackIndex == 0;
    final showHiddenValues =
        !widget.hideMeanings || (enableRevealAnimation && _isRevealed);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40;
    // Card extends to bottom of screen: only top offset (20), no bottom margin
    final cardHeight = availableHeight - 20;

    return Transform.translate(
      offset: Offset(horizontalOffset,
          20 + verticalOffset), // Position cards with top overlap
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: 0, end: enableRevealAnimation ? _revealTurns : 0),
            duration: _revealDuration,
            curve: Curves.easeInOutCubic,
            builder: (context, turns, child) {
              final angle = turns * 2 * math.pi;
              final normalizedAngle = angle % (2 * math.pi);
              final isBackFace = normalizedAngle > (math.pi / 2) &&
                  normalizedAngle < (3 * math.pi / 2);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isBackFace
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: child,
                      )
                    : child,
              );
            },
            child: Container(
              width: cardWidth - (stackIndex * 10),
              height: cardHeight -
                  (stackIndex * 20), // More size difference for stacked cards
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.25 * (1 - stackIndex * 0.1)),
                    blurRadius: 25 - (stackIndex * 4),
                    offset: Offset(0, 6 + stackIndex * 3),
                    spreadRadius: stackIndex * 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Scrollable content so card doesn't overflow on small screens
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bookmark section in top-left, delete icon in top-right
                          Builder(
                            builder: (context) {
                              final statusColor = _categoryColor();
                              final statusIcon = card.status == 'saved'
                                  ? FontAwesomeIcons.solidFloppyDisk
                                  : card.status == 'difficult'
                                      ? FontAwesomeIcons
                                          .solidTriangleExclamation
                                      : card.status == 'training'
                                          ? FontAwesomeIcons.solidDumbbell
                                          : card.status == 'mastered'
                                              ? FontAwesomeIcons.solidBadgeCheck
                                              : Icons.bookmark_border;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          statusIcon,
                                          size: 20,
                                          color: statusColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (showDelete &&
                                      isTopCard &&
                                      card.flashcardId != null)
                                    GestureDetector(
                                      onTap: () async {
                                        final confirmed =
                                            await _confirmDeleteFlashcard(card);
                                        if (!confirmed || !mounted) return;
                                        try {
                                          await flashcardService
                                              .deleteFlashcard(
                                                  card.flashcardId!);
                                          setState(() {
                                            _flashcards.removeAt(_currentIndex);
                                            _isRevealed = !widget.hideMeanings;
                                            _isRevealAnimating = false;
                                            _revealTurns = 0.0;
                                            if (_currentIndex >=
                                                    _flashcards.length &&
                                                _currentIndex > 0) {
                                              _currentIndex--;
                                            }
                                          });
                                        } catch (e) {
                                          debugPrint(
                                              'Error deleting flashcard: $e');
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting flashcard: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: FaIcon(
                                        FontAwesomeIcons.trashCan,
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
                          if (card.type.isNotEmpty)
                            Text(
                              _getPartOfSpeech(card.type),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 6),
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
                                      _isPlaying
                                          ? FontAwesomeIcons.pause
                                          : FontAwesomeIcons.solidCirclePlay,
                                      size: 36,
                                      color: getColorPlayIcon(card.status),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 0.5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _categoryColor(),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    card.word,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: _categoryColor(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (showHiddenValues)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(FontAwesomeIcons.language,
                                          size: 18,
                                          color: AppColors.textSecondary),
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
                                if (card.basis != null &&
                                    card.basis!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.lightArrowRightLong,
                                        size: 22,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        card.basis!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!showHiddenValues &&
                              widget.hideMeanings &&
                              isTopCard) ...[
                            const SizedBox(height: 54),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _isRevealAnimating
                                    ? null
                                    : _revealHiddenValues,
                                icon: _isRevealAnimating
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        FontAwesomeIcons.arrowRotateRight,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                label: const Text(
                                  'Reveal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  backgroundColor:
                                      getColorPlayIcon(card.status),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (showHiddenValues) ...[
                            const SizedBox(height: 34),
                            _buildExampleBlock(
                              title: 'EXAMPLE',
                              text: card.exampleSentence ?? '',
                              textColor: AppColors.textPrimary,
                              emphasized: true,
                            ),
                            const SizedBox(height: 12),
                            _buildExampleBlock(
                              title: 'TRANSLATION',
                              text: card.exampleTranslation ?? '',
                              textColor: AppColors.textSecondary,
                              emphasized: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Four status buttons: Saved, Difficult, Training, Mastered (fixed at bottom, no overflow)
                  Text(
                    AppLocalizations.of(context)!.changeStatus,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusIconButton(
                        status: 'saved',
                        label: 'Saved',
                        icon: FontAwesomeIcons.floppyDisk,
                        color: AppColors.primary,
                        isCurrent:
                            (card.status ?? widget.categoryName) == 'saved',
                        onTap: () => _updateStatusAndNext(card, 'saved'),
                      ),
                      const SizedBox(width: 8),
                      _StatusIconButton(
                        status: 'difficult',
                        label: 'Difficult',
                        icon: FontAwesomeIcons.triangleExclamation,
                        color: AppColors.error,
                        isCurrent:
                            (card.status ?? widget.categoryName) == 'difficult',
                        onTap: () => _updateStatusAndNext(card, 'difficult'),
                      ),
                      const SizedBox(width: 8),
                      _StatusIconButton(
                        status: 'training',
                        label: 'Training',
                        icon: FontAwesomeIcons.dumbbell,
                        color: AppColors.secondary,
                        isCurrent:
                            (card.status ?? widget.categoryName) == 'training',
                        onTap: () => _updateStatusAndNext(card, 'training'),
                      ),
                      const SizedBox(width: 8),
                      _StatusIconButton(
                        status: 'mastered',
                        label: 'Mastered',
                        icon: FontAwesomeIcons.badgeCheck,
                        color: AppColors.success,
                        isCurrent:
                            (card.status ?? widget.categoryName) == 'mastered',
                        onTap: () => _updateStatusAndNext(card, 'mastered'),
                      ),
                    ],
                  ),
                ],
              ),
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
        onTapDown:
            widget.isCurrent ? null : (_) => setState(() => _pressScale = 0.92),
        onTapUp:
            widget.isCurrent ? null : (_) => setState(() => _pressScale = 1.0),
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
