import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'target_language_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback? onComplete;
  
  const WelcomePage({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer at top
            const SizedBox(height: 60),
            
            // App Title
            const Text(
              'Fluemingo',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Learn with your '),
                    TextSpan(
                      text: 'favorite content',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
             const SizedBox(height: 20),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Build a '),
                    TextSpan(
                      text: 'Strong, Lasting Vocabulary',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            
            // Book covers showcase
            Expanded(
              child: Column(
                children: [
                  // Label above books
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.arrowRight, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'articles about topics you love',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.arrowRight, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'articles about current events',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.arrowRight, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'audiobooks about topics you love',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Book covers collage
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildBookCoversCollage(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TargetLanguagePage(
                        onComplete: onComplete,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.lightArrowRight,
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
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
    );
  }

  Widget _buildBookCoversCollage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background books (left side)
        Positioned(
          left: 0,
          child: _buildBookCover(
            imagePath: 'assets/images/petitprince.jpg',
            offset: 0,
          ),
        ),
        
        Positioned(
          left: 20,
          top: 20,
          child: _buildBookCover(
            imagePath: 'assets/images/leroisoleil.jpg',
            offset: 1,
          ),
        ),
        
        // Center book (most prominent)
        Positioned(
          child: _buildBookCover(
            imagePath: 'assets/images/olivertwist.jpg',
            offset: 2,
            isMain: true,
          ),
        ),
        
        // Right side books
        Positioned(
          right: 20,
          top: 10,
          child: _buildBookCover(
            imagePath: 'assets/images/lospazosdeulloa.jpg',
            offset: 3,
          ),
        ),
        
        Positioned(
          right: 0,
          top: 30,
          child: _buildBookCover(
            imagePath: 'assets/images/canasbarro.jpeg',
            offset: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBookCover({
    required String imagePath,
    required int offset,
    bool isMain = false,
  }) {
    final size = isMain ? 120.0 : 90.0;
    
    return Transform.rotate(
      angle: offset * 0.05, // Slight rotation for collage effect
      child: Container(
        width: size,
        height: size * 1.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            imagePath,
            width: size,
            height: size * 1.5,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to a colored container if image fails to load
              return Container(
                width: size,
                height: size * 1.5,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
