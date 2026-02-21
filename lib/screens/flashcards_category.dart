import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';
import '../widgets/vocabulary_item_card.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';
import 'flashcards_deck.dart';
import '../widgets/flashcard_status_sheet.dart';

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
    print("widget.categoryName: ${widget.categoryName}");
    final flashcards = await flashcardService.getFlashcardsWithStatus(status: widget.categoryName);
    setState(() {
      _flashcards = flashcards;
      _isLoading = false;
    });
  }

  Future<void> _deleteFlashcard(int flashcardId) async {
    try {
      await flashcardService.deleteFlashcard(flashcardId);
        setState(() {
        _flashcards.removeWhere((flashcard) => flashcard.flashcardId == flashcardId);
      });
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
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
        await flashcardService.editStatusFlashcard(item.flashcardId!, newStatus);
        if (mounted) {
          setState(() {
            _flashcards.removeWhere((f) => f.flashcardId == item.flashcardId);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not update status: $e')),
          );
        }
      }
    }
  }
  

  void _onReadFlashcards() {
    // Navigate to flashcard deck screen with the loaded flashcards
    if (_flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flashcards available')),
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
                      widget.categoryName == 'saved'
                          ? 'Saved Vocabulary'
                          : widget.categoryName == 'difficult'
                              ? 'Difficult Vocabulary'
                              : widget.categoryName == 'training'
                                  ? 'Training Vocabulary'
                                  : widget.categoryName == 'mastered' ? 'Mastered Vocabulary' : 'Vocabulary',
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
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
                                  : widget.categoryName == 'mastered' ? FontAwesomeIcons.badgeCheck : Icons.menu,
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
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
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _flashcards.isEmpty
                          ? const Center(
                              child: Text(
                                'No flashcards found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: _flashcards.length,
                              itemBuilder: (context, index) {
                                final item = _flashcards[index];
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
                                  confirmDismiss: (direction) async {
                                    // Show confirmation dialog
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Flashcard'),
                                        content: Text('Are you sure you want delete "${item.word}" from your ${widget.categoryName == 'saved' ? 'Saved' : widget.categoryName == 'difficult' ? 'Difficult' : widget.categoryName == 'training' ? 'Training' : widget.categoryName == 'mastered' ? 'Mastered' : ''} Vocabulary?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ) ?? false;
                                  },
                                  onDismissed: (direction) async {
                                    if (item.flashcardId != null) await _deleteFlashcard(item.flashcardId!);
                                  },
                                  child: VocabularyItemCard(
                                    item: item,
                                    displayType: 'flashcard',
                                    onIconToggle: () => _onIconToggle(item),
                                  ),
                                );
                              },
                            ),
            ),

            // Buttons
            if (!_isLoading && _errorMessage == null && _flashcards.isNotEmpty)
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test your knowledge feature coming soon')),
                          );
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
                            const Text(
                              'Test your Knowledge',
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
                            const Text(
                              'Read Flashcards',
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

