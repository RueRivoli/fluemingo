import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';

class FlashcardsDeckPage extends StatefulWidget {
  final List<VocabularyItem> flashcards;


  const FlashcardsDeckPage({
    super.key,
    required this.flashcards,
  });

  @override
  State<FlashcardsDeckPage> createState() => _FlashcardsDeckPageState();
}

class _FlashcardsDeckPageState extends State<FlashcardsDeckPage> {
  int _currentIndex = 0;
  late AudioPlayer _audioPlayer;
  late final FlashcardService flashcardService;
  bool _isPlaying = false;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    flashcardService = FlashcardService(Supabase.instance.client);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _dragOffset = 0.0;
      });
    }
  }

  void _moveToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _dragOffset = 0.0;
      });
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

  Future<void> _onIconToggle(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      if (item.status != null) {
        await supabase
            .from('flashcards_fr')
            .delete()
            .eq('user_id', user.id)
            .eq('text', item.word);

        setState(() {
          item.status = null;
        });
      } else {
        await supabase.from('flashcards_fr').insert({
          'user_id': user.id,
          'text': item.word,
          'text_translation': item.translation,
          'function': item.type,
        });

        setState(() {
          item.status = 'saved';
        });
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
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

    final currentCard = widget.flashcards[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.primary, // Light purple background
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
                  const Center(
                    child: Text(
                      'Flashcards',
                      style: TextStyle(
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
                      '${_currentIndex + 1} / ${widget.flashcards.length}',
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
                  setState(() {
                    _dragOffset += details.delta.dx;
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (_dragOffset > 100 && _currentIndex > 0) {
                    _moveToPrevious();
                  } else if (_dragOffset < -100 && _currentIndex < widget.flashcards.length - 1) {
                    _moveToNext();
                  } else {
                    setState(() {
                      _dragOffset = 0.0;
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Show up to 5 cards stacked (render back to front)
                    for (int i = 4; i >= 0; i--)
                      if (_currentIndex + i < widget.flashcards.length)
                        _buildStackedCard(widget.flashcards[_currentIndex + i], i),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedCard(VocabularyItem card, int stackIndex) {
    // Calculate transform for stack effect - overlapping from top
    final horizontalOffset = _dragOffset * (stackIndex == 0 ? 1.0 : 0.0) + (stackIndex * 3.0); // Slight horizontal offset for depth
    final verticalOffset = stackIndex * 25.0; // Increased vertical offset for better visibility (overlapping from top)
    final scale = 1.0 - (stackIndex * 0.05); // More scale difference for cards behind
    final opacity = stackIndex == 0 ? 1.0 : (1.0 - stackIndex * 0.15); // Better opacity gradient
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
                // Bookmark section in top-left
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _onIconToggle(card),
                      child: Icon(
                        card.status == 'saved' ? Icons.bookmark : Icons.bookmark_border,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    if (card.status == 'saved') ...[
                      const SizedBox(width: 6),
                      const Text(
                        'saved',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A4A4A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Part of speech label
                Text(
                  _getPartOfSpeech(card.type),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // French word with yellow highlight, speaker icon, and translation aligned vertically
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Word and speaker icon in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        //   decoration: BoxDecoration(
                        //     color: AppColors.secondary,
                        //     borderRadius: BorderRadius.circular(4),
                        //   ),
                          child: Text(
                            card.word,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
               
                    GestureDetector(
                          onTap: () => _playAudio(card.audioUrl),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.volume_up,
                              size: 24,
                              color: const Color(0xFF4A4A4A),
                            ),
                          ),
                        ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        card.translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                // Example sentence in French
                  Center(
                  child: Container(
                    child: Text(
                        card.exampleSentence ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Example sentence in English
                 Center(
                  child: Container(
                    child: Text(
                       card.exampleTranslation ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF8A8A8A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const Spacer(), // Push buttons to bottom
                const SizedBox(height: 24),
                // Bottom buttons: Difficult and Training
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Difficult button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (card.id != null) await flashcardService.updateFlashcardStatus(card.id!, 'difficult');
                          setState(() {
                            card.status = 'difficult';
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5), // Slightly red background
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFD0D0D0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning,
                                size: 20,
                                color: const Color(0xFF4A4A4A),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Difficult',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Training button
                    Expanded(
                      child: GestureDetector(
                         onTap: () async {
                          if (card.id != null) await flashcardService.updateFlashcardStatus(card.id!, 'difficult');
                          setState(() {
                            card.status = 'training';
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.3), // Slightly secondary background
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFD0D0D0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                              ),
                               Icon(
                                Icons.refresh,
                                size: 20,
                                color: const Color(0xFF4A4A4A),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Needs Training',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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