import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../widgets/article_card.dart';
import '../services/article_service.dart';
import '../constants/app_colors.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String selectedLevel = 'All';
  bool _isLoading = true;
  List<Article> _articles = [];
  String? _errorMessage;
  late final ArticleService _articleService;

  final List<String> levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void initState() {
    super.initState();
    _articleService = ArticleService(Supabase.instance.client);
    _loadArticles();
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
    if (selectedLevel == 'All') {
      return _articles;
    }
    return _articles.where((article) => article.level == selectedLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Library',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Levels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
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
                  children: levels.map((level) {
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
                            color: isSelected ? AppColors.secondary : Colors.white,
                            border: isSelected ? Border.all(color: AppColors.borderBlack) : Border.all(color: Colors.white),
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
            ),

            const SizedBox(height: 20),

            // Articles List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
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
                          ? const Center(
                              child: Text(
                                'No articles found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredArticles.length,
                              itemBuilder: (context, index) {
                                return ArticleCard(
                                  article: filteredArticles[index],
                                  onFavoriteToggle: () async {
                                    try {
                                      await _articleService.toggleFavorite(
                                        filteredArticles[index].id,
                                        !filteredArticles[index].isFavorite,
                                      );
                                      setState(() {
                                        filteredArticles[index].isFavorite =
                                            !filteredArticles[index].isFavorite;
                                      });
                                    } catch (e) {
                                      // Handle error
                                      print('Error toggling favorite: $e');
                                    }
                                  },
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

