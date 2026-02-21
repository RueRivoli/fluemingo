import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';
import '../constants/word_types.dart';

class VocabularyItemCard extends StatefulWidget {
  final VocabularyItem item;
  final Future<void> Function() onIconToggle;
  final String displayType; // 'standard', 'flashcard','text'
  final bool hideAddAction;
  final VoidCallback? onDelete;

  const VocabularyItemCard({
    super.key,
    required this.item,
    required this.onIconToggle,
    this.displayType = 'standard',
    this.hideAddAction = false,
    this.onDelete,
  });

  @override
  State<VocabularyItemCard> createState() => _VocabularyItemCardState();
}

class _VocabularyItemCardState extends State<VocabularyItemCard> {
  String? _status;
  bool? _isAddedByUser;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _isAddedByUser = widget.item.isAddedByUser ?? false;
    _audioPlayer = AudioPlayer();

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
          return Icon(FontAwesomeIcons.solidFloppyDisk, size: 22, color: AppColors.primary);
        case 'difficult':
          return Icon(FontAwesomeIcons.solidTriangleExclamation, size: 22, color: AppColors.error);
        case 'training':
          return Icon(FontAwesomeIcons.solidDumbbell, size: 22, color: AppColors.secondary);
        case 'mastered':
          return Icon(FontAwesomeIcons.solidBadgeCheck, size: 22, color: AppColors.success);
        default:
          return Icon(FontAwesomeIcons.solidBookmark, size: 22, color: Colors.black);
      }
    } else if (widget.displayType == 'standard') {
      if (_status != null) {
        return Icon(FontAwesomeIcons.solidBookmark, size: 22, color: AppColors.primary);
      } else {
        return Icon(FontAwesomeIcons.thinBookmarkPlus, size: 22, color: Colors.black);
      }
    } else if (widget.displayType == 'text') {
      return isAddedByUser ? Icon(FontAwesomeIcons.trashCan, size: 18, color: Colors.black) : Icon(FontAwesomeIcons.plus, size: 18, color: Colors.black);
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
           return AppColors.secondary.withOpacity(0.06);
        case 'mastered':
           return AppColors.success.withOpacity(0.06);
        default:
          return Colors.black.withOpacity(0.06);
      }
    } else if (widget.displayType == 'standard') {
      return isAddedByUser ? Colors.black.withOpacity(0.06) : Colors.white.withOpacity(0.06);
    } else if (widget.displayType == 'text') {
      return Colors.white;
  }
    return Colors.black.withOpacity(0.06);
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
      return isAddedByUser ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2);
    } else if (widget.displayType == 'text') {
      return isAddedByUser ? Colors.black.withOpacity(0.06) : Colors.black.withOpacity(0.2);
  }
    return Colors.black.withOpacity(0.2);
  }

    Color getPlayIconBorderColor(bool isAddedByUser) {
    if (widget.displayType == 'flashcard') {
        switch (_status) {
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
    } else if (widget.displayType == 'standard') {
      if (_status != null) {
        return AppColors.primary;
      } else {
        return Colors.transparent;
      }
    } else if (widget.displayType == 'text') {
      return Colors.white;
  }
    return Colors.black;
  }

  IconData getPlayIconIconData(bool isPlaying, String? status) {
    if (widget.displayType == 'flashcard') {
      return isPlaying ? FontAwesomeIcons.solidCirclePause : FontAwesomeIcons.solidCirclePlay;
    } else if (widget.displayType == 'standard') {
      return isPlaying
          ? (status != null ? FontAwesomeIcons.solidCirclePause : FontAwesomeIcons.thinCirclePlay)
          : (status != null ? FontAwesomeIcons.solidCirclePlay : FontAwesomeIcons.thinCirclePlay);
    } else if (widget.displayType == 'text') {
      return isPlaying ? FontAwesomeIcons.thinCirclePause : FontAwesomeIcons.thinCirclePlay;
    }
    return FontAwesomeIcons.thinCirclePlay;
  }

  @override
  Widget build(BuildContext context) {
    final isAddedByUser = _isAddedByUser == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAddedByUser ? AppColors.primary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getCardBorderColor(isAddedByUser), width: 1),
        boxShadow: [
          BoxShadow(
            color: getCardBackgroundColor(isAddedByUser),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Play/Pause button
          if (widget.displayType != 'text') GestureDetector(
            onTap: _toggleAudio,
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
                child: FaIcon(
                  getPlayIconIconData(_isPlaying, _status),
                  color: getColorPlayIcon(),
                  size: 30,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.word,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (widget.item.type.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      if (WORD_SHORT_TYPES_FR.containsKey(widget.item.type))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            (WORD_SHORT_TYPES_FR[widget.item.type]!),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      else
                        Text(
                          widget.item.type,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.item.translation}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (_isAddedByUser == true && widget.onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onDelete,
              child: FaIcon(
                FontAwesomeIcons.trashCan,
                size: 22,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
            onTap: () async {
              // Toggle local state immediately for UI feedback
              setState(() {
                if (widget.displayType == 'standard') _status = _status == 'saved' ? null : 'saved';
                else if (widget.displayType == 'text') _isAddedByUser = _isAddedByUser == true ? false : true;
              });
              // Also update the item's state
              widget.item.status = _status;
              widget.item.isAddedByUser = _isAddedByUser;
              try {
                await widget.onIconToggle();
              } catch (e) {
                // Revert on error
                setState(() {
                  _status = "saved";
                });
                widget.item.status = _status;
                print('Error in onIconToggle: $e');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: widget.hideAddAction ? const SizedBox.shrink() : Padding(
              padding: const EdgeInsets.all(8.0),
              child: getCardStatusIcon(isAddedByUser),
            ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
