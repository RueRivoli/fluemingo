import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';
import '../constants/word_types.dart';
import '../l10n/app_localizations.dart';

class VocabularyItemCard extends StatefulWidget {
  final VocabularyItem item;
  final Future<void> Function() onIconToggle;
  final String displayType; // 'standard', 'flashcard','text'
  final bool hideAddAction;
  final VoidCallback? onDelete;
  /// True when audio generation is known to be in flight for this item.
  /// When audioUrl is empty: spinner if pending, retry icon otherwise.
  final bool isAudioPending;

  const VocabularyItemCard({
    super.key,
    required this.item,
    required this.onIconToggle,
    this.displayType = 'standard',
    this.hideAddAction = false,
    this.onDelete,
    this.isAudioPending = false,
  });

  @override
  State<VocabularyItemCard> createState() => _VocabularyItemCardState();
}

class _VocabularyItemCardState extends State<VocabularyItemCard> {
  String? _status;
  bool? _isAddedByUser;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _showBasisTop = false;
  bool _showBasisBottom = false;
  bool _showType = false;

  String _normalizedBasisText() {
    final basis = widget.item.basis?.trim() ?? '';
    if (basis.isEmpty) return '';
    if (basis.toLowerCase() == 'null') return '';
    return basis;
  }

  void _syncDisplayFlags() {
    final hasBasis = _normalizedBasisText().isNotEmpty;
    _showBasisTop = hasBasis && widget.item.word.length < 7;
    _showBasisBottom = hasBasis && widget.item.word.length >= 7;
    _showType = widget.item.word.isNotEmpty && widget.item.word.length < 20;
  }

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _isAddedByUser = widget.item.isAddedByUser ?? false;
    _audioPlayer = AudioPlayer();
    _syncDisplayFlags();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final audioUrl = widget.item.audioUrl;
    if (audioUrl.isEmpty) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {
          _isPlaying = true;
        });
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void didUpdateWidget(VocabularyItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always sync status from widget - needed when the same item object is mutated
    _status = widget.item.status;
    _isAddedByUser = widget.item.isAddedByUser ?? false;
    _syncDisplayFlags();
  }

  String displayTypeToText(String word, String wordType, bool properName) {
    if (wordType.isNotEmpty) {
      return WORD_SHORT_TYPES_FR.containsKey(wordType) && wordType.length > 0
          ? (WORD_SHORT_TYPES_FR[wordType]!.toLowerCase())
          : properName == true ? WORD_SHORT_TYPES_FR['properName'] as String : wordType.toLowerCase();
    } else {
      return WORD_SHORT_TYPES_FR['expr'] as String;
    }
  }

  Color getColorPlayIcon() {
    if (widget.displayType == 'flashcard') {
      switch (_status) {
        case 'saved':
          return AppColors.primary;
        case 'difficult':
          return AppColors.error;
        case 'training':
          return AppColors.secondary.withOpacity(0.9);
        case 'mastered':
          return AppColors.success;
        default:
          return Colors.black;
      }
    } else if (widget.displayType == 'standard') {
      if (_status != null) {
        return AppColors.primary;
      } else {
        return Colors.black;
      }
    } else if (widget.displayType == 'text') {
      return Colors.black;
    }
    return Colors.black;
  }

  Widget getCardStatusIcon(bool isAddedByUser) {
    if (widget.displayType == 'flashcard') {
      switch (_status) {
        case 'saved':
          return Icon(FontAwesomeIcons.solidFloppyDisk,
              size: 22, color: AppColors.primary);
        case 'difficult':
          return Icon(FontAwesomeIcons.solidTriangleExclamation,
              size: 22, color: AppColors.error);
        case 'training':
          return Icon(FontAwesomeIcons.solidDumbbell,
              size: 22, color: AppColors.secondary);
        case 'mastered':
          return Icon(FontAwesomeIcons.solidBadgeCheck,
              size: 22, color: AppColors.success);
        default:
          return Icon(FontAwesomeIcons.solidBookmark,
              size: 22, color: Colors.black);
      }
    } else if (widget.displayType == 'standard') {
      if (_status != null) {
        return Icon(FontAwesomeIcons.solidBookmark,
            size: 22, color: AppColors.primary);
      } else {
        return Icon(FontAwesomeIcons.thinBookmarkPlus,
            size: 22, color: Colors.black);
      }
    } else if (widget.displayType == 'text') {
      return isAddedByUser
          ? Icon(FontAwesomeIcons.trashCan, size: 18, color: Colors.black)
          : Icon(FontAwesomeIcons.plus, size: 18, color: Colors.black);
    }
    return Icon(FontAwesomeIcons.solidBookmark, size: 22, color: Colors.black);
  }

  Color getCardBackgroundColor(bool isAddedByUser) {
    if (widget.displayType == 'flashcard') {
      switch (_status) {
        case 'saved':
          return AppColors.primary.withOpacity(0.06);
        case 'difficult':
          return AppColors.error.withOpacity(0.06);
        case 'training':
          return AppColors.white;
        case 'mastered':
          return AppColors.success.withOpacity(0.06);
        default:
          return AppColors.white.withOpacity(0.06);
      }
    } else if (widget.displayType == 'standard') {
      switch (_status) {
        case 'saved':
          return Color(0xFFD3D3EE);
        case 'difficult':
          return Color(0xFFD3D3EE);
        case 'training':
          return Color(0xFFD3D3EE);
        case 'mastered':
          return Color(0xFFD3D3EE);
        default:
          return AppColors.textGrey;
      }
    } else if (widget.displayType == 'text') {
      if (widget.hideAddAction) {
        return AppColors.textGrey;
      } else if (isAddedByUser) {
        return AppColors.textGrey;
      } else {
        return AppColors.white;
      }
    }
    return AppColors.textGrey;
  }

  Color getCardBorderColor(bool isAddedByUser) {
    if (widget.displayType == 'flashcard') {
      switch (_status) {
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
    } else if (widget.displayType == 'standard') {
      return _status != null
          ? AppColors.primary.withOpacity(0.8)
          : Colors.black.withOpacity(0.2);
    } else if (widget.displayType == 'text') {
      return Colors.black.withOpacity(0.2);
    }
    return Colors.black.withOpacity(0.2);
  }

  Color getPlayIconBorderColor(bool isAddedByUser) {
    return Colors.transparent;
  }

  IconData getPlayIconIconData(bool isPlaying, String? status) {
    if (widget.displayType == 'flashcard') {
      return isPlaying
          ? FontAwesomeIcons.solidCirclePause
          : FontAwesomeIcons.solidCirclePlay;
    } else if (widget.displayType == 'standard') {
      return isPlaying
          ? (status != null
              ? FontAwesomeIcons.solidCirclePause
              : FontAwesomeIcons.thinCirclePause)
          : (status != null
              ? FontAwesomeIcons.solidCirclePlay
              : FontAwesomeIcons.thinCirclePlay);
    } else if (widget.displayType == 'text') {
      return isPlaying
          ? FontAwesomeIcons.thinCirclePause
          : FontAwesomeIcons.thinCirclePlay;
    }
    return FontAwesomeIcons.thinCirclePlay;
  }

  @override
  Widget build(BuildContext context) {
    final isAddedByUser = _isAddedByUser == true;
    final basisText = _normalizedBasisText();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: getCardBackgroundColor(isAddedByUser),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getCardBorderColor(isAddedByUser), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Play/Pause button
            if (widget.displayType != 'text')
              Center(
                child: GestureDetector(
                  onTap: widget.item.audioUrl.isEmpty ? null : _toggleAudio,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: getPlayIconBorderColor(isAddedByUser),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: widget.item.audioUrl.isNotEmpty
                          ? FaIcon(
                              getPlayIconIconData(_isPlaying, _status),
                              color: getColorPlayIcon(),
                              size: 30,
                            )
                          : widget.isAudioPending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        getColorPlayIcon()),
                                  ),
                                )
                              : FaIcon(
                                  FontAwesomeIcons.arrowRotateRight,
                                  color: getColorPlayIcon(),
                                  size: 22,
                                ),
                    ),
                  ),
                ),
              ),
            if (widget.displayType != 'text') const SizedBox(width: 14),
            // Word and translation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const SizedBox(height: 2),
                        Text(
                          widget.item.word,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_showType)
                          Text(
                            ' · ${displayTypeToText(widget.item.word, widget.item.type, widget.item.properName)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (isAddedByUser) ...[
                          const SizedBox(width: 12),
                          Tooltip(
                            message: AppLocalizations.of(context)!.addedByUser,
                            child: FaIcon(
                              FontAwesomeIcons.lightUserPen,
                              size: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                        if (_showBasisTop) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightArrowRightLong,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                basisText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          )
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 2),
                  if (widget.item.translation.isNotEmpty) ...[
                    Text(
                      '${widget.item.translation}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (_showBasisBottom) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightArrowRightLong,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          basisText,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    )
                  ],
                ],
              ),
            ),
            if (_isAddedByUser == true && widget.onDelete != null) ...[
              const SizedBox(width: 8),
              Center(
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: FaIcon(
                    FontAwesomeIcons.thinTrashCan,
                    size: 22,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      final wasAdded = _isAddedByUser == true;
                      // Toggle local state immediately for UI feedback
                      setState(() {
                        if (widget.displayType == 'standard')
                          _status = _status == 'saved' ? null : 'saved';
                        else if (widget.displayType == 'text')
                          _isAddedByUser =
                              _isAddedByUser == true ? false : true;
                      });
                      // Also update the item's state
                      widget.item.status = _status;
                      widget.item.isAddedByUser = _isAddedByUser;
                      if (widget.displayType == 'text' &&
                          !wasAdded &&
                          mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!
                                  .vocabularyAddedToList,
                              style: const TextStyle(color: Colors.black),
                            ),
                            backgroundColor: AppColors.textGrey,
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                      }
                      try {
                        await widget.onIconToggle();
                      } catch (e) {
                        // Revert on error
                        setState(() {
                          _status = "saved";
                        });
                        widget.item.status = _status;
                        debugPrint('Error in onIconToggle: $e');
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: widget.hideAddAction || widget.item.properName == true
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: getCardStatusIcon(isAddedByUser),
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
