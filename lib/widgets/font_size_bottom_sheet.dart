import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Bottom sheet for adjusting article reading font size.
class FontSizeBottomSheet {
  static void show(
    BuildContext context, {
    required double initialFontSize,
    required void Function(double) onFontSizeChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FontSizeBottomSheetContent(
        initialFontSize: initialFontSize,
        onFontSizeChanged: onFontSizeChanged,
      ),
    );
  }
}

class _FontSizeBottomSheetContent extends StatefulWidget {
  final double initialFontSize;
  final void Function(double) onFontSizeChanged;

  const _FontSizeBottomSheetContent({
    required this.initialFontSize,
    required this.onFontSizeChanged,
  });

  @override
  State<_FontSizeBottomSheetContent> createState() =>
      _FontSizeBottomSheetContentState();
}

class _FontSizeBottomSheetContentState
    extends State<_FontSizeBottomSheetContent> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.fontSize,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _fontSize,
            min: 14,
            max: 24,
            divisions: 10,
            label: _fontSize.toStringAsFixed(0),
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() => _fontSize = value);
              widget.onFontSizeChanged(value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('14',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(
                _fontSize.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text('24',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
