import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../widgets/article_card.dart';
import '../widgets/library_skeleton.dart';
import '../services/article_service.dart';
import '../constants/app_colors.dart';
import '../constants/levels.dart';
import '../constants/content.dart';
import '../l10n/app_localizations.dart';
import '../l10n/label_localization.dart';
import '../widgets/theme_chip.dart';
import '../stores/profile_store.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, this.isVisible = true});

  final bool isVisible;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String selectedLevel = 'All';
  Set<String> selectedThemes = {}; // empty = All themes
  bool includeFinished = false;
  bool favoritesOnly = false;
  bool _isLoading = true;
  List<Article> _articles = [];
  String? _errorMessage;
  bool _isSubscribed = false;
  late final ArticleService _articleService;
  late ProfileStore _profileStore;
  bool _didLoadInitial = false;

  @override
  void initState() {
    super.initState();
    _articleService = ArticleService(Supabase.instance.client);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileStore = ProfileStoreScope.of(context);
    _isSubscribed = _profileStore.isSubscribed;
    if (!_didLoadInitial) {
      _didLoadInitial = true;
      _loadArticles();
    }
  }

  @override
  void didUpdateWidget(covariant LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _loadArticles();
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await _articleService.getArticles(level: selectedLevel);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading articles: $e';
        _isLoading = false;
      });
    }
  }

  List<Article> get filteredArticles {
    var list = _articles;
    if (selectedLevel != 'All') {
      list = list.where((a) => a.level == selectedLevel).toList();
    }
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
      builder: (ctx) => _LibraryFilterSheet(
        selectedLevel: selectedLevel,
        onLevelChanged: (v) => setState(() => selectedLevel = v),
        themes: THEMES.map((e) => e.id).toList(),
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

  Widget _buildArticleCard(
    Article article, {
    bool stackChipsAtBottom = false,
  }) {
    return ArticleCard(
      article: article,
      showLocker: !_isSubscribed && !article.isFree,
      stackChipsAtBottom: stackChipsAtBottom,
      onFavoriteToggle: () async {
        try {
          await _articleService.toggleFavorite(article.id);
          setState(() {
            article.isFavorite = !article.isFavorite;
          });
        } catch (e) {
          print('Error toggling favorite: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //  final readingLevels = getReadingLevels(context);
    return Scaffold(
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
                          AppLocalizations.of(context)!.navLibrary,
                          style: TextStyle(
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
                          _loadArticles();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.secondary : Colors.white,
                            border: isSelected
                                ? Border.all(color: AppColors.borderBlack)
                                : Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level == 'All'
                                ? AppLocalizations.of(context)!.allLevels
                                : level,
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
            ),

            // Themes section (only when some theme filters are selected)
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
                    children: selectedThemes.map((theme) {
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
                                getTranslatedLabel(context, theme),
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
                                          ..remove(theme);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
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
                              AppLocalizations.of(context)!
                                  .includeFinishedArticles,
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
                                  Icons.close,
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
                              AppLocalizations.of(context)!
                                  .favoritesArticlesOnly,
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
                                  Icons.close,
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

            // Articles List
            Expanded(
              child: _isLoading
                  ? const LibraryPageSkeleton()
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadArticles,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filteredArticles.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noArticlesFound,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final isTabletLayout =
                                    constraints.maxWidth >= 700;
                                if (!isTabletLayout) {
                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    itemCount: filteredArticles.length,
                                    itemBuilder: (context, index) =>
                                        _buildArticleCard(
                                      filteredArticles[index],
                                    ),
                                  );
                                }

                                return GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: filteredArticles.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: (() {
                                      const horizontalPadding = 20.0;
                                      const crossSpacing = 12.0;
                                      const estimatedCardHeight = 460.0;
                                      final tileWidth = (constraints.maxWidth -
                                              (horizontalPadding * 2) -
                                              crossSpacing) /
                                          2;
                                      return tileWidth / estimatedCardHeight;
                                    })(),
                                  ),
                                  itemBuilder: (context, index) =>
                                      _buildArticleCard(
                                    filteredArticles[index],
                                    stackChipsAtBottom: true,
                                  ),
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

class _LibraryFilterSheet extends StatefulWidget {
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

  const _LibraryFilterSheet({
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
  State<_LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<_LibraryFilterSheet> {
  /// Local copy so the sheet rebuilds and shows selection when chips/switches are tapped.
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Level
            Text(
              AppLocalizations.of(context)!.level,
              style: TextStyle(
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
                          color:
                              isSelected ? AppColors.secondary : Colors.white,
                          border: isSelected
                              ? Border.all(color: AppColors.borderBlack)
                              : Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          level == 'All'
                              ? AppLocalizations.of(context)!.allLevels
                              : level,
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
              style: TextStyle(
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
                final leadingIcon = theme == 'All'
                    ? null
                    : THEMES.where((e) => e.id == theme).firstOrNull?.icon;
                return ThemeChip(
                  label: theme,
                  isSelected: isSelected,
                  leadingIcon: leadingIcon,
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
            // Include Finished Articles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.includeFinishedArticles,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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
            // Favorite Articles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.showOnlyFavoriteArticles,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
