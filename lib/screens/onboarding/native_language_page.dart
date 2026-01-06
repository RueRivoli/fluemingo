import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import 'registration_page.dart';

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

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'nl', 'name': 'Nederlands'},
  ];

  String _getLanguageIconPath(String code) {
    switch (code) {
      case 'en':
        return 'assets/images/languages/english.svg';
      case 'fr':
        return 'assets/images/languages/french.svg';
      case 'es':
        return 'assets/images/languages/spanish.svg';
      case 'de':
        return 'assets/images/languages/german.svg';
      case 'ja':
        return 'assets/images/languages/japanese.svg';
      case 'nl':
        return 'assets/images/languages/dutch.svg';
      case 'it':
        return 'assets/images/languages/italian.svg';
      default:
        return 'assets/images/languages/english.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Which language do you speak ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This language will be your language of reference',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Language options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: _languages.map((lang) {
                      final isSelected = _selectedLanguage == lang['code'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLanguageOption(
                          code: lang['code']!,
                          name: lang['name']!,
                          isSelected: isSelected,
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
                            builder: (context) => RegistrationPage(
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
                        Icons.play_arrow,
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

  Widget _buildLanguageOption({
    required String code,
    required String name,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Language icon circle
              Container(
                width: 36,
                height: 36,
                child: Center(
                  child: SvgPicture.asset(
                    _getLanguageIconPath(code),
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Container(
                        width: 24,
                        height: 24,
                        color: Colors.grey[300],
                        child: Icon(Icons.language, size: 16, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

