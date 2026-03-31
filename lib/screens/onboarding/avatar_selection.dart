import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/avatar.dart';
import 'favorite_themes_selection.dart';

/// Onboarding step index (1-based). Avatar selection = step 4 of 7.
const int _onboardingTotalSteps = 7;
const int _avatarSelectionStep = 4;

const List<String> _avatarSeeds = <String>[
  'atlas',
  'nova',
  'rio',
  'sol',
  'alma',
  'onyx',
  'jade',
  'luna',
  'kai',
  'iris',
  'milo',
  'zara',
  'echo',
  'niko',
  'sora',
  'cleo',
  'pax',
  'leon',
];

class AvatarSelectionPage extends StatefulWidget {
  final String targetLanguage;
  final String nativeLanguage;
  final VoidCallback? onComplete;

  const AvatarSelectionPage({
    super.key,
    required this.targetLanguage,
    required this.nativeLanguage,
    this.onComplete,
  });

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  String? _selectedAvatarSeed;

  void _goToNextStep() {
    if (_selectedAvatarSeed == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteThemesSelectionPage(
          targetLanguage: widget.targetLanguage,
          nativeLanguage: widget.nativeLanguage,
          avatar: _selectedAvatarSeed!,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = _avatarSelectionStep / _onboardingTotalSteps;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Choose your avatar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectOne,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  itemCount: _avatarSeeds.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final seed = _avatarSeeds[index];
                    final isSelected = seed == _selectedAvatarSeed;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarSeed = seed),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              widthFactor: 0.65,
                              child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: SvgPicture.network(
                                    buildOpenPeepsAvatarUrl(seed),
                                    fit: BoxFit.contain,
                                    placeholderBuilder: (_) => const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                          const SizedBox(height: 6),
                          Text(
                            seed[0].toUpperCase() + seed.substring(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: GestureDetector(
                onTap: _selectedAvatarSeed == null ? null : _goToNextStep,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _selectedAvatarSeed == null
                        ? Colors.white.withOpacity(0.85)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textPrimary, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.lightArrowRight,
                        size: 22,
                        color: _selectedAvatarSeed == null
                            ? AppColors.textPrimary.withOpacity(0.5)
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.next,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _selectedAvatarSeed == null
                              ? AppColors.textPrimary.withOpacity(0.5)
                              : Colors.white,
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
