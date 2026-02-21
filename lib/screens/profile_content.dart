import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/profile_service.dart';
import '../services/audiobook_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../widgets/article_card.dart';
import '../widgets/audiobook_card.dart';
import '../models/audiobook.dart';
import '../stores/profile_store.dart';
import '../services/article_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/edit_themes_bottom_sheet.dart';
import '../widgets/theme_chip.dart';

enum ContentMenu { inProgress, favorite, interesting }

class ProfileContent extends StatefulWidget {
  final bool isVisible;
  final String category; // "inProgress", "favorite", "interesting"
  /// When true, renders without Scaffold so it can be embedded in another page.
  final bool embedded;

  const ProfileContent({super.key, this.isVisible = true, this.category = "inProgress", this.embedded = false});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}


class _ProfileContentState extends State<ProfileContent> {
  static const int _maxSelections = 5;
  late final ProfileService profileService = ProfileService(Supabase.instance.client);
  late final ArticleService _articleService;
  late final AudiobookService _audiobookService;
  bool isLoading = true;
  List<Article> _inProgressArticles = [];
  List<Audiobook> _inProgressAudiobooks = [];
  List<Article> _favoriteArticles = [];
  List<Audiobook> _favoriteAudiobooks = [];
  List<Article> _interestingArticles = [];
  List<Audiobook> _interestingAudiobooks = [];
  List<String> _interestThemes = [];
  Set<String> _selectedThemes = {};

  @override
  void initState() {
    super.initState();
     _articleService = ArticleService(Supabase.instance.client);
     _audiobookService = AudiobookService(Supabase.instance.client);
    _loadProfileContentData();
  }

    @override
  void didUpdateWidget(covariant ProfileContent oldWidget) {
    print('didUpdateWidget week progress');
    super.didUpdateWidget(oldWidget);
    // Reload when switching tabs or changing category
    if ((widget.isVisible && !oldWidget.isVisible) || widget.category != oldWidget.category) {
      _loadProfileContentData();
    }
  }

  Future<void> _loadProfileContentData() async {
    if (mounted) setState(() => isLoading = true);
    if (widget.category == 'inProgress') {
      _inProgressArticles = await profileService.getArticlesInProgress();
      _inProgressAudiobooks = await profileService.getAudiobooksInProgress();
    } else if (widget.category == 'favorite') {
      final favoriteArticlesRaw = await profileService.getFavoriteArticles();
      _favoriteArticles = favoriteArticlesRaw.where((article) => article.readingStatus != 'started' && article.readingStatus != 'finished').toList();
      final favoriteAudiobooksRaw = await profileService.getFavoriteAudiobooks();
      print('favoriteAudiobooksRaw: ${favoriteAudiobooksRaw}');
      _favoriteAudiobooks = favoriteAudiobooksRaw.where((audiobook) => audiobook.readingStatus != 'finished').toList();
    } else if (widget.category == 'interesting') {
      _interestThemes = await profileService.getThemeInterests();
      print('interestThemes: ${_interestThemes}');
      _selectedThemes = _interestThemes.toSet();
      print('selectedThemes: ${_selectedThemes}');
      final interestingArticlesRaw = await profileService.getInterestingArticles();
      _interestingArticles = interestingArticlesRaw.where((article) => article.readingStatus != 'started' && article.readingStatus != 'finished').toList();
      final interestingAudiobooksRaw = await profileService.getInterestingAudiobooks();
      _interestingAudiobooks = interestingAudiobooksRaw.where((audiobook) => audiobook.readingStatus != 'started' && audiobook.readingStatus != 'finished').toList();
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  List<Widget> _buildMenuContent() {
    switch (widget.category) {
      case 'inProgress':
        return [
          if (_inProgressArticles.isNotEmpty) ...[
            const Text(
              'Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                itemCount: _inProgressArticles.length,
                itemBuilder: (context, index) {
                  final article = _inProgressArticles[index];
                  return ArticleCard(
                    article: article,
                    onFavoriteToggle: () {
                      _articleService.toggleFavorite(article.id);
                      setState(() {
                        article.isFavorite = !article.isFavorite;
                      });
                    },
                    minified: true,
                    showStatusBadge: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_inProgressAudiobooks.isNotEmpty) ...[
            const Text(
              'Audiobooks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                itemCount: _inProgressAudiobooks.length,
                itemBuilder: (context, index) {
                  final audiobook = _inProgressAudiobooks[index];
                  final profileStore = ProfileStoreScope.of(context);
                  final isSubscribed = profileStore.isSubscribed;
                  return AudiobookCard(audiobook: audiobook, showIsFavorite: audiobook.isFavorite, showLocker: !isSubscribed && !audiobook.isFree, onFavoriteToggled: () {
                    if (!isSubscribed && !audiobook.isFree != null) return;
                    _audiobookService.toggleFavorite(audiobook.id);
                    setState(() {
                      audiobook.isFavorite = !audiobook.isFavorite;
                    });
                  });
                },
              ),
            ),
          ],
            if (_inProgressArticles.isEmpty && _inProgressAudiobooks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'No content in Progress.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ];
      case 'favorite':
        return [
          if (_favoriteArticles.isNotEmpty) ...[
            const Text(
              'Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                itemCount: _favoriteArticles.length,
                itemBuilder: (context, index) {
                  final article = _favoriteArticles[index];
                  return ArticleCard(
                    article: article,
                    onFavoriteToggle: () {
                      _articleService.toggleFavorite(article.id);
                      setState(() {
                        article.isFavorite = !article.isFavorite;
                      });
                    },
                    minified: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_favoriteAudiobooks.isNotEmpty) ...[
            const Text(
              'Audiobooks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                itemCount: _favoriteAudiobooks.length,
                itemBuilder: (context, index) {
                  final audiobook = _favoriteAudiobooks[index];
                  final profileStore = ProfileStoreScope.of(context);
                  final isSubscribed = profileStore.isSubscribed;
                  return AudiobookCard(audiobook: audiobook, showIsFavorite: audiobook.isFavorite, showLocker: !isSubscribed && !audiobook.isFree, onFavoriteToggled: () {
                    if (!isSubscribed && !audiobook.isFree != null) return;
                    _audiobookService.toggleFavorite(audiobook.id);
                    setState(() {
                      audiobook.isFavorite = !audiobook.isFavorite;
                    });
                  });
                },
              ),
            ),
          ],
          if (_favoriteArticles.isEmpty && _favoriteAudiobooks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'No liked content yet. Click on the heart icon to like a content.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ];
      case 'interesting':
        return [
          if (_interestingArticles.isNotEmpty) ...[
            const Text(
              'Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                itemCount: _interestingArticles.length,
                itemBuilder: (context, index) {
                  final article = _interestingArticles[index];
                  return ArticleCard(
                    article: article,
                    onFavoriteToggle: () {
                      _articleService.toggleFavorite(article.id);
                      setState(() {
                        _interestingArticles[index].isFavorite = !article.isFavorite;
                      });
                    },
                    minified: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_interestingAudiobooks.isNotEmpty) ...[
            const Text(
              'Audiobooks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                itemCount: _interestingAudiobooks.length,
                itemBuilder: (context, index) {
                  final audiobook = _interestingAudiobooks[index];
                  final profileStore = ProfileStoreScope.of(context);
                  final isSubscribed = profileStore.isSubscribed;
                  return AudiobookCard(audiobook: audiobook, showIsFavorite: audiobook.isFavorite, showLocker: !isSubscribed && !audiobook.isFree, onFavoriteToggled: () {
                    if (!isSubscribed && !audiobook.isFree != null) return;
                    _audiobookService.toggleFavorite(audiobook.id);
                    setState(() {
                      audiobook.isFavorite = !audiobook.isFavorite;
                    });
                  });
                },
              ),
            ),
          ],
          if (_interestingArticles.isEmpty && _interestingAudiobooks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'No suggestions yet.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ];
      default:
        return [];
    }
  }

  String get _categoryTitle {
    switch (widget.category) {
      case 'inProgress':
        return 'Your Content in Progress';
      case 'favorite':
        return 'Your Favorite Content';
      case 'interesting':
        return 'Content Matching Your Interests';
      default:
        return 'Your content';
    }
  }

  static const double _kTopBarHeight = 60; // 8 + 40 + 12

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: widget.embedded ? 0 : MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 20,
      ),
      color: AppColors.background,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.chevronLeft,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _categoryTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  void _showInterestingThemesBottomSheet() {
    EditThemesBottomSheet.show(
      context,
      initialSelectedThemes: _interestThemes,
      maxSelections: _maxSelections,
      onSave: (selected) async {
        await profileService.updateThemeInterests(selected);
        if (mounted) {
          setState(() {
            _selectedThemes = selected.toSet();
            _interestThemes = selected;
          });
          _loadProfileContentData();
        }
      },
    );
  }

  void _onThemeTap(String theme) {
    setState(() {
      if (_selectedThemes.contains(theme)) {
        _selectedThemes.remove(theme);
      } else if (_selectedThemes.length < _maxSelections) {
        _selectedThemes.add(theme);
      }
    });
  }

  bool _isSelected(String theme) {
    return _selectedThemes.contains(theme);
  }


  Widget _buildScrollableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.category == 'inProgress')
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 12),
            child: Text(
              'Finish this content to earn XP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (widget.category == 'favorite')
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 12),
            child: Text(
              'Based on your Likes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (widget.category == 'interesting') ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 4),
            child: Text(
              'Based on your Favorite Themes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_interestThemes.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _interestThemes.map((theme) => ThemeChip(label: theme, isSelected: true, onTap: () {})).toList(),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: InkWell(
                    onTap: _showInterestingThemesBottomSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FontAwesomeIcons.pencil, size: 20, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        ..._buildMenuContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopBar(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [_buildScrollableContent()],
          ),
        ],
      );
    }
    // Full screen: list first (behind), then top bar on top so it receives taps
    final topPadding = MediaQuery.of(context).padding.top + _kTopBarHeight;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: ListView(
            padding: EdgeInsets.only(
              top: topPadding,
              left: 20,
              right: 20,
            ),
            children: [_buildScrollableContent()],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false, // Top bar handles its own top padding
        child: _buildContent(),
      ),
    );
  }
}

