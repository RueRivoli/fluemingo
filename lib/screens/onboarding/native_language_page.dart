import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/language_option_card.dart';
import 'favorite_themes_selection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/languages.dart';

class NativeLanguagePage extends StatefulWidget {
  final String targetLanguage;
  final VoidCallback? onComplete;

  const NativeLanguagePage({
    super.key,
    required this.targetLanguage,
    this.onComplete,
  });

  @override
  State<NativeLanguagePage> createState() => _NativeLanguagePageState();
}

class _NativeLanguagePageState extends State<NativeLanguagePage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final languages = getReferenceLanguages(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Which language do you speak best ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Language options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: languages.map((lang) {
                      final isSelected = _selectedLanguage == lang['code'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LanguageOptionCard(
                          code: lang['code']!,
                          name: lang['name']!,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedLanguage = lang['code']),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: GestureDetector(
                onTap: _selectedLanguage != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FavoriteThemesSelectionPage(
                              targetLanguage: widget.targetLanguage,
                              nativeLanguage: _selectedLanguage!,
                              onComplete: widget.onComplete,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      _selectedLanguage != null ? 1.0 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.arrowRight,
                        size: 22,
                        color: _selectedLanguage != null
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _selectedLanguage != null
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withOpacity(0.5),
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

}

