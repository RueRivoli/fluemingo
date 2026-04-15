import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/unit.dart';
import '../constants/app_colors.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/quiz_content_widget.dart';
import '../widgets/playback_speed_dialog.dart';
import '../widgets/article_reading_top_bar.dart';
import '../widgets/article_reading_tab_bar.dart';
import '../widgets/article_paragraphs_view.dart';
import '../widgets/audio_playback_controls.dart';
import '../widgets/quiz_completed_view.dart';
import '../services/feedback_service.dart';
import '../widgets/font_size_bottom_sheet.dart';
import '../services/quiz_service.dart';
import '../services/flashcard_service.dart';
import '../services/language_table_resolver.dart';
import '../controllers/quiz_controller.dart';
import '../utils/flashcards.dart';
import '../utils/flashcard_snackbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/deepl_service.dart';
import '../stores/profile_store.dart';
import '../services/anthropic_generation_service.dart';
import '../services/audio_service.dart';
import '../services/edge_function_auth_exception.dart';
import '../services/rate_limit_exception.dart';
import '../widgets/xp_reward_bottom_sheet.dart';
import '../services/week_progress_service.dart';
import '../services/article_service.dart';
import 'onboarding/registration_page.dart';

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
  int? _currentHighlightedSentenceIndex;
  final ScrollController _scrollController = ScrollController();

  // Keys for each sentence to enable auto-scrolling
  final Map<int, GlobalKey> _sentenceKeys = {};

  double _fontSize = 16.0;
  bool _showTranslation = true;
  bool _showUnitChips = true;
  bool _showTranslationAfterParagraph = false;

  // Quiz state
  late QuizController _quizController;
  bool _quizWasCompleted = false;

  late List<String> _listOfVocabularyItems;
  late FlashcardService _flashcardService;
  late DeeplService _deeplService;
  late AnthropicGenerationService _anthropicGenerationService;
  late AudioService _audioService;
  bool _isHandlingReauthRequired = false;
  /// Flashcard IDs whose audio generation is currently in flight.
  final Set<int> _pendingAudioFlashcardIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _listOfVocabularyItems = widget.article.listOfVocabularyItems;
    _flashcardService = FlashcardService(Supabase.instance.client);
    _deeplService = const DeeplService();
    _anthropicGenerationService = AnthropicGenerationService();
    _audioService = AudioService(Supabase.instance.client);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _quizController = QuizController(
      quizService: QuizService(Supabase.instance.client),
      articleId: widget.article.id,
      chapterId: widget.article.chapterId ?? '',
      contentType: widget.article.contentType,
    );
    _quizController.addListener(() {
      setState(() {});
      if (_quizController.isCompleted && !_quizWasCompleted && mounted) {
        _quizWasCompleted = true;
        // Only show XP when the user actually answered in this session.
        // userAnswers is empty when isCompleted comes from initializeQuiz
        // (quiz was already done before), and populated only via onQuizComplete.
        if (_quizController.userAnswers.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleQuizCompleted();
          });
        }
      }
      if (!_quizController.isCompleted) {
        _quizWasCompleted = false;
      }
    });

    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing != _isPlaying) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentHighlightedSentenceIndex = null;
        });
      }
    });
    _audioPlayer.positionStream.listen((position) {
      _updateHighlightedSentence(position);
    });

    _initializeSentenceKeys();
    _loadAudio();
    _quizController.initializeQuiz(false);
  }

  Future<void> _loadAudio() async {
    if (widget.article.audioUrl != null &&
        widget.article.audioUrl!.isNotEmpty) {
      try {
        final rawAudioPath = widget.article.audioUrl!;
        final normalizedAudioPath = rawAudioPath.startsWith('file://')
            ? rawAudioPath.replaceFirst('file://', '')
            : rawAudioPath;
        if (normalizedAudioPath.startsWith('/')) {
          await _audioPlayer.setFilePath(normalizedAudioPath);
        } else {
          await _audioPlayer.setUrl(rawAudioPath);
        }
        await _updatePlaybackSpeed();
        if (_repeatMode) {
          await _audioPlayer.setLoopMode(LoopMode.one);
        }
      } catch (e) {
        debugPrint('Error loading audio: $e');
      }
    }
  }

  void _initializeSentenceKeys() {
    final paragraphs = widget.article.paragraphs;
    if (paragraphs.isEmpty) return;

    int globalIndex = 0;
    for (final paragraph in paragraphs) {
      for (final _ in paragraph.sentences) {
        _sentenceKeys[globalIndex] = GlobalKey();
        globalIndex++;
      }
    }
  }

  void _updateHighlightedSentence(Duration position) {
    final paragraphs = widget.article.paragraphs;
    if (paragraphs.isEmpty) return;

    final positionSeconds = position.inMilliseconds / 1000.0;
    int? newHighlightedIndex;
    int globalIndex = 0;

    for (final paragraph in paragraphs) {
      for (final sentence in paragraph.sentences) {
        if (sentence.startTime != null && sentence.endTime != null) {
          if (positionSeconds >= sentence.startTime! &&
              positionSeconds <= sentence.endTime!) {
            newHighlightedIndex = globalIndex;
            break;
          }
        }
        globalIndex++;
      }
      if (newHighlightedIndex != null) break;
    }

    if (newHighlightedIndex != _currentHighlightedSentenceIndex) {
      setState(() {
        _currentHighlightedSentenceIndex = newHighlightedIndex;
      });
      if (newHighlightedIndex != null) {
        _scrollToSentence(newHighlightedIndex);
      }
    }
  }

  void _scrollToSentence(int sentenceIndex) {
    final key = _sentenceKeys[sentenceIndex];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.4,
      );
    }
  }

  Future<void> _updatePlaybackSpeed() async {
    try {
      await _audioPlayer.setSpeed(_playbackSpeed);
    } catch (e) {
      debugPrint('Error updating playback speed: $e');
    }
  }

  Future<void> _seekBy(Duration offset) async {
    if (widget.article.audioUrl == null || widget.article.audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.noAudioAvailableForThisArticle),
        ),
      );
      return;
    }

    try {
      final processingState = _audioPlayer.processingState;
      if (processingState == ProcessingState.idle ||
          processingState == ProcessingState.loading) {
        await _loadAudio();
      }

      final currentPosition = _audioPlayer.position;
      final duration = _audioPlayer.duration;
      var targetPosition = currentPosition + offset;

      if (targetPosition < Duration.zero) {
        targetPosition = Duration.zero;
      }
      if (duration != null && targetPosition > duration) {
        targetPosition = duration;
      }

      await _audioPlayer.seek(targetPosition);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorSeekingAudio)),
      );
    }
  }

  Future<void> _togglePlayback() async {
    if (widget.article.audioUrl == null || widget.article.audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.noAudioAvailableForThisArticle)),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final processingState = _audioPlayer.processingState;
        if (processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        if (processingState == ProcessingState.idle ||
            processingState == ProcessingState.loading) {
          await _loadAudio();
        }
        await _updatePlaybackSpeed();
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorPlayingAudio)),
      );
    }
  }

  Future<void> _toggleRepeatMode() async {
    setState(() {
      _repeatMode = !_repeatMode;
    });
    try {
      await _audioPlayer.setLoopMode(_repeatMode ? LoopMode.one : LoopMode.off);
    } catch (e) {
      debugPrint('Error setting repeat mode: $e');
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

  Future<void> _handleQuizCompleted() async {
    final article = widget.article;
    final isChapter = article.contentType == 2 && article.chapterId != null;
    final l10n = AppLocalizations.of(context)!;

    // Ask if user wants to mark article/chapter as finished
    final markAsFinished = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quizCompleted),
        content: Text(isChapter
            ? l10n.quizFinishedMarkChapterAsFinished
            : l10n.quizFinishedMarkArticleAsFinished),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (markAsFinished == true) {
      if (isChapter) {
        // Mark chapter as finished (also auto-syncs audiobook status)
        final articleService = ArticleService(Supabase.instance.client);
        await articleService.editChapterStatus(
          audiobookId: article.id,
          chapterId: article.chapterId!,
          status: 'finished',
        );
      } else {
        final articleService = ArticleService(Supabase.instance.client);
        await articleService.editArticleStatus(article, 'finished');
      }
      if (!mounted) return;
      final xp =
          XP_PER_QUIZ + (isChapter ? XP_PER_AUDIOBOOK_CHAPTER : XP_PER_ARTICLE);
      final message =
          isChapter ? l10n.congratsQuizAndChapter : l10n.congratsQuizAndArticle;
      FeedbackService.instance.playSuccess();
      XpRewardBottomSheet.show(context, xp: xp, message: message);
    } else {
      if (!mounted) return;
      FeedbackService.instance.playSuccess();
      XpRewardBottomSheet.show(context,
          xp: XP_PER_QUIZ, message: l10n.congratsQuiz);
    }
  }

  Color _getBackgroundColor() {
    switch (_selectedTabIndex) {
      case 0:
        return AppColors.background;
      case 1:
        return AppColors.secondary.withOpacity(0.96);
      case 2:
        return AppColors.primary.withOpacity(0.96);
      default:
        return AppColors.background;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        bottom: _selectedTabIndex != 0,
        child: Column(
          children: [
            ArticleReadingTopBar(
              title: widget.article.title,
              contentType: widget.article.contentType,
              orderId: widget.article.orderId,
              onBack: () => Navigator.pop(context, widget.article),
            ),
            ArticleReadingTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                _tabController.animateTo(index);
                setState(() => _selectedTabIndex = index);
              },
            ),
            if (_selectedTabIndex == 0) _buildActionButtons(),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  ArticleParagraphsView(
                    paragraphs: widget.article.paragraphs,
                    scrollController: _scrollController,
                    sentenceKeys: _sentenceKeys,
                    currentHighlightedSentenceIndex:
                        _currentHighlightedSentenceIndex,
                    fontSize: _fontSize,
                    showTranslation: _showTranslation,
                    showUnitsAsChips: _showUnitChips,
                    showTranslationAfterParagraph:
                        _showTranslationAfterParagraph,
                    onUnitTap: _showVocabularyBottomSheet,
                  ),
                  _buildVocabularyContent(),
                  _buildQuizContent(),
                ],
              ),
            ),
            if (_selectedTabIndex == 0)
              AudioPlaybackControls(
                audioPlayer: _audioPlayer,
                isPlaying: _isPlaying,
                repeatMode: _repeatMode,
                playbackSpeed: _playbackSpeed,
                onPlayPause: _togglePlayback,
                onRewind: () => _seekBy(const Duration(seconds: -10)),
                onForward: () => _seekBy(const Duration(seconds: 10)),
                onRepeatToggle: _toggleRepeatMode,
                onSpeedTap: _showSpeedDialog,
              ),
          ],
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
            children: [
              _buildActionButton(FontAwesomeIcons.language, _showTranslation,
                  () {
                setState(() {
                  _showTranslation = !_showTranslation;
                });
              }),
              const SizedBox(width: 12),
              _buildActionButton(
                FontAwesomeIcons.puzzlePiece,
                _showUnitChips,
                () {
                  setState(() {
                    _showUnitChips = !_showUnitChips;
                  });
                },
                selectedBackgroundColor: AppColors.secondary,
                selectedIconColor: AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              _buildActionButton(FontAwesomeIcons.textSize, false, () {
                FontSizeBottomSheet.show(
                  context,
                  initialFontSize: _fontSize,
                  onFontSizeChanged: (value) {
                    setState(() => _fontSize = value);
                  },
                );
              }),
              if (_showTranslation) ...[
                const SizedBox(width: 12),
                _buildActionButton(
                    _showTranslationAfterParagraph
                        ? FontAwesomeIcons.alignJustify
                        : FontAwesomeIcons.blockQuote,
                    false, () {
                  setState(() {
                    _showTranslationAfterParagraph =
                        !_showTranslationAfterParagraph;
                  });
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    bool isSelected,
    VoidCallback onTap, {
    Color selectedBackgroundColor = AppColors.primary,
    Color selectedIconColor = AppColors.white,
    Color unselectedBackgroundColor = AppColors.white,
    Color unselectedIconColor = AppColors.textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isSelected ? selectedIconColor : unselectedIconColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildVocabularyContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...widget.article.orderedListOfVocabularyItems.map((item) {
          return VocabularyItemCard(
            item: item,
            isAudioPending: item.flashcardId != null &&
                _pendingAudioFlashcardIds.contains(item.flashcardId),
            onIconToggle: () async {
              await _updateMainVocabularyItemInFlashcards(item);
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuizContent() {
    if (_quizController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_quizController.isCompleted) {
      return QuizCompletedView(quizController: _quizController);
    }

    if (!_quizController.hasQuestions) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            AppLocalizations.of(context)!.noQuizAvailableForThisArticle,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    return QuizContentWidget(
      questions: _quizController.questions,
      onQuizComplete: _quizController.onQuizComplete,
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

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

  // ─── Vocabulary bottom sheet ───────────────────────────────────────────────

  void _showVocabularyBottomSheet(Unit unit) async {
    final isItemAlreadyInMainVocabulary = widget.article.mainVocabularyItems
        .any((item) =>
            item.word == unit.text &&
            item.type == unit.type &&
            item.isAddedByUser != true);
    final isAlreadyInList =
        _listOfVocabularyItems.contains(unit.text + ' (' + unit.type + ')');
    final contextSentence = _findContextSentenceForWord(unit.text);
    final targetLanguage = ProfileStoreScope.of(context).targetLanguage;
    final sourceLanguage = ProfileStoreScope.of(context).nativeLanguage;
    if (!mounted) return;

    String currentTranslation = unit.translatedText;
    bool isRetranslating = false;
    bool localIsAdded = isAlreadyInList;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final vocabularyItem = VocabularyItem(
            word: unit.text,
            translation: currentTranslation,
            type: unit.type,
            properName: unit.properName ?? false,
            audioUrl: '',
            basis: unit.originVerb ?? unit.basis,
            isAddedByUser: localIsAdded && !isItemAlreadyInMainVocabulary,
            status: null,
          );

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  AppLocalizations.of(context)!.definition,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (!(unit.properName ?? false))
                  Text(
                    isItemAlreadyInMainVocabulary
                        ? AppLocalizations.of(context)!.mainVocabulary
                        : localIsAdded
                            ? AppLocalizations.of(context)!
                                .clickOnXToRemoveThisExpressionFromYourVocabularyList
                            : AppLocalizations.of(context)!
                                .clickOnPlusToAddThisExpressionToYourVocabularyList,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 8),
                if (!isItemAlreadyInMainVocabulary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: localIsAdded
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context)!
                                      .vocabularyAddedToList,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : (unit.properName ?? false)
                            ? const SizedBox.shrink()
                            : GestureDetector(
                                onTap: isRetranslating
                                    ? null
                                    : () async {
                                        setSheetState(() {
                                          isRetranslating = true;
                                          currentTranslation = '...';
                                        });
                                        String? result;
                                        try {
                                          result = await _deeplService
                                              .translateWithDeepL(
                                            text: unit.text,
                                            sourceLanguage: targetLanguage,
                                            targetLanguage: sourceLanguage,
                                            context: contextSentence.isNotEmpty
                                                ? contextSentence
                                                : null,
                                          );
                                        } on RateLimitExceededException {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(AppLocalizations.of(context)!.dailyLimitReached)),
                                          );
                                          return;
                                        } on EdgeFunctionReauthRequiredException {
                                          if (!mounted) return;
                                          setSheetState(() {
                                            isRetranslating = false;
                                          });
                                          await _handleEdgeFunctionReauthRequired();
                                          return;
                                        }
                                        if (!mounted) return;
                                        setSheetState(() {
                                          isRetranslating = false;
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            currentTranslation = result;
                                          }
                                        });
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isRetranslating)
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: AppColors.textPrimary,
                                          ),
                                        )
                                      else
                                        const FaIcon(
                                          FontAwesomeIcons.arrowsRotate,
                                          size: 18,
                                          color: AppColors.textPrimary,
                                        ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .retranslate,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                if (!isItemAlreadyInMainVocabulary) const SizedBox(height: 4),
                VocabularyItemCard(
                  item: vocabularyItem,
                  displayType: 'text',
                  hideAddAction: isItemAlreadyInMainVocabulary ? true : false,
                  onIconToggle: () async {
                    if (localIsAdded) {
                      final savedItem = widget.article.vocabulary
                          .where(
                              (v) => v.word == unit.text && v.type == unit.type)
                          .firstOrNull;
                      if (savedItem != null) {
                        await _deleteVocabularyItem(savedItem);
                      }
                      setSheetState(() => localIsAdded = false);
                    } else {
                      setSheetState(() => localIsAdded = true);
                      final added = await _createFlashcardFromTextExpression(
                          vocabularyItem);
                      if (!added) {
                        setSheetState(() => localIsAdded = false);
                        if (!context.mounted) return;
                        if (!mounted) return;
                        if (_isHandlingReauthRequired) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Impossible d’ajouter ce mot pour le moment.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Flashcard operations ─────────────────────────────────────────────────

  void _showFlashcardAddedSnackBar() {
    FlashcardSnackbar.show(context, 'added');
  }

  Future<void> _handleEdgeFunctionReauthRequired() async {
    if (!mounted || _isHandlingReauthRequired) return;
    _isHandlingReauthRequired = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Votre session a expiré. Merci de vous reconnecter pour continuer.'),
        backgroundColor: Colors.red,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const RegistrationPage.loginOnly(),
      ),
      (route) => false,
    );
  }

  String _findContextSentenceForWord(String word) {
    final normalizedWord = word.trim().toLowerCase();
    for (final paragraph in widget.article.paragraphs) {
      for (final sentence in paragraph.sentences) {
        final hasUnitMatch = sentence.units
            .any((unit) => unit.text.trim().toLowerCase() == normalizedWord);
        if (hasUnitMatch) return sentence.originalText.trim();
      }
    }
    for (final paragraph in widget.article.paragraphs) {
      for (final sentence in paragraph.sentences) {
        if (sentence.originalText.toLowerCase().contains(normalizedWord)) {
          return sentence.originalText.trim();
        }
      }
    }
    return '';
  }

  Future<bool> _createFlashcardFromTextExpression(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return false;
      final contentId = int.tryParse(widget.article.id);
      if (contentId == null) {
        debugPrint('Invalid content id: ${widget.article.id}');
        return false;
      }
      final chapterId = widget.article.chapterId != null
          ? int.tryParse(widget.article.chapterId!)
          : null;
      final targetLanguage = ProfileStoreScope.of(context).targetLanguage;
      final sourceLanguage = ProfileStoreScope.of(context).nativeLanguage;

      final contextSentence = _findContextSentenceForWord(item.word);
      final initialVocabularyItem = VocabularyItem(
        word: item.word,
        translation: item.translation,
        type: item.type,
        exampleSentence:
            contextSentence.isNotEmpty ? contextSentence : item.word,
        exampleTranslation: item.exampleTranslation,
        audioUrl: item.audioUrl,
        basis: item.basis,
        isAddedByUser: true,
      );
      final newFlashcardFromTextExpression = await _flashcardService
          .addFlashcard(initialVocabularyItem, contentId, chapterId);
      if (newFlashcardFromTextExpression == null) return false;

      final newVocabularyItem =
          flashcardRowToVocabularyItem(newFlashcardFromTextExpression);
      if (!mounted) return true;
      final pendingId = newVocabularyItem.flashcardId;
      setState(() {
        final existingIndex = widget.article.vocabulary.indexWhere(
          (v) =>
              (v.flashcardId != null &&
                  v.flashcardId == newVocabularyItem.flashcardId) ||
              (v.flashcardId == null &&
                  v.word == newVocabularyItem.word &&
                  v.type == newVocabularyItem.type &&
                  v.isAddedByUser == true),
        );
        if (existingIndex >= 0) {
          widget.article.vocabulary[existingIndex] = newVocabularyItem;
        } else {
          widget.article.vocabulary.add(newVocabularyItem);
        }
        _listOfVocabularyItems = widget.article.listOfVocabularyItems;
        if (pendingId != null) _pendingAudioFlashcardIds.add(pendingId);
      });
      try {
      final translatedWord = await _deeplService.translateWithDeepL(
        text: item.word,
        sourceLanguage: targetLanguage,
        targetLanguage: sourceLanguage,
        context: contextSentence,
      );
      final generatedResult = await _anthropicGenerationService
          .generateExampleSentenceWithAnthropic(
        word: item.word,
        translatedWord: (translatedWord != null && translatedWord.isNotEmpty)
            ? translatedWord
            : item.translation,
        targetLanguageCode: targetLanguage,
        sourceLanguageCode: sourceLanguage,
      );
      final exampleSentence = generatedResult?['sentence'] ??
          (contextSentence.isNotEmpty ? contextSentence : item.word);
      final exampleTranslation = generatedResult?['translation'];

      final lang = LanguageTableResolver.language;
      final contentTitle = widget.article.contentType == 2
          ? (widget.article.parentTitle ?? widget.article.title)
          : widget.article.title;
      final audioUrl = await _audioService.generateAndUploadWordAudio(
        word: item.word,
        language: lang,
        userId: user.id,
        contentType: widget.article.contentType,
        contentTitle: contentTitle,
        chapterOrder: widget.article.contentType == 2
            ? (widget.article.orderId ?? 0)
            : null,
      );

      final enrichedUpdate = <String, dynamic>{
        'text_translation':
            (translatedWord != null && translatedWord.isNotEmpty)
                ? translatedWord
                : item.translation,
        'example': exampleSentence,
        'example_translation': exampleTranslation ?? item.exampleTranslation,
        'audio_url': audioUrl ?? item.audioUrl,
      };
      if (newVocabularyItem.flashcardId != null) {
        await supabase
            .from(LanguageTableResolver.table('flashcards'))
            .update(enrichedUpdate)
            .eq('id', newVocabularyItem.flashcardId!)
            .eq('user_id', user.id);
        if (!mounted) return true;
        final enrichedVocabularyItem = flashcardRowToVocabularyItem({
          ...newFlashcardFromTextExpression,
          ...enrichedUpdate,
        });
        setState(() {
          final index = widget.article.vocabulary.indexWhere(
            (v) => v.flashcardId == newVocabularyItem.flashcardId,
          );
          if (index >= 0) {
            widget.article.vocabulary[index] = enrichedVocabularyItem;
          }
        });
      }
      return true;
      } finally {
        if (pendingId != null && mounted) {
          setState(() => _pendingAudioFlashcardIds.remove(pendingId));
        }
      }
    } on RateLimitExceededException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.dailyLimitReached)),
        );
      }
      return false;
    } on EdgeFunctionReauthRequiredException {
      await _handleEdgeFunctionReauthRequired();
      return false;
    } catch (e) {
      debugPrint('Error updating flashcard ${item.flashcardId}: $e');
      return false;
    }
  }

  Future<void> _updateMainVocabularyItemInFlashcards(
      VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final flashcardId = item.flashcardId;
      final flashcardsTable = LanguageTableResolver.table('flashcards');

      if (flashcardId != null) {
        // Distinguish between:
        // - text-added row not yet "saved" (status is null): first click should save
        // - already saved row: click should remove from flashcards
        final existing = await supabase
            .from(flashcardsTable)
            .select('id, status')
            .eq('id', flashcardId)
            .eq('user_id', user.id)
            .maybeSingle();

        if (existing != null) {
          final currentStatus = existing['status'] as String?;
          if (currentStatus == null || currentStatus.isEmpty) {
            await _flashcardService.updateFlashcardStatus(flashcardId, 'saved');
            setState(() {
              item.status = 'saved';
            });
            _showFlashcardAddedSnackBar();
          } else {
            await _flashcardService.deleteFlashcard(flashcardId);
            setState(() {
              item.flashcardId = null;
              item.status = null;
            });
          }
          return;
        }

        // Stale local id: fallback to create flow below.
        item.flashcardId = null;
      } else {
        if (item.status == null || item.status!.isEmpty) {
          item.status = 'saved';
        }
        final createdFlashcard = await _flashcardService.addFlashcard(
            item,
            int.parse(widget.article.id),
            widget.article.chapterId != null
                ? int.parse(widget.article.chapterId!)
                : null);
        if (createdFlashcard != null) {
          setState(() {
            item.flashcardId = createdFlashcard['id'] as int?;
            item.status = 'saved';
          });
          _showFlashcardAddedSnackBar();
        }
      }
    } catch (e) {
      debugPrint('Error updating flashcard ${item.flashcardId}: $e');
    }
  }

  Future<void> _deleteVocabularyItem(VocabularyItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final flashcardId = item.flashcardId;
      if (flashcardId == null) return;
      await _flashcardService.deleteFlashcard(flashcardId);
      if (!mounted) return;
      setState(() {
        widget.article.vocabulary
            .removeWhere((element) => element.flashcardId == flashcardId);
        _listOfVocabularyItems = widget.article.listOfVocabularyItems;
      });
    } catch (e) {
      debugPrint('Error deleting flashcard ${item.flashcardId}: $e');
    }
  }
}
