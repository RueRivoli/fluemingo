import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';

class VocabularyItemCard extends StatefulWidget {
  final VocabularyItem item;
  final Future<void> Function() onIconToggle;
  final String displayType; // 'standard' or 'text'

  const VocabularyItemCard({
    super.key,
    required this.item,
    required this.onIconToggle,
    this.displayType = 'standard',
  });

  @override
  State<VocabularyItemCard> createState() => _VocabularyItemCardState();
}

class _VocabularyItemCardState extends State<VocabularyItemCard> {
  String? _status;
  bool? _isAddedByUser;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _isAddedByUser = widget.item.isAddedByUser ?? false;
  }

  @override
  void didUpdateWidget(VocabularyItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always sync status from widget - needed when the same item object is mutated
    _status = widget.item.status;
    _isAddedByUser = widget.item.isAddedByUser ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final useWhiteBackground = _isAddedByUser == false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: useWhiteBackground ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: useWhiteBackground
            ? null
            : Border.all(
                color: Colors.grey[400]!,
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: useWhiteBackground
                ? Colors.black.withOpacity(0.04)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _status == 'saved' ? AppColors.primary : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Word and translation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.item.word} (${widget.item.type})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.item.translation}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Bookmark or add button
          InkWell(
            onTap: () async {
              // Toggle local state immediately for UI feedback
              setState(() {
                if (widget.displayType == 'standard') _status = _status == 'saved' ? null : 'saved';
                else _isAddedByUser = _isAddedByUser == true ? false : true;
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                widget.displayType == 'text' ? _isAddedByUser == true ? Icons.cancel : Icons.add : _status == 'saved' ? Icons.bookmark : Icons.bookmark_border,
                size: 26,
                color: _status == 'saved' ? AppColors.primary : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
