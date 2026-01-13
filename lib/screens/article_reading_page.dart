import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/article_content.dart';
import '../models/quiz_question.dart';
import '../constants/app_colors.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/quiz_content_widget.dart';
import '../services/quiz_service.dart';

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
  
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _repeatMode = false;
  
  // Highlighting state for audio synchronization
  int? _currentHighlightedIndex; // Content segment index (legacy)
  int? _currentHighlightedWordIndex; // Word index from contentTimestamps
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _contentKeys = {};
  
  // Precomputed word ranges for each content segment
  // Maps segment index to (startWordIndex, endWordIndex) in contentTimestamps
  Map<int, (int, int)> _segmentWordRanges = {};
  
  double _fontSize = 16.0;
  bool _showTranslation = true;
  bool _showTranslationAfterParagraph = true;

  // Quiz state
  late QuizService _quizService;
  List<QuizQuestion> _quizModelQuestions = [];
  bool _isLoadingQuiz = true;
  int? _quizResultId;
  bool _quizCompleted = false;
  int _correctAnswersCount = 0;
  Map<int, int> _userAnswers = {}; // questionIndex -> answerIndex

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Initialize quiz service
    _quizService = QuizService(Supabase.instance.client);
    
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
          _currentHighlightedWordIndex = null;
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
    
    // Precompute word ranges for each segment
    _computeSegmentWordRanges();
    
    // Load audio if available
    _loadAudio();
    
    // Load quiz questions and create quiz result
    _initializeQuiz(false);
  }

  Future<void> _initializeQuiz(bool retry) async {
    try {
      final contentId = int.tryParse(widget.article.id);
      if (contentId == null) {
        setState(() {
          _isLoadingQuiz = false;
        });
        return;
      }

      // Fetch quiz questions for this content
      final questions = await _quizService.getQuizQuestionsForContent(contentId);
      
      if (questions.isNotEmpty) {
        // Get current user
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          // Create a quiz result entry using the first question's quiz_id
          final quizId = questions.first.quizId ?? questions.first.id;
          final result = await _quizService.createQuizResult(
            referenceId: contentId,
            quizId: quizId,
            userId: user.id,
            type: 1,
          );
          print('result: $result');
          if (result != null && result['filled_out'] == true) {
            print('already filledout');
            setState(() {
              _quizModelQuestions = questions;
              _quizResultId = result['id'] as int?;
              _correctAnswersCount = result['number_correct_answers'] as int? ?? 0;
              _quizCompleted = retry ? false : true;
              _isLoadingQuiz = false;
            });
          } else {
            setState(() {
              _quizModelQuestions = questions;
              _quizResultId = result?['id'] as int?;
              _isLoadingQuiz = false;
            });
          }
        } else {
          setState(() {
            _quizModelQuestions = questions;
            _isLoadingQuiz = false;
          });
        }
      } else {
        setState(() {
          _isLoadingQuiz = false;
        });
      }
    } catch (e) {
      print('Error initializing quiz: $e');
      setState(() {
        _isLoadingQuiz = false;
      });
    }
  }
  
  // Update highlighted segment based on audio position
  void _updateHighlightedSegment(Duration position) {
    if (!_isPlaying) return;
    
    final positionSeconds = position.inMilliseconds / 1000.0;
    
    // Use word-level timestamps if available (more precise)
    if (widget.article.contentTimestamps != null && 
        widget.article.contentTimestamps!.isNotEmpty) {
      int? newHighlightedWordIndex;
      print('contentTimestamps: ${widget.article.contentTimestamps}');
      // Find the word that matches the current audio position
      for (int i = 0; i < widget.article.contentTimestamps!.length; i++) {
        final wordTimestamp = widget.article.contentTimestamps![i];
        if (positionSeconds >= wordTimestamp.start && 
            positionSeconds < wordTimestamp.end) {
          newHighlightedWordIndex = i;
          break;
        }
      }
      
      // Update highlight if it changed
      if (newHighlightedWordIndex != _currentHighlightedWordIndex) {
        setState(() {
          _currentHighlightedWordIndex = newHighlightedWordIndex;
        });
        
        // Auto-scroll to keep highlighted content visible
        if (newHighlightedWordIndex != null) {
          _scrollToHighlightedWord(newHighlightedWordIndex);
        }
      }
      print('content: $widget.article.content.length');

    } else {
      // Fallback to segment-level highlighting if no word timestamps
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
  
  // Scroll to the content segment containing the highlighted word
  void _scrollToHighlightedWord(int wordIndex) {
    if (widget.article.contentTimestamps == null || 
        wordIndex >= widget.article.contentTimestamps!.length) {
      return;
    }
    
    // Find which content segment contains this word
    // We'll estimate based on word index relative to total words
    final totalWords = widget.article.contentTimestamps!.length;
    final wordsPerSegment = totalWords / widget.article.content.length;
    final segmentIndex = (wordIndex / wordsPerSegment).floor();
    final clampedIndex = segmentIndex.clamp(0, widget.article.content.length - 1);
    
    _scrollToContent(clampedIndex);
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
  
  /// Precompute word ranges for each content segment by matching words
  /// This creates a mapping from segment index to (startWordIndex, endWordIndex)
  void _computeSegmentWordRanges() {
    if (widget.article.contentTimestamps == null || 
        widget.article.contentTimestamps!.isEmpty) {
      return;
    }
    
    _segmentWordRanges = {};
    int currentTimestampIndex = 0;
    final timestamps = widget.article.contentTimestamps!;
    
    for (int segmentIndex = 0; segmentIndex < widget.article.content.length; segmentIndex++) {
      final segmentText = widget.article.content[segmentIndex].originalText;
      final segmentWords = _extractWordsNormalized(segmentText);
      
      if (segmentWords.isEmpty) {
        continue;
      }
      
      final startIndex = currentTimestampIndex;
      int matchedWords = 0;
      
      // Match words from timestamps to segment words
      while (currentTimestampIndex < timestamps.length && 
             matchedWords < segmentWords.length) {
        final timestampWord = _normalizeWord(timestamps[currentTimestampIndex].word);
        final expectedWord = segmentWords[matchedWords];
        
        // Check if words match (allowing for some flexibility)
        if (_wordsMatch(timestampWord, expectedWord)) {
          matchedWords++;
        }
        currentTimestampIndex++;
      }
      
      // Store the range for this segment
      final endIndex = currentTimestampIndex - 1;
      if (startIndex <= endIndex && startIndex < timestamps.length) {
        _segmentWordRanges[segmentIndex] = (startIndex, endIndex);
      }
    }
  }
  
  /// Normalize a word for matching (lowercase, remove punctuation)
  String _normalizeWord(String word) {
    return word.toLowerCase().replaceAll(RegExp(r'[^\w\sàâäéèêëïîôùûüœæç]'), '').trim();
  }
  
  /// Extract words from text and normalize them
  List<String> _extractWordsNormalized(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => _normalizeWord(w))
        .where((w) => w.isNotEmpty)
        .toList();
  }
  
  /// Check if two words match (with some flexibility for punctuation differences)
  bool _wordsMatch(String word1, String word2) {
    if (word1 == word2) return true;
    // Allow partial match if one contains the other (for contractions etc.)
    if (word1.contains(word2) || word2.contains(word1)) return true;
    // Check if first few characters match (for variations)
    if (word1.length >= 3 && word2.length >= 3) {
      return word1.substring(0, 3) == word2.substring(0, 3);
    }
    return false;
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
                color: AppColors.white,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
              _buildActionButton(Icons.translate, () {
                setState(() {
                  _showTranslation = !_showTranslation;
                });
              }),
              const SizedBox(width: 12),
              _buildActionButton(Icons.text_fields, () {
                _showFontSizeDialog();
              }),
              if (_showTranslation) ...[
                const SizedBox(width: 12),
                _buildActionButton(_showTranslationAfterParagraph ? Icons.view_headline_rounded : Icons.view_stream_rounded, () {
                   setState(() {
                     _showTranslationAfterParagraph = !_showTranslationAfterParagraph;
                   });
                }),
              ],
             ],
          ),
          const SizedBox(width: 12),
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
      child: _showTranslationAfterParagraph
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original text (e.g., French) with word-level highlighting
                _buildTextWithWordHighlighting(
                  content.originalText,
                  index,
                  isHighlighted,
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
            )
          : _buildPhraseByPhraseContent(content, index, isHighlighted),
    );
  }
  
  // Build content showing each phrase with translation below
  Widget _buildPhraseByPhraseContent(ArticleContent content, int index, bool isHighlighted) {
    // Split text into sentences/phrases
    final originalPhrases = _splitIntoPhrases(content.originalText);
    final translationPhrases = _splitIntoPhrases(content.translationText);
    
    // Use the maximum length to show all phrases
    final maxPhraseCount = originalPhrases.length > translationPhrases.length
        ? originalPhrases.length
        : translationPhrases.length;
    
    // Calculate word offsets for each phrase within this segment
    final phraseWordOffsets = <int>[];
    int cumulativeWordCount = 0;
    for (int i = 0; i < originalPhrases.length; i++) {
      phraseWordOffsets.add(cumulativeWordCount);
      // Count words in this phrase
      final wordsInPhrase = originalPhrases[i]
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().isNotEmpty)
          .length;
      cumulativeWordCount += wordsInPhrase;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(maxPhraseCount, (phraseIndex) {
        final hasOriginal = phraseIndex < originalPhrases.length;
        final hasTranslation = phraseIndex < translationPhrases.length;
        
        // Skip if neither exists (shouldn't happen, but safe guard)
        if (!hasOriginal && !hasTranslation) {
          return const SizedBox.shrink();
        }
        
        // Get word offset for this phrase
        final wordOffset = phraseIndex < phraseWordOffsets.length 
            ? phraseWordOffsets[phraseIndex] 
            : 0;
        
        return Padding(
          padding: EdgeInsets.only(bottom: phraseIndex < maxPhraseCount - 1 ? 16 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original phrase with word-level highlighting
              if (hasOriginal)
                _buildTextWithWordHighlighting(
                  originalPhrases[phraseIndex],
                  index,
                  isHighlighted,
                  wordOffsetInSegment: wordOffset,
                ),
              if (hasOriginal && hasTranslation && _showTranslation)
                const SizedBox(height: 8),
              // Translation phrase
              if (hasTranslation && _showTranslation)
                Text(
                  translationPhrases[phraseIndex],
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
      }),
    );
  }
  
  // Split text into phrases (sentences)
  List<String> _splitIntoPhrases(String text) {
    if (text.trim().isEmpty) return [];
    
    // Use regex to match sentences: content ending with . ! or ? followed by space or end
    // This pattern matches: one or more characters (non-whitespace or whitespace) ending with sentence punctuation
    final regex = RegExp(r'[^.!?]*[.!?]+(?:\s+|$)', multiLine: true);
    final matches = regex.allMatches(text);
    
    final phrases = <String>[];
    int lastEnd = 0;
    
    for (final match in matches) {
      final phrase = match.group(0)?.trim();
      if (phrase != null && phrase.isNotEmpty) {
        phrases.add(phrase);
        lastEnd = match.end;
      }
    }
    
    // If no matches found or there's remaining text, handle it
    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        // If we found some phrases, add remaining as last phrase
        // If no phrases found, return whole text as single phrase
        if (phrases.isEmpty) {
          return [text.trim()];
        } else {
          phrases.add(remaining);
        }
      }
    }
    
    // If no phrases were found (e.g., no sentence-ending punctuation), return whole text
    if (phrases.isEmpty) {
      return [text.trim()];
    }
    
    return phrases;
  }
  
  // Build text with word-level highlighting based on timestamps
  // wordOffsetInSegment: offset to add to the word index within this segment (for phrase-by-phrase mode)
  Widget _buildTextWithWordHighlighting(
    String text, 
    int contentIndex, 
    bool isSegmentHighlighted, 
    {int wordOffsetInSegment = 0}
  ) {
    // If no word timestamps available, fall back to regular text
    if (widget.article.contentTimestamps == null || 
        widget.article.contentTimestamps!.isEmpty ||
        !_segmentWordRanges.containsKey(contentIndex)) {
      return Text(
        text,
        style: TextStyle(
          fontSize: _fontSize,
          color: AppColors.textPrimary,
          height: 1.6,
          fontWeight: isSegmentHighlighted ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }
    
    // Get precomputed word range for this content segment
    final (startWordIndex, endWordIndex) = _segmentWordRanges[contentIndex]!;
    
    // Split text into parts (words + spaces) while preserving layout
    final parts = _splitTextPreservingLayout(text);
    
    // Build text spans with highlighting
    final textSpans = <TextSpan>[];
    int currentWordInText = 0;
    
    for (final part in parts) {
      // Check if this part is a word (not whitespace)
      final trimmed = part.trim();
      final isWord = trimmed.isNotEmpty;
      
      if (isWord) {
        // Calculate which word timestamp index this corresponds to
        // Use the wordOffsetInSegment to account for words in previous phrases
        final actualWordIndex = startWordIndex + wordOffsetInSegment + currentWordInText;
        
        // Ensure we don't exceed bounds
        if (actualWordIndex <= endWordIndex && 
            actualWordIndex < widget.article.contentTimestamps!.length) {
          final isWordHighlighted = actualWordIndex == _currentHighlightedWordIndex;
          
          textSpans.add(
            TextSpan(
              text: part,
              style: TextStyle(
                fontSize: _fontSize,
                color: isWordHighlighted 
                    ? AppColors.textPrimary 
                    : AppColors.textPrimary,
                fontWeight: FontWeight.normal,
                // fontWeight: isWordHighlighted 
                //     ? FontWeight.w700 
                //     : (isSegmentHighlighted ? FontWeight.w600 : FontWeight.normal),
                backgroundColor: isWordHighlighted 
                    ? AppColors.primary.withOpacity(0.2) 
                    : Colors.transparent,
                decoration: TextDecoration.none,
              ),
            ),
          );
          currentWordInText++;
        } else {
          // Word index out of bounds, just render normally
          textSpans.add(
            TextSpan(
              text: part,
              style: TextStyle(
                fontSize: _fontSize,
                color: AppColors.textPrimary,
                fontWeight: isSegmentHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }
      } else {
        // Whitespace - render normally without highlighting
        textSpans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              fontSize: _fontSize,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }
    }
    
    return RichText(
      text: TextSpan(
        children: textSpans,
        style: TextStyle(
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
  
  // Split text into parts (words + spaces) while preserving layout
  List<String> _splitTextPreservingLayout(String text) {
    final parts = <String>[];
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      // Check if current char is whitespace
      final isWhitespace = char == ' ' || char == '\n' || char == '\t';
      
      if (isWhitespace && buffer.isNotEmpty) {
        // End of word, add word then whitespace
        parts.add(buffer.toString());
        buffer.clear();
        buffer.write(char);
      } else if (!isWhitespace && buffer.toString().trim().isEmpty && buffer.isNotEmpty) {
        // End of whitespace, add whitespace then start word
        parts.add(buffer.toString());
        buffer.clear();
        buffer.write(char);
      } else {
        buffer.write(char);
      }
    }
    
    // Add remaining part
    if (buffer.isNotEmpty) {
      parts.add(buffer.toString());
    }
    
    return parts;
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
    if (_isLoadingQuiz) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      );
    }

    if (_quizCompleted) {
      return _buildQuizCompletedView();
    }

    if (_quizModelQuestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No quiz available for this article',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
        ),
      );
    }

    return QuizContentWidget(
      questions: _quizModelQuestions,
      onQuizComplete: _onQuizComplete,
    );
  }

  void _onQuizComplete(int correctAnswers, Map<int, int> userAnswers) async {
    setState(() {
      _quizCompleted = true;
      _correctAnswersCount = correctAnswers;
      _userAnswers = userAnswers;
    });

    // Update quiz result in database
    if (_quizResultId != null) {
      try {
        await _quizService.updateQuizResult(
          resultId: _quizResultId!,
          numberCorrectAnswers: correctAnswers,
        );
      } catch (e) {
        print('Error updating quiz result: $e');
      }
    }
  }

  Widget _buildQuizCompletedView() {
    final totalQuestions = _quizModelQuestions.length;
    final percentage = totalQuestions > 0 
        ? (_correctAnswersCount / totalQuestions * 100).round() 
        : 0;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Quiz completed image
            Container(
              width: 160,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo/quizlogo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Congratulations text
            const Text(
              'Quiz Completed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Score
            Text(
              '$_correctAnswersCount / $totalQuestions',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              '$percentage% correct',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            
            // Retry button
            GestureDetector(
              onTap: () {
                setState(() {
                  _quizCompleted = false;
                  _correctAnswersCount = 0;
                  _userAnswers = {};
                });
                // Create new quiz result for retry
                _initializeQuiz(true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.borderBlack,
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_quizModelQuestions.isNotEmpty && _userAnswers.isNotEmpty) ...[
            Text(
              'Answers',
              style: TextStyle(
                fontSize: 28,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            ..._quizModelQuestions.asMap().entries.map((entry) {
              final questionIndex = entry.key;
              final question = entry.value;
              final userAnswerIndex = _userAnswers[questionIndex];
              final isCorrect = userAnswerIndex != null && 
                  question.isCorrectAnswer(userAnswerIndex);
              final labels = ['A', 'B', 'C', 'D'];
              final userAnswerLabel = userAnswerIndex != null 
                  ? labels[userAnswerIndex] 
                  : '';
              final correctAnswerIndex = question.correctAnswer - 1; // Convert 1-based to 0-based
              final correctAnswerLabel = labels[correctAnswerIndex];
              final correctAnswerText = question.answers[correctAnswerIndex];
              final userAnswerText = userAnswerIndex != null 
                  ? question.answers[userAnswerIndex] 
                  : '';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Colored bar on the left
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: isCorrect 
                              ? const Color(0xFF4CAF50) // Light green
                              : const Color(0xFFF44336), // Light red
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Question and answer content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${questionIndex + 1}. ${question.question}',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (userAnswerIndex != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isCorrect 
                            ? const Color(0xFF4CAF50) // Light green
                            : const Color(0xFFF44336), 
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$userAnswerLabel. $userAnswerText',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                             if (!isCorrect) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$correctAnswerLabel. $correctAnswerText',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
      backgroundColor: AppColors.white,
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
      backgroundColor: AppColors.white,
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
