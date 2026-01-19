import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/article_paragraph.dart';
import '../models/sentence_timestamp.dart';
import '../models/article_paragraph.dart';
import '../models/article_sentence.dart';
import '../constants/app_colors.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/quiz_content_widget.dart';
import '../services/quiz_service.dart';
import '../controllers/quiz_controller.dart';

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
  int? _currentHighlightedSentenceIndex; // Index in contentTimestamps list
  final ScrollController _scrollController = ScrollController();
  
  // Keys for each sentence to enable scrolling
  final Map<int, GlobalKey> _sentenceKeys = {};
  
  double _fontSize = 16.0;
  bool _showTranslation = true;
  bool _showTranslationAfterParagraph = false;

  // Quiz state
  late QuizController _quizController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Initialize quiz controller
    _quizController = QuizController(
      quizService: QuizService(Supabase.instance.client),
      articleId: widget.article.id,
    );
    _quizController.addListener(() {
      setState(() {}); // Rebuild when quiz state changes
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
          _currentHighlightedSentenceIndex = null;
        });
      }
    });
    
    // Listen to audio position for sentence highlighting
    _audioPlayer.positionStream.listen((position) {
      _updateHighlightedSentence(position);
    });
    
    // Initialize sentence keys for scrolling
    _initializeSentenceKeys();
    
    // Load audio if available
    _loadAudio();
    
    // Load quiz questions and create quiz result
    _quizController.initializeQuiz(false);
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
  
  void _initializeSentenceKeys() {
    final paragraphs = widget.article.paragraphs;
    if (paragraphs.isEmpty) return;
    
    int globalIndex = 0;
    for (final paragraph in paragraphs) {
      for (final sentence in paragraph.sentences) {
        _sentenceKeys[globalIndex] = GlobalKey();
        globalIndex++;
      }
    }
  }
  
  // Update highlighted sentence based on audio position
  void _updateHighlightedSentence(Duration position) {
    final paragraphs = widget.article.paragraphs;
    if (paragraphs.isEmpty) return;
    
    final positionSeconds = position.inMilliseconds / 1000.0;
    
    // Find the sentence that contains the current audio position
    int? newHighlightedIndex;
    int globalIndex = 0;
    
    for (final paragraph in paragraphs) {
      for (final sentence in paragraph.sentences) {
        if (sentence.startTime != null && sentence.endTime != null) {
          if (positionSeconds >= sentence.startTime! && positionSeconds <= sentence.endTime!) {
            newHighlightedIndex = globalIndex;
            break;
          }
        }
        globalIndex++;
      }
      if (newHighlightedIndex != null) break;
    }
    
    // Only update if the highlighted sentence changed
    if (newHighlightedIndex != _currentHighlightedSentenceIndex) {
      setState(() {
        _currentHighlightedSentenceIndex = newHighlightedIndex;
      });
      
      // Scroll to keep the highlighted sentence centered
      if (newHighlightedIndex != null) {
        _scrollToSentence(newHighlightedIndex);
      }
    }
  }
  
  // Scroll to center the highlighted sentence on screen
  void _scrollToSentence(int sentenceIndex) {
    final key = _sentenceKeys[sentenceIndex];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.4, // 0.4 means the sentence will be ~40% from the top (roughly centered)
      );
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
    _quizController.dispose();
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
                  _buildArticleParagraphs(),
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

  Widget _buildArticleParagraphs() {
    final paragraphs = widget.article.paragraphs;
    print('paragraphs: ${paragraphs}');
    if (paragraphs.isEmpty) {
      return const Center(
        child: Text('No paragraphs available'),
      );
    }
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render paragraphs with their sentences
          ...paragraphs.asMap().entries.map((paragraphEntry) {
            final paragraphIndex = paragraphEntry.key;
            final paragraph = paragraphEntry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render sentences in this paragraph
                if (_showTranslationAfterParagraph)
                  // Inline rendering when translations are shown after paragraph
                  _buildInlineParagraphSentences(paragraph, paragraphIndex, paragraphs)
                else
                  // Normal rendering with line breaks
                  ...paragraph.sentences.asMap().entries.map((sentenceEntry) {
                    final sentenceIndexInParagraph = sentenceEntry.key;
                    final sentence = sentenceEntry.value;
                    
                    // Calculate global sentence index
                    int globalSentenceIndex = 0;
                    for (int i = 0; i < paragraphIndex; i++) {
                      globalSentenceIndex += paragraphs[i].sentences.length;
                    }
                    globalSentenceIndex += sentenceIndexInParagraph;
                    
                    return _buildArticleSentenceWidget(sentence, globalSentenceIndex);
                  }),
                // Show translations at the end of paragraph if enabled
                if (_showTranslation && _showTranslationAfterParagraph) ...[
                  const SizedBox(height: 16),
                  Text(
                    paragraph.sentences
                        .where((sentence) => sentence.translationText.isNotEmpty)
                        .map((sentence) => sentence.translationText)
                        .join(' '),
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
                // Add spacing between paragraphs
                if (paragraphIndex < paragraphs.length - 1)
                  const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }
  
  // Build inline paragraph sentences (no line breaks between sentences)
  Widget _buildInlineParagraphSentences(
    ArticleParagraph paragraph,
    int paragraphIndex,
    List<ArticleParagraph> allParagraphs,
  ) {
    // Calculate the starting global index for this paragraph
    int startingGlobalIndex = 0;
    for (int i = 0; i < paragraphIndex; i++) {
      startingGlobalIndex += allParagraphs[i].sentences.length;
    }
    
    // Build TextSpans for each sentence with highlighting support
    final textSpans = <TextSpan>[];
    for (int i = 0; i < paragraph.sentences.length; i++) {
      final sentence = paragraph.sentences[i];
      final globalIndex = startingGlobalIndex + i;
      final isHighlighted = _currentHighlightedSentenceIndex == globalIndex;
      
      textSpans.add(
        TextSpan(
          text: sentence.originalText + (i < paragraph.sentences.length - 1 ? ' ' : ''),
          style: TextStyle(
            fontSize: _fontSize,
            color: isHighlighted 
                ? AppColors.primary 
                : AppColors.textPrimary,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            height: 1.6,
          ),
        ),
      );
    }
    
    return Container(
      key: _sentenceKeys[startingGlobalIndex], // Use first sentence key for scrolling
      child: RichText(
        text: TextSpan(children: textSpans),
      ),
    );
  }
  
  // Build a single article sentence widget with highlighting support
  Widget _buildArticleSentenceWidget(ArticleSentence sentence, int globalIndex) {
    final isHighlighted = _currentHighlightedSentenceIndex == globalIndex;
    final displayText = sentence.originalText;
    final translation = _showTranslation ? sentence.translationText : null;
    
    return AnimatedContainer(
      key: _sentenceKeys[globalIndex],
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: isHighlighted ? 12 : 4,
        vertical: isHighlighted ? 10 : 4,
      ),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? AppColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted 
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 2)
            : null,
        boxShadow: isHighlighted 
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original sentence
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: _fontSize,
              color: isHighlighted 
                  ? AppColors.primary 
                  : AppColors.textPrimary,
              height: 1.6,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
            child: Text(displayText),
          ),
          // Translation if enabled and available
          if (translation != null && !_showTranslationAfterParagraph) ...[
            const SizedBox(height: 8),
            Text(
              translation,
              style: TextStyle(
                fontSize: _fontSize,
                color: isHighlighted 
                    ? AppColors.textPrimary.withOpacity(0.7) 
                    : AppColors.textSecondary,
                height: 1.6,
                fontStyle: FontStyle.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  
  // Build a single sentence widget with highlighting support
  Widget _buildSentenceWidget(ArticleSentence sentence, int index) {
    final isHighlighted = _currentHighlightedSentenceIndex == index;
    final displayText = sentence.originalText;
    final translation = _showTranslation ? sentence.translationText : null;
    
    return AnimatedContainer(
      key: _sentenceKeys[index],
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: isHighlighted ? 12 : 4,
        vertical: isHighlighted ? 10 : 4,
      ),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? AppColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted 
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 2)
            : null,
        boxShadow: isHighlighted 
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original sentence
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: _fontSize,
              color: isHighlighted 
                  ? AppColors.primary 
                  : AppColors.textPrimary,
              height: 1.6,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
            child: Text(displayText),
          ),
          // Translation if enabled and available
          if (translation != null && !_showTranslationAfterParagraph) ...[
            const SizedBox(height: 8),
            Text(
              translation,
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
    if (_quizController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      );
    }

    if (_quizController.isCompleted) {
      return _buildQuizCompletedView();
    }

    if (!_quizController.hasQuestions) {
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
      questions: _quizController.questions,
      onQuizComplete: _quizController.onQuizComplete,
    );
  }

  Widget _buildQuizCompletedView() {
    final totalQuestions = _quizController.totalQuestions;
    final percentage = _quizController.percentageScore;

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
              '${_quizController.correctAnswersCount} / $totalQuestions',
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
              onTap: _quizController.resetQuiz,
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
            if (_quizController.hasQuestions && _quizController.userAnswers.isNotEmpty) ...[
            Text(
              'Answers',
              style: TextStyle(
                fontSize: 28,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            ..._quizController.questions.asMap().entries.map((entry) {
              final questionIndex = entry.key;
              final question = entry.value;
              final userAnswerIndex = _quizController.userAnswers[questionIndex];
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
