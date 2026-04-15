import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/level_chip_row.dart';
import '../widgets/theme_chip.dart';

/// Shared filter bottom sheet used by both Library and Audiobooks pages.
///
/// The [includeFinishedLabel] parameter lets callers provide the correct
/// content-type-specific label (e.g. "Include finished articles" vs
/// "Include finished audiobooks").
class ContentFilterSheet extends StatefulWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelChanged;
  final List<String> themes;
  final Set<String> selectedThemes;
  final ValueChanged<Set<String>> onThemesChanged;
  final bool includeFinished;
  final ValueChanged<bool> onIncludeFinishedChanged;
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesOnlyChanged;
  final VoidCallback onApply;
  final String includeFinishedLabel;

  const ContentFilterSheet({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
    required this.themes,
    required this.selectedThemes,
    required this.onThemesChanged,
    required this.includeFinished,
    required this.onIncludeFinishedChanged,
    required this.favoritesOnly,
    required this.onFavoritesOnlyChanged,
    required this.onApply,
    required this.includeFinishedLabel,
  });

  @override
  State<ContentFilterSheet> createState() => _ContentFilterSheetState();
}

class _ContentFilterSheetState extends State<ContentFilterSheet> {
  late String _selectedLevel;
  late Set<String> _selectedThemes;
  late bool _includeFinished;
  late bool _favoritesOnly;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.selectedLevel;
    _selectedThemes = Set<String>.from(widget.selectedThemes);
    _includeFinished = widget.includeFinished;
    _favoritesOnly = widget.favoritesOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.filters,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    FontAwesomeIcons.thinCircleX,
                    size: 36,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Level
            Text(
              AppLocalizations.of(context)!.level,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            LevelChipRow(
              selectedLevel: _selectedLevel,
              onLevelChanged: (v) => setState(() => _selectedLevel = v),
            ),
            const SizedBox(height: 24),

            // Themes
            Text(
              AppLocalizations.of(context)!.themes,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.themes.map((theme) {
                final isAll = theme == 'All';
                final isSelected = isAll
                    ? _selectedThemes.isEmpty
                    : _selectedThemes.contains(theme);
                return ThemeChip(
                  label: theme,
                  isSelected: isSelected,
                  onTap: () {
                    if (isAll) {
                      setState(() => _selectedThemes = {});
                    } else {
                      final next = Set<String>.from(_selectedThemes);
                      if (next.contains(theme)) {
                        next.remove(theme);
                      } else {
                        next.add(theme);
                      }
                      setState(() => _selectedThemes = next);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Include finished toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.includeFinishedLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: _includeFinished,
                  onChanged: (v) => setState(() => _includeFinished = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onLevelChanged(_selectedLevel);
                  widget.onThemesChanged(_selectedThemes);
                  widget.onIncludeFinishedChanged(_includeFinished);
                  widget.onFavoritesOnlyChanged(_favoritesOnly);
                  widget.onApply();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                        color: AppColors.borderBlack, width: 1),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.apply,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
