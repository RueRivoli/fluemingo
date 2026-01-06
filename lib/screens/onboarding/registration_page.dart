import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../home_page.dart';

class RegistrationPage extends StatelessWidget {
  final String targetLanguage;
  final String nativeLanguage;
  final VoidCallback? onComplete;

  const RegistrationPage({
    super.key,
    required this.targetLanguage,
    required this.nativeLanguage,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Connexion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Social login buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/google.jpg'),
                    label: 'Google',
                    onTap: () => _handleSocialLogin(context, 'google'),
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/apple.png'),
                    label: 'Apple',
                    onTap: () => _handleSocialLogin(context, 'apple'),
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/facebook.png'),
                    label: 'Facebook',
                    onTap: () => _handleSocialLogin(context, 'facebook'),
                  ),
                ],
              ),
            ),

            // Flamingo illustration
            Expanded(
              child: Center(
                child: _buildFlamingoIllustration(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildLogoIcon(String assetPath) {
    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 24,
          height: 24,
          color: Colors.grey[300],
        );
      },
    );
  }

  Widget _buildFlamingoIllustration() {
    return Image.asset(
      'assets/logo/flamingo.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 280,
          color: Colors.grey[300],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  void _handleSocialLogin(BuildContext context, String provider) {
    // TODO: Implement actual social login
    // For now, just complete the onboarding
    onComplete?.call();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }
}

