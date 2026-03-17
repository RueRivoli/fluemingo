import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import 'native_language_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/languages.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Onboarding step index (1-based). Target language = step 2 of 7.
const int _onboardingTotalSteps = 7;
const int _targetLanguageStep = 2;

class TargetLanguagePage extends StatefulWidget {
  final VoidCallback? onComplete;

  const TargetLanguagePage({super.key, this.onComplete});

  @override
  State<TargetLanguagePage> createState() => _TargetLanguagePageState();
}

class _TargetLanguagePageState extends State<TargetLanguagePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languages = getTargetLanguages(context);
    final progress = _targetLanguageStep / _onboardingTotalSteps;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back button + progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FontAwesomeIcons.leftLong),
                    color: AppColors.textPrimary,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title (rounded, bold sans-serif like the goals screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.whichLanguageDoYouWantToLearn,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              l10n.selectOne,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary.withOpacity(0.85),
              ),
            ),

            const SizedBox(height: 28),

            // Language options (screenshot-style: rounded cards, lighter than background)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: languages.map((lang) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _GoalStyleOptionCard(
                          languageCode: lang['code']!,
                          name: lang['name']!,
                          isSelected: false,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NativeLanguagePage(
                                  targetLanguage: lang['code']!,
                                  onComplete: widget.onComplete,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Option card styled like the screenshot: rounded rect, lighter fill, left-aligned text (+ optional icon).
class _GoalStyleOptionCard extends StatelessWidget {
  final String languageCode;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalStyleOptionCard({
    required this.languageCode,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                getLanguageIconPath(languageCode),
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  FontAwesomeIcons.language,
                  size: 20,
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
