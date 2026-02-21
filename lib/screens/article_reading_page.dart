import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/article_paragraph.dart';
import '../models/sentence_timestamp.dart';
import '../models/article_paragraph.dart';
import '../models/article_sentence.dart';
import '../models/unit.dart';
import '../constants/app_colors.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/quiz_content_widget.dart';
import '../widgets/playback_speed_dialog.dart';
import '../services/quiz_service.dart';
import '../services/flashcard_service.dart';
import '../controllers/quiz_controller.dart';
import '../utils/flashcards.dart';
import '../utils/vocabulary_items.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';

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

  late List<String> _listOfVocabularyItems;
  late FlashcardService _flashcardService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _listOfVocabularyItems = widget.article.listOfVocabularyItems;
    _flashcardService = FlashcardService(Supabase.instance.client);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Initialize quiz controller
    _quizController = QuizController(
      quizService: QuizService(Supabase.instance.client),
      articleId: widget.article.id,
      chapterId: widget.article.chapterId ?? '',
      contentType: widget.article.contentType,
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
            onTap: () => Navigator.pop(context, widget.article),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.chevronLeft,
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
              AppLocalizations.of(context)!.article,
              0,
              AppColors.secondary,
              Colors.black,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              AppLocalizations.of(context)!.vocabulary,
              1,
              AppColors.primary,
              Colors.white,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              AppLocalizations.of(context)!.quiz,
              2,
              Colors.white,
            Colors.black,
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
    
    // Build TextSpans for each sentence with units
    final textSpans = <InlineSpan>[];
    for (int i = 0; i < paragraph.sentences.length; i++) {
      final sentence = paragraph.sentences[i];
      final globalIndex = startingGlobalIndex + i;
      final isHighlighted = _currentHighlightedSentenceIndex == globalIndex;
      
      // Build spans for each unit in this sentence
      for (int j = 0; j < sentence.units.length; j++) {
        final unit = sentence.units[j];
        final isLastUnitInSentence = j == sentence.units.length - 1;
        final isLastSentence = i == paragraph.sentences.length - 1;
        
        final hasPunctuation = unit.punctuation == true;
        textSpans.add(
          WidgetSpan(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hasPunctuation 
                  ? null 
                  : () {
                      _showVocabularyBottomSheet(unit);
                    },
              child: Container(
                margin: EdgeInsets.only(
                  right: (isLastUnitInSentence && !isLastSentence) ? 0 : 4,
                  bottom: 2,
                ),
                padding: hasPunctuation 
                    ? EdgeInsets.zero 
                    : EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: hasPunctuation 
                    ? null 
                    : BoxDecoration(
                        color: isHighlighted 
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.neutral.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(4),
                      ),
                child: Text(
                  unit.text + (isLastUnitInSentence && !isLastSentence ? ' ' : ''),
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.normal,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ),
        );
      }
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
    final translation = _showTranslation ? sentence.translationText : null;
    
    // Build TextSpans for each unit
    final unitSpans = <InlineSpan>[];
    for (int i = 0; i < sentence.units.length; i++) {
      final unit = sentence.units[i];
      final isLastUnit = i == sentence.units.length - 1;
      
      final hasPunctuation = unit.punctuation == true;
      unitSpans.add(
        WidgetSpan(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hasPunctuation 
                ? null 
                : () {
                    _showVocabularyBottomSheet(unit);
                  },
            child: Container(
              margin: EdgeInsets.only(
                right: isLastUnit ? 0 : 4,
                bottom: 2,
              ),
              padding: hasPunctuation 
                  ? EdgeInsets.zero 
                  : EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: hasPunctuation 
                  ? null 
                  : BoxDecoration(
                      color: isHighlighted 
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.neutral.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(4),
                    ),
              child: Text(
                unit.text + (isLastUnit ? '' : ' '),
                style: TextStyle(
                  fontSize: _fontSize,
                  color: AppColors.textPrimary,
                  height: 1.8,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Container(
      key: _sentenceKeys[globalIndex],
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original sentence with units
          RichText(
            text: TextSpan(children: unitSpans),
          ),
          // Translation if enabled and available
          if (translation != null && !_showTranslationAfterParagraph) ...[
            const SizedBox(height: 4),
            Text(
              translation,
              style: TextStyle(
                fontSize: _fontSize,
                color: AppColors.textSecondary,
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
  
    // Save or unsave vocabulary item to flashcards_fr table in Supabase
  Future<void> _createFlashcardFromTextExpression(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) return;
      final textExpressionToAdd = VocabularyItem(
          word: item.word,
          translation: item.translation,
          type: item.type,
          exampleSentence: item.exampleSentence,
          exampleTranslation: item.exampleTranslation,
          audioUrl: item.audioUrl,
          isAddedByUser: true,
        );
          final newFlashcardFromTextExpression = await _flashcardService.addFlashcard(textExpressionToAdd, int.parse(widget.article.id), widget.article.chapterId != null ? int.parse(widget.article.chapterId!) : null);        setState(() {
            if (newFlashcardFromTextExpression != null) {
              final newVocabularyItem = flashcardRowToVocabularyItem(newFlashcardFromTextExpression);
              widget.article.vocabulary.add(newVocabularyItem);
            }
          });
        return;
    } catch (e) {
      print('Error updating flashcard ${item.flashcardId}: $e');
    }
  }

 // Save or unsave vocabulary item to flashcards_fr table in Supabase
  Future<void> _updateMainVocabularyItemInFlashcards(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) return;
      
      final flashcardId = item.flashcardId;
      
      if (flashcardId != null) {
          final deletedFlashcard = await _flashcardService.deleteFlashcard(flashcardId);
          setState(() {
            item.flashcardId = null;
            item.status = null;
          });
      } else {
          final createdFlashcard = await _flashcardService.addFlashcard(item, int.parse(widget.article.id), widget.article.chapterId != null ? int.parse(widget.article.chapterId!) : null);
          setState(() {
            // createdFlashcard?['id'] is already an int from Supabase, not a String
            item.flashcardId = createdFlashcard?['id'] as int? ?? 0;
            item.status = 'saved';
          });
      }
    } catch (e) {
      print('Error updating flashcard ${item.flashcardId}: $e');
    }
  }

  // Save or unsave vocabulary item to flashcards_fr table in Supabase
  Future<void> _updateAddedByUserVocabularyItemInFlashcards(VocabularyItem item) async {
    printVocabularyItem(item);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('❌ User not authenticated, cannot save vocabulary item');
        return;
      }
      
      final flashcardId = item.flashcardId;
      
      if (flashcardId == null) {
        print('❌ Flashcard ID is null, cannot update');
        return;
      }
      
      if (item.status != null) {
          final vocabularyResponse = await supabase
              .from('flashcards_fr')
              .update({
                'status': null,
              })
              .eq('id', flashcardId);
          setState(() {
            final vocabItem = widget.article.vocabulary.firstWhere((element) => element.flashcardId == flashcardId);
            vocabItem.status = null;
          });
      } else {
          final vocabularyResponse = await supabase
              .from('flashcards_fr')
              .update({
                'status': 'saved',
              })
              .eq('id', flashcardId);
          setState(() {
            final vocabItem = widget.article.vocabulary.firstWhere((element) => element.flashcardId == flashcardId);
            vocabItem.status = 'saved';
          });
          print('✅ Flashcard $flashcardId updated: status=saved');
      }
    } catch (e) {
      print('Error updating flashcard ${item.flashcardId}: $e');
    }
  }

  // Delete vocabulary item from flashcards_fr table in Supabase
  Future<void> _deleteVocabularyItem(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        return;
      }
      final flashcardId = item.flashcardId;
      if (flashcardId == null) {
        print('❌ Flashcard ID is null, cannot delete');
        return;
      }
      await _flashcardService.deleteFlashcard(flashcardId);      
      setState(() {
        widget.article.vocabulary.removeWhere((element) => element.flashcardId == flashcardId);
      });
      
    } catch (e) {
      print('❌ Error deleting flashcard ${item.flashcardId}: $e');
    }
  }


  // Show bottom sheet with unit information
  void _showVocabularyBottomSheet(Unit unit) async {
    // Check if there is an item in mainVocabularyItems that has unit.text and unit.type as values
    final isItemAlreadyInMainVocabulary = widget.article.mainVocabularyItems.any((item) => item.word == unit.text && item.type == unit.type);
    final isAlreadyInList = _listOfVocabularyItems.contains(unit.text + ' (' + unit.type + ')');
    // Create a VocabularyItem from the Unit's properties
    final vocabularyItem = VocabularyItem(
      word: unit.text,
      translation: unit.translatedText,
      type: unit.type,
      audioUrl: '', // Units don't have audio URLs
      isAddedByUser: isItemAlreadyInMainVocabulary ? false : isAlreadyInList ? true : false,
      status: null,
    );
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Text(
              AppLocalizations.of(context)!.definition,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
            isItemAlreadyInMainVocabulary ? AppLocalizations.of(context)!.mainVocabulary : isAlreadyInList ? AppLocalizations.of(context)!.clickOnXToRemoveThisExpressionFromYourVocabularyList : AppLocalizations.of(context)!.clickOnPlusToAddThisExpressionToYourVocabularyList,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Vocabulary item card
            VocabularyItemCard(
              item: vocabularyItem,
              displayType: 'text',
              hideAddAction: isItemAlreadyInMainVocabulary ? true : false,
              onIconToggle: () async {
                // isSaved is already toggled by the card
                isAlreadyInList ? await _deleteVocabularyItem(vocabularyItem) : await _createFlashcardFromTextExpression(vocabularyItem);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVocabularyContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
        Icon(
          Icons.bookmark,
          color: AppColors.primary,
          size: 26,
        ),
        Icon(
          Icons.arrow_right_alt,
          color: AppColors.primary,
          size: 26,
        ),
         Text(
            AppLocalizations.of(context)!.expressionAddedToFlashcards,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),  
          ],
        ),
        const SizedBox(height: 18),
        // Section "Personnal" pour les flashcards ajoutées par l'utilisateur
        if (widget.article.hasAddedByUserVocabularyItems) ...[
          const SizedBox(height: 12),
          ...widget.article.addedByUserVocabularyItems.map((item) {
            final vocabularyItem = VocabularyItem(
              id: item.id,
              word: item.word,
              translation: item.translation,
              type: item.type,
              exampleSentence: item.exampleSentence,
              exampleTranslation: item.exampleTranslation,
              audioUrl: item.audioUrl,
              flashcardId: item.flashcardId,
              status: item.status,
              isAddedByUser: item.isAddedByUser,
            );
            
            return Dismissible(
              key: Key('personal_vocab_${item.flashcardId ?? item.word}_${item.type}'),
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
                    title: Text(AppLocalizations.of(context)!.deleteVocabularyItem),
                    content: Text(AppLocalizations.of(context)!.areYouSureYouWantToDeleteWord(item.word)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                ) ?? false;
              },
              onDismissed: (direction) async {
                await _deleteVocabularyItem(vocabularyItem);
              },
              child: VocabularyItemCard(
                item: vocabularyItem,
                onIconToggle: () async {
                  await _updateAddedByUserVocabularyItemInFlashcards(item);
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.deleteVocabularyItem),
                      content: Text(AppLocalizations.of(context)!.areYouSureYouWantToDeleteWord(item.word)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text(AppLocalizations.of(context)!.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await _deleteVocabularyItem(vocabularyItem);
                  }
                },
              ),
            );
          }),
        ],
        // Section "Main" pour le vocabulaire standard
        if (widget.article.hasAddedByUserVocabularyItems) ...[
          const SizedBox(height: 6)
          ],
          ...[...widget.article.mainVocabularyItems.map((item) {
            return VocabularyItemCard(
              item: item,
                onIconToggle: () async {
                  await _updateMainVocabularyItemInFlashcards(item);
                },
              );
            }),
          ],
      ],
    );
  }

  Widget _buildQuizContent() {
    if (_quizController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_quizController.isCompleted) {
      return _buildQuizCompletedView();
    }

    if (!_quizController.hasQuestions) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            AppLocalizations.of(context)!.noQuizAvailableForThisArticle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
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
            // Congratulations text
            Text(
              AppLocalizations.of(context)!.quizCompleted,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                color: Colors.white.withOpacity(0.8),
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
                child: Text(
                  AppLocalizations.of(context)!.tryAgain,
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
              AppLocalizations.of(context)!.answers,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white.withOpacity(0.8),
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
                              color: Colors.white,
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
                                  color: Colors.white,
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
                                  color: Colors.white,
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
        color: Colors.white,
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
                    SnackBar(content: Text(AppLocalizations.of(context)!.noAudioAvailableForThisArticle)),
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
    PlaybackSpeedDialog.show(
      context,
      currentSpeed: _playbackSpeed,
      onSpeedChanged: (newSpeed) async {
        setState(() {
          _playbackSpeed = newSpeed;
        });
        await _updatePlaybackSpeed();
      },
    );
  }

  void _showFontSizeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              Text(
                AppLocalizations.of(context)!.fontSize,
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
