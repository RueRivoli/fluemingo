import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audiobook.dart';
import '../services/audiobook_service.dart';
import '../constants/app_colors.dart';
import '../constants/levels.dart';
import '../constants/content.dart';
import '../l10n/app_localizations.dart';
import '../l10n/label_localization.dart';
import '../widgets/audiobook_card.dart';
import '../widgets/theme_chip.dart';
import '../widgets/audiobooks_skeleton.dart';
import '../stores/profile_store.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AudiobooksPage extends StatefulWidget {
  const AudiobooksPage({super.key, this.isVisible = false});

  final bool isVisible;

  @override
  State<AudiobooksPage> createState() => _AudiobooksPageState();
}

class _AudiobooksPageState extends State<AudiobooksPage> {
  String selectedLevel = 'All';
  Set<String> selectedThemes = {};
  bool includeFinished = false;
  bool favoritesOnly = false;
  bool _isLoading = false;
  List<Audiobook> _audiobooks = [];
  String? _errorMessage;
  late final AudiobookService _audiobookService;

  @override
  void initState() {
    super.initState();
    _audiobookService = AudiobookService(Supabase.instance.client);
    _loadAudiobooks();
  }

  @override
  void didUpdateWidget(covariant AudiobooksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _loadAudiobooks();
    }
  }

  Future<void> _loadAudiobooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final audiobooks = await _audiobookService.getAudiobooks(level: selectedLevel);
      setState(() {
        _audiobooks = audiobooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading audiobooks: $e';
        _isLoading = false;
      });
    }
  }

  List<Audiobook> get filteredAudiobooks {
    var list = _audiobooks;
    if (selectedThemes.isNotEmpty) {
      list = list.where((a) {
        final cats = [a.category1, a.category2, a.category3]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toSet();
        return cats.any((c) => selectedThemes.contains(c));
      }).toList();
    }
    if (!includeFinished) {
      list = list.where((a) => a.readingStatus != 'finished').toList();
    }
    if (favoritesOnly) {
      list = list.where((a) => a.isFavorite).toList();
    }
    return list;
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AudiobooksFilterSheet(
        selectedLevel: selectedLevel,
        onLevelChanged: (v) {
          setState(() => selectedLevel = v);
          _loadAudiobooks();
        },
        themes: ['All', ...THEMES.map((e) => e.id)],
        selectedThemes: selectedThemes,
        onThemesChanged: (v) => setState(() => selectedThemes = v),
        includeFinished: includeFinished,
        onIncludeFinishedChanged: (v) => setState(() => includeFinished = v),
        favoritesOnly: favoritesOnly,
        onFavoritesOnlyChanged: (v) => setState(() => favoritesOnly = v),
        onApply: () => Navigator.pop(ctx),
      ),
    );
  }

  Map<String, List<Audiobook>> get audiobooksByCategory {
    final Map<String, List<Audiobook>> categorized = {};
    for (final book in filteredAudiobooks) {
      if (!categorized.containsKey(book.category1)) {
        categorized[book.category1] = [];
      }
      categorized[book.category1]!.add(book);
    }
    return categorized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.audiobooks,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.level,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.filter_list),
                    color: AppColors.textPrimary,
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
            ),

            // Level Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: LEVELS.map((level) {
                    final isSelected = selectedLevel == level;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLevel = level;
                          });
                          _loadAudiobooks();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary : Colors.white,
                            border: isSelected ? Border.all(color: AppColors.borderBlack) : Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level == 'All' ? AppLocalizations.of(context)!.allLevels : level,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Theme filters (when any selected)
            if (selectedThemes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  AppLocalizations.of(context)!.themes,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: selectedThemes.map((t) {
                      var categoryKey = t.trim().toLowerCase();
                      if (categoryKey == 'sports') categoryKey = 'sport';
                      final themeIcon = THEMES
                          .where((e) => e.id == categoryKey)
                          .firstOrNull
                          ?.icon;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 12,
                            top: 6,
                            bottom: 6,
                            right: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            border: Border.all(color: AppColors.borderBlack),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getTranslatedLabel(context, t),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedThemes =
                                        Set<String>.from(selectedThemes)
                                          ..remove(t);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    FontAwesomeIcons.xmark,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // Include finished / Favorites only (when toggled on)
            if (includeFinished || favoritesOnly) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  AppLocalizations.of(context)!.activeFilters,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (includeFinished)
                      Container(
                        padding: const EdgeInsets.only(
                          left: 12,
                          top: 6,
                          bottom: 6,
                          right: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          border: Border.all(color: AppColors.borderBlack),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                             AppLocalizations.of(context)!.includeFinishedAudiobooks,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => includeFinished = false),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  FontAwesomeIcons.xmark,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (favoritesOnly)
                      Container(
                        padding: const EdgeInsets.only(
                          left: 12,
                          top: 6,
                          bottom: 6,
                          right: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          border: Border.all(color: AppColors.borderBlack),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.favoritesAudiobooksOnly,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => favoritesOnly = false),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  FontAwesomeIcons.xmark,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Audiobooks List by Category
            Expanded(
              child: _isLoading
                  ? const AudiobooksPageSkeleton()
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAudiobooks,
                                child: Text(AppLocalizations.of(context)!.retry),
                              ),
                            ],
                          ),
                        )
                      : filteredAudiobooks.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noAudiobooksFound,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: audiobooksByCategory.length,
                itemBuilder: (context, index) {
                  final category = audiobooksByCategory.keys.elementAt(index);
                  final books = audiobooksByCategory[category]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          audiobookTypeLabel(context, category),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Books Grid
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: books.length,
                          itemBuilder: (context, bookIndex) {
                            final book = books[bookIndex];
                            final profileStore = ProfileStoreScope.of(context);
                            final isSubscribed = profileStore.isSubscribed;
                            return AudiobookCard(
                              audiobook: book,
                              showIsFavorite: book.isFavorite,
                              showLocker: !isSubscribed && !book.isFree,
                              onFavoriteToggled: () {
                                if (!isSubscribed && !book.isFree) return;
                                _audiobookService.toggleFavorite(book.id);
                                setState(() {
                                  book.isFavorite = !book.isFavorite;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudiobooksFilterSheet extends StatefulWidget {
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

  const _AudiobooksFilterSheet({
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
  });

  @override
  State<_AudiobooksFilterSheet> createState() => _AudiobooksFilterSheetState();
}

class _AudiobooksFilterSheetState extends State<_AudiobooksFilterSheet> {
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
            Text(
              AppLocalizations.of(context)!.filters,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: LEVELS.map((level) {
                  final isSelected = _selectedLevel == level;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedLevel = level);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.secondary : Colors.white,
                          border: isSelected
                              ? Border.all(color: AppColors.borderBlack)
                              : Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
              children: widget.themes.map((t) {
                final isAll = t == 'All';
                final isSelected =
                    isAll ? _selectedThemes.isEmpty : _selectedThemes.contains(t);
                final leadingIcon = t == 'All'
                    ? null
                    : THEMES.where((e) => e.id == t).firstOrNull?.icon;
                return ThemeChip(
                  label: t,
                  isSelected: isSelected,
                  leadingIcon: leadingIcon,
                  onTap: () {
                    if (isAll) {
                      setState(() => _selectedThemes = {});
                    } else {
                      final next = Set<String>.from(_selectedThemes);
                      if (next.contains(t)) {
                        next.remove(t);
                      } else {
                        next.add(t);
                      }
                      setState(() => _selectedThemes = next);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Include Finished Audiobooks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.includeFinishedAudiobooks,
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
            const SizedBox(height: 12),
            // Show only Favorite Audiobooks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.showOnlyFavoriteAudiobooks,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: _favoritesOnly,
                  onChanged: (v) => setState(() => _favoritesOnly = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 28),
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
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.apply,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
