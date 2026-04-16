import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/vocabulary_item_skeleton.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';
import 'flashcards_deck.dart';
import '../widgets/flashcard_status_sheet.dart';
import '../l10n/app_localizations.dart';
import '../utils/flashcard_snackbar.dart';
import '../utils/flashcard_dialogs.dart';

class FlashcardsCategoryPage extends StatefulWidget {
  final String categoryName;

  const FlashcardsCategoryPage({
    super.key,
    required this.categoryName,
  });

  @override
  State<FlashcardsCategoryPage> createState() => _FlashcardsCategoryPageState();
}

class _FlashcardsCategoryPageState extends State<FlashcardsCategoryPage> {
  late final FlashcardService flashcardService;
  List<VocabularyItem> _flashcards = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _audioPollTimer;
  int _audioPollAttempts = 0;
  static const int _audioPollMaxAttempts = 10; // 10 * 3s = 30s

  String _toTitleCase(String value) {
    return value
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }


  @override
  void initState() {
    super.initState();
    flashcardService = FlashcardService(Supabase.instance.client);
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final flashcards = await flashcardService.getFlashcardsWithStatus(
        status: widget.categoryName);
    if (!mounted) return;
    setState(() {
      _flashcards = flashcards;
      _isLoading = false;
    });
    _maybeStartAudioPoll();
  }

  bool _hasMissingAudio() {
    return _flashcards.any((v) =>
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
        final refreshed = await flashcardService.getFlashcardsWithStatus(
            status: widget.categoryName);
        if (!mounted) return;
        setState(() {
          _flashcards = refreshed;
        });
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

  Future<void> _deleteFlashcard(int flashcardId) async {
    await flashcardService.deleteFlashcard(flashcardId);
    if (!mounted) return;
    setState(() {
      _flashcards
          .removeWhere((flashcard) => flashcard.flashcardId == flashcardId);
    });
  }

  Future<void> _onIconToggle(VocabularyItem item) async {
    if (item.flashcardId == null) return;

    final newStatus = await FlashcardStatusSheet.show(
      context,
      word: item.word,
      currentStatus: item.status ?? widget.categoryName,
    );

    if (newStatus != null && mounted && newStatus != widget.categoryName) {
      try {
        await flashcardService.updateFlashcardStatus(
            item.flashcardId!, newStatus);
        if (mounted) {
          setState(() {
            _flashcards.removeWhere((f) => f.flashcardId == item.flashcardId);
          });
          FlashcardSnackbar.show(context, newStatus);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorUpdatingStatus)),
          );
        }
      }
    }
  }

  void _onReadFlashcards() {
    // Navigate to flashcard deck screen with the loaded flashcards
    if (_flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noFlashcardsAvailable)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardsDeckPage(
          flashcards: _flashcards,
          categoryName: widget.categoryName,
        ),
      ),
    ).then((_) {
      // Recharger les flashcards quand on revient de la page deck
      _loadFlashcards();
    });
  }

  Widget _buildDismissibleFlashcardItem(VocabularyItem item) {
    return Dismissible(
      key: Key('flashcard_${item.flashcardId ?? item.word}_${item.type}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) =>
          confirmDeleteFlashcard(context, item.word),
      onDismissed: (direction) async {
        if (item.flashcardId != null) {
          await _deleteFlashcard(item.flashcardId!);
        }
      },
      child: VocabularyItemCard(
        item: item,
        displayType: 'flashcard',
        onIconToggle: () => _onIconToggle(item),
        isAudioPending: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Handle back navigation - always pop with true to trigger refresh
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Centered title
                    Center(
                      child: Text(
                        _toTitleCase(
                          widget.categoryName == 'saved'
                              ? AppLocalizations.of(context)!.savedVocabulary
                              : widget.categoryName == 'difficult'
                                  ? AppLocalizations.of(context)!
                                      .difficultVocabulary
                                  : widget.categoryName == 'training'
                                      ? AppLocalizations.of(context)!
                                          .trainingVocabulary
                                      : widget.categoryName == 'mastered'
                                          ? AppLocalizations.of(context)!
                                              .masteredVocabulary
                                          : AppLocalizations.of(context)!
                                              .vocabulary,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Back button on the left
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        width: 40,
                        height: 40,
                        child: const Icon(
                          FontAwesomeIcons.arrowLeft,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                    // Save icon on the right
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        widget.categoryName == 'saved'
                            ? FontAwesomeIcons.floppyDisk
                            : widget.categoryName == 'difficult'
                                ? FontAwesomeIcons.triangleExclamation
                                : widget.categoryName == 'training'
                                    ? FontAwesomeIcons.dumbbell
                                    : widget.categoryName == 'mastered'
                                        ? FontAwesomeIcons.badgeCheck
                                        : Icons.menu,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Flashcards list
              Expanded(
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
                        child: VocabularyListSkeleton(itemCount: 6),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadFlashcards,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: Text(AppLocalizations.of(context)!.retry),
                                ),
                              ],
                            ),
                          )
                        : _flashcards.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noFlashcardsFound,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final isTabletLayout =
                                      constraints.maxWidth >= 700;
                                  if (!isTabletLayout) {
                                    return ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 100),
                                      itemCount: _flashcards.length,
                                      itemBuilder: (context, index) =>
                                          _buildDismissibleFlashcardItem(
                                        _flashcards[index],
                                      ),
                                    );
                                  }

                                  final itemWidth =
                                      (constraints.maxWidth - 40 - 12) / 2;
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 100),
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 0,
                                      children: _flashcards
                                          .map((item) => SizedBox(
                                                width: itemWidth,
                                                child:
                                                    _buildDismissibleFlashcardItem(
                                                        item),
                                              ))
                                          .toList(),
                                    ),
                                  );
                                },
                              ),
              ),

              // Buttons
              if (!_isLoading &&
                  _errorMessage == null &&
                  _flashcards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      // Test your knowledge button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement test your knowledge functionality
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlashcardsDeckPage(
                                  flashcards: _flashcards,
                                  categoryName: widget.categoryName,
                                  hideMeanings: true,
                                ),
                              ),
                            ).then((_) {
                              _loadFlashcards();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.blockQuestion,
                                color: Colors.black,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.testYourKnowledge,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Read Flashcards button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onReadFlashcards,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.cardsBlank,
                                color: Colors.black,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.readFlashcards,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }
}
