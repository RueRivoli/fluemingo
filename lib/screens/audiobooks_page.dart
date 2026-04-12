import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/audiobook.dart';
import '../services/audiobook_service.dart';
import '../constants/app_colors.dart';
import '../constants/content.dart';
import '../l10n/app_localizations.dart';
import '../l10n/label_localization.dart';
import '../widgets/audiobook_card.dart';
import '../widgets/audiobooks_skeleton.dart';
import '../widgets/content_filter_sheet.dart';
import '../widgets/level_chip_row.dart';
import '../stores/profile_store.dart';

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
  late AudiobookService _audiobookService;
  bool _didLoadInitial = false;
  String _lastNativeLanguage = '';

  @override
  void initState() {
    super.initState();
    _audiobookService = AudiobookService(Supabase.instance.client);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileStore = ProfileStoreScope.of(context);
    final currentNativeLanguage = profileStore.nativeLanguage;
    if (!_didLoadInitial) {
      _didLoadInitial = true;
      _lastNativeLanguage = currentNativeLanguage;
      _loadAudiobooks();
    } else if (currentNativeLanguage.isNotEmpty &&
        currentNativeLanguage != _lastNativeLanguage) {
      _lastNativeLanguage = currentNativeLanguage;
      _audiobookService = AudiobookService(Supabase.instance.client);
      _loadAudiobooks();
    }
  }

  @override
  void didUpdateWidget(covariant AudiobooksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _loadAudiobooks();
    }
  }

  Future<void> _loadAudiobooks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final audiobooks = await _audiobookService.getAudiobooks(level: selectedLevel);
      if (!mounted) return;
      setState(() {
        _audiobooks = audiobooks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      builder: (ctx) => ContentFilterSheet(
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
        includeFinishedLabel:
            AppLocalizations.of(context)!.includeFinishedAudiobooks,
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
              child: LevelChipRow(
                selectedLevel: selectedLevel,
                onLevelChanged: (level) {
                  setState(() => selectedLevel = level);
                  _loadAudiobooks();
                },
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
                                FontAwesomeIcons.thinCircleX,
                                size: 40,
                                color: AppColors.textPrimary,
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
