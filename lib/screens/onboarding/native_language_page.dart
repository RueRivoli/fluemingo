import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import 'avatar_selection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/languages.dart';
import '../../l10n/app_localizations.dart';
import '../../stores/profile_store.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Onboarding step index (1-based). Native language = step 3 of 7.
const int _onboardingTotalSteps = 7;
const int _nativeLanguageStep = 3;

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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languages = getReferenceLanguages(context);
    final progress = _nativeLanguageStep / _onboardingTotalSteps;

    return Scaffold(
      backgroundColor: AppColors.primary,
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
                    color: Colors.white,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                l10n.whichLanguageDoYouSpeakTheBest,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
                color: Colors.white.withOpacity(0.9),
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
                        child: _NativeLanguageOptionCard(
                          languageCode: lang['code']!,
                          name: lang['name']!,
                          onTap: () {
                            ProfileStoreScope.of(context)
                                .setUiLanguageOverride(lang['code']!);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AvatarSelectionPage(
                                  targetLanguage: widget.targetLanguage,
                                  nativeLanguage: lang['code']!,
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

/// Option card: rounded rect, lighter than primary, white text (for primary background).
class _NativeLanguageOptionCard extends StatelessWidget {
  final String languageCode;
  final String name;
  final VoidCallback onTap;

  const _NativeLanguageOptionCard({
    required this.languageCode,
    required this.name,
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
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                  color: Colors.white.withOpacity(0.9),
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
