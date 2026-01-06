import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import 'native_language_page.dart';

class TargetLanguagePage extends StatefulWidget {
  final VoidCallback? onComplete;

  const TargetLanguagePage({super.key, this.onComplete});

  @override
  State<TargetLanguagePage> createState() => _TargetLanguagePageState();
}

class _TargetLanguagePageState extends State<TargetLanguagePage> {
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'es', 'name': 'Spanish'},
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
                  children: _languages.map((lang) {
                    final isSelected = _selectedLanguage == lang['code'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
                    color: _selectedLanguage != null
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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

