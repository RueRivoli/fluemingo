import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import 'target_language_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback? onComplete;

  const WelcomePage({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.marketingColor,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer at top
            const SizedBox(height: 60),

            // App Logo & Title
            Image.asset('assets/logo/app-logo.png', height: 48),
            const SizedBox(height: 12),
            const Text(
              'Fluemingo',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                    color: Colors.white,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: AppLocalizations.of(context)!.learn),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SizedBox(width: 10),
                    ),
                    // WidgetSpan(
                    //   alignment: PlaceholderAlignment.middle,
                    //   child: SvgPicture.asset('assets/images/languages/english.svg', height: 24),
                    // ),
                    // const WidgetSpan(
                    //   alignment: PlaceholderAlignment.middle,
                    //   child: SizedBox(width: 4),
                    // ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SvgPicture.asset(
                          'assets/images/languages/french.svg',
                          height: 24),
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SizedBox(width: 10),
                    ),
                    TextSpan(text: AppLocalizations.of(context)!.withContent),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SizedBox(width: 5),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.fitTasteLevel,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Book covers showcase
            Expanded(
              child: Column(
                children: [
                  // Label above books
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Book covers collage
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFrenchContentRow(),
                    ),
                  ),
                ],
              ),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
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
                        color: const Color(0xFFf6d75a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.lightArrowRight,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.start,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrenchContentRow() {
    const imagePaths = [
      'assets/img/french/leroisoleil.jpg',
      'assets/img/french/lesmiserables.jpg',
      'assets/img/french/tour-du-monde.jpg',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < imagePaths.length; i++) ...[
          Expanded(child: _buildContentCard(imagePaths[i])),
          if (i < imagePaths.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _buildContentCard(String imagePath) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
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
