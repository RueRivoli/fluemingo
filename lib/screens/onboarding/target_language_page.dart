import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/language_option_card.dart';
import 'native_language_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/languages.dart';

class TargetLanguagePage extends StatefulWidget {
  final VoidCallback? onComplete;

  const TargetLanguagePage({super.key, this.onComplete});

  @override
  State<TargetLanguagePage> createState() => _TargetLanguagePageState();
}

class _TargetLanguagePageState extends State<TargetLanguagePage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final languages = getTargetLanguages(context);
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Which language do you want to learn ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Language options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: languages.map((lang) {
                    final isSelected = _selectedLanguage == lang['code'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: GestureDetector(
                onTap: _selectedLanguage != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NativeLanguagePage(
                              targetLanguage: _selectedLanguage!,
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

