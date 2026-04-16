import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../services/flashcard_service.dart';
import '../l10n/app_localizations.dart';

/// Bottom sheet to edit the flashcard category (status) for a vocabulary item.
/// Shows the word and four status buttons: Saved, Difficult, Training, Mastered.
/// The current status button is greyed out and not tappable.
class FlashcardStatusSheet extends StatelessWidget {
  final String word;
  final String? currentStatus;
  final void Function(String status)? onStatusSelected;

  const FlashcardStatusSheet({
    super.key,
    required this.word,
    this.currentStatus,
    this.onStatusSelected,
  });

  /// Shows the bottom sheet and returns the selected status when the user picks one, or null if dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String word,
    String? currentStatus,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FlashcardStatusSheet(
        word: word,
        currentStatus: currentStatus,
        onStatusSelected: (status) => Navigator.of(context).pop(status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Edit Flashcard category for',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            word,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Column(children: [
              _StatusButton(
                label: l10n.saved,
                status: FlashcardStatus.saved.value,
                icon: FontAwesomeIcons.floppyDisk,
                color: AppColors.primary,
                isCurrent: currentStatus == FlashcardStatus.saved.value,
                onTap: () =>
                    onStatusSelected?.call(FlashcardStatus.saved.value),
              ),
              const SizedBox(height: 10),
              _StatusButton(
                label: l10n.difficult,
                status: FlashcardStatus.difficult.value,
                icon: FontAwesomeIcons.triangleExclamation,
                color: AppColors.error,
                isCurrent: currentStatus == FlashcardStatus.difficult.value,
                onTap: () =>
                    onStatusSelected?.call(FlashcardStatus.difficult.value),
              ),
              const SizedBox(height: 10),
              _StatusButton(
                label: l10n.training,
                status: FlashcardStatus.training.value,
                icon: FontAwesomeIcons.dumbbell,
                color: AppColors.secondary,
                isCurrent: currentStatus == FlashcardStatus.training.value,
                onTap: () =>
                    onStatusSelected?.call(FlashcardStatus.training.value),
              ),
              const SizedBox(height: 10),
              _StatusButton(
                label: l10n.mastered,
                status: FlashcardStatus.mastered.value,
                icon: FontAwesomeIcons.badgeCheck,
                color: AppColors.success,
                isCurrent: currentStatus == FlashcardStatus.mastered.value,
                onTap: () =>
                    onStatusSelected?.call(FlashcardStatus.mastered.value),
              ),
            ]);
          }),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String status;
  final IconData icon;
  final Color color;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.label,
    required this.status,
    required this.icon,
    required this.color,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isCurrent ? AppColors.textGrey : color;
    final borderColor = isCurrent
        ? AppColors.textGrey.withOpacity(0.5)
        : color.withOpacity(0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrent ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.textGrey.withOpacity(0.2)
                : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 20,
                color: effectiveColor,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
