import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class FlashcardSnackbar {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, String status, {bool showAtTop = false}) {
    if (!context.mounted) return;

    final Color bgColor;
    final IconData icon;
    final Color iconColor;
    final String label;
    final Color textColor;
    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case 'added':
        bgColor = AppColors.primary;
        icon = FontAwesomeIcons.thinCardsBlank;
        iconColor = Colors.white;
        textColor = Colors.white;
        label = l10n.expressionAddedToFlashcards;
        break;
      case 'saved':
        bgColor = AppColors.primary;
        icon = FontAwesomeIcons.solidFloppyDisk;
        iconColor = Colors.white;
        textColor = Colors.white;
        label = l10n.flashcardCategoryUpdated;
        break;
      case 'training':
        bgColor = AppColors.secondary;
        icon = FontAwesomeIcons.solidDumbbell;
        iconColor = AppColors.textPrimary;
        textColor = AppColors.textPrimary;
        label = l10n.flashcardCategoryUpdated;
        break;
      case 'difficult':
        bgColor = AppColors.error;
        icon = FontAwesomeIcons.solidTriangleExclamation;
        iconColor = Colors.white;
        textColor = Colors.white;
        label = l10n.flashcardCategoryUpdated;
        break;
      case 'mastered':
      default:
        bgColor = AppColors.success;
        icon = FontAwesomeIcons.solidShrimp;
        iconColor = AppColors.secondary;
        textColor = Colors.white;
        label = l10n.flashcardMastered;
        break;
    }

    if (showAtTop) {
      _showTopOverlay(context, bgColor: bgColor, icon: icon, iconColor: iconColor, label: label, textColor: textColor);
    } else {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: bgColor,
          content: Row(
            children: [
              FaIcon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: TextStyle(color: textColor)),
              ),
            ],
          ),
        ),
      );
    }
  }

  static void _showTopOverlay(
    BuildContext context, {
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required String label,
  }) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _TopSnackbar(
        bgColor: bgColor,
        icon: icon,
        iconColor: iconColor,
        textColor: textColor,
        label: label,
        onDismissed: () {
          entry.remove();
          if (_currentOverlay == entry) _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);
  }
}

class _TopSnackbar extends StatefulWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String label;
  final VoidCallback onDismissed;

  const _TopSnackbar({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.label,
    required this.onDismissed,
  });

  @override
  State<_TopSnackbar> createState() => _TopSnackbarState();
}

class _TopSnackbarState extends State<_TopSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismissed());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                FaIcon(widget.icon, color: widget.iconColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
