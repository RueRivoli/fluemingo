import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/content.dart';
import '../l10n/app_localizations.dart';
import 'theme_chip.dart';

/// Reusable bottom sheet to edit "interesting themes" selection.
/// Use in profile content and profile settings.
class EditThemesBottomSheet extends StatefulWidget {
  /// Currently selected theme IDs (e.g. from profile).
  final List<String> initialSelectedThemes;

  /// Max number of themes the user can select.
  final int maxSelections;

  /// All theme options to show. Defaults to [THEMES] from library_themes.
  final List<String>? themeOptions;

  /// Called when user taps Save. Implement to call [ProfileService.updateThemeInterests]
  /// and update parent state. Return normally on success; throw or show error on failure.
  final Future<void> Function(List<String> selectedThemes) onSave;

  const EditThemesBottomSheet({
    super.key,
    required this.initialSelectedThemes,
    this.maxSelections = 5,
    this.themeOptions,
    required this.onSave,
  });

  /// Shows the bottom sheet and returns the selected themes if saved, null if cancelled.
  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> initialSelectedThemes,
    int maxSelections = 5,
    List<String>? themeOptions,
    required Future<void> Function(List<String>) onSave,
  }) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditThemesBottomSheet(
        initialSelectedThemes: initialSelectedThemes,
        maxSelections: maxSelections,
        themeOptions: themeOptions,
        onSave: onSave,
      ),
    );
    return result;
  }

  @override
  State<EditThemesBottomSheet> createState() => _EditThemesBottomSheetState();
}

class _EditThemesBottomSheetState extends State<EditThemesBottomSheet> {
  late Set<String> _localSelected;

  List<String> get _themeOptions => widget.themeOptions ?? THEMES.map((e) => e.id).toList();
  int get _maxSelections => widget.maxSelections;

  @override
  void initState() {
    super.initState();
    _localSelected = Set<String>.from(widget.initialSelectedThemes);
  }

  Future<void> _handleSave() async {
    if (_localSelected.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSelectAtLeastOneTheme),
          ),
        );
      }
      return;
    }
    try {
      await widget.onSave(_localSelected.toList());
      if (mounted) {
        Navigator.of(context).pop(_localSelected.toList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingThemes)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.favoriteThemes,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.selectUpToThemes(_maxSelections),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _themeOptions.map((theme) {
                final isSelected = _localSelected.contains(theme);
                return ThemeChip(
                  label: theme,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (_localSelected.contains(theme)) {
                        _localSelected.remove(theme);
                      } else if (_localSelected.length < _maxSelections) {
                        _localSelected.add(theme);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
