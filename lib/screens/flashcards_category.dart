import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';
import '../widgets/vocabulary_item_card.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';
import 'flashcards_deck.dart';

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

  Future<void> _onIconToggle(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      if (item.status == 'saved') {
        // Remove from flashcards_fr
        await supabase
            .from('flashcards_fr')
            .delete()
            .eq('user_id', user.id)
            .eq('text', item.word);

        // Update local state
        setState(() {
          item.status = null;
          _flashcards.removeWhere((flashcard) => flashcard.word == item.word);
        });
      } else {
        // Add to flashcards_fr
        await supabase.from('flashcards_fr').insert({
          'user_id': user.id,
          'text': item.word,
          'text_translation': item.translation,
          'function': item.type,
        });

        // Update local state
        setState(() {
          item.status = 'saved';
        });
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      rethrow;
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
        ),
      ),
    ).then((_) {
    // Recharger les flashcards quand on revient de la page deck
    _loadFlashcards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          ? 'Bookmarked Vocabulary'
                          : widget.categoryName == 'difficult'
                              ? 'Difficult Vocabulary'
                              : widget.categoryName == 'training'
                                  ? 'Training Vocabulary'
                                  : widget.categoryName == 'acknowledged' ? 'Acknowledged Vocabulary' : 'Vocabulary',
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
                    onTap: () => Navigator.of(context).pop(),
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
                                return VocabularyItemCard(
                                  item: item,
                                  onIconToggle: () => _onIconToggle(item),
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
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Test your knowledge',
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
                            const Icon(
                              Icons.play_arrow,
                              color: AppColors.textPrimary,
                              size: 24,
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
    );
  }
}

