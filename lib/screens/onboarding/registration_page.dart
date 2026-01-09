import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../home_page.dart';

class RegistrationPage extends StatefulWidget {
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
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          // User successfully signed in
          if (mounted) {
            // First, ensure profile exists (in case trigger failed)
            _ensureProfileExists(session.user).then((_) {
              // Then update profile with language preferences
              return _updateProfileWithLanguages(session.user);
            }).then((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                widget.onComplete?.call();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            }).catchError((error) {
              // Log error but don't block navigation
              debugPrint('Error ensuring/updating profile: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                widget.onComplete?.call();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            });
          }
        }
      },
      onError: (error) {
        debugPrint('Auth state change error: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur d\'authentification: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

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
                    onTap: _isLoading ? null : () => _handleGoogleLogin(context),
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/apple.png'),
                    label: 'Apple',
                    onTap: _isLoading ? null : () => _handleSocialLogin(context, 'apple'),
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/facebook.png'),
                    label: 'Facebook',
                    onTap: _isLoading ? null : () => _handleSocialLogin(context, 'facebook'),
                    isLoading: _isLoading,
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
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                    ),
                  )
                else
                  icon,
                if (isLoading) const SizedBox(width: 16),
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

  Future<void> _handleGoogleLogin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Configure the redirect URL
      // For mobile apps, use a custom URL scheme
      // Make sure this URL is also configured in your Supabase dashboard
      // under Authentication > URL Configuration > Redirect URLs
      const redirectUrl = 'com.fluemingo.app://login-callback';
      
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Note: The auth state listener in initState will handle the callback
      // when the user returns from the OAuth flow
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(BuildContext context, String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Configure the redirect URL
      // For mobile apps, use a custom URL scheme
      // Make sure this URL is also configured in your Supabase dashboard
      // under Authentication > URL Configuration > Redirect URLs
      const redirectUrl = 'com.fluemingo.app://login-callback';
      
      // Map provider string to OAuthProvider enum
      OAuthProvider oauthProvider;
      switch (provider.toLowerCase()) {
        case 'facebook':
          oauthProvider = OAuthProvider.facebook;
          break;
        case 'apple':
          oauthProvider = OAuthProvider.apple;
          break;
        default:
          throw Exception('Provider non supporté: $provider');
      }
      
      await supabase.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Note: The auth state listener in initState will handle the callback
      // when the user returns from the OAuth flow
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la connexion $provider: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Ensures the user profile exists in the database
  /// This handles cases where the database trigger might have failed
  Future<void> _ensureProfileExists(User user) async {
    final supabase = Supabase.instance.client;
    
    try {
      // Check if profile exists
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      
      // If profile doesn't exist, create it
      if (response == null) {
        debugPrint('Profile does not exist, creating it...');
        
        // Extract user data from metadata (handles different OAuth providers)
        final metadata = user.userMetadata ?? {};
        final appMetadata = user.appMetadata ?? {};
        
        // Facebook uses different field names
        final fullName = metadata['full_name'] ?? 
                        metadata['name'] ?? 
                        metadata['user_name'] ??
                        '${metadata['first_name'] ?? ''} ${metadata['last_name'] ?? ''}'.trim() ??
                        user.email?.split('@').first ??
                        'User';
        
        final avatarUrl = metadata['avatar_url'] ?? 
                         metadata['picture'] ??
                         metadata['picture_url'] ??
                         null;
        
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email ?? user.phone,
          'full_name': fullName.isEmpty ? 'User' : fullName,
          'avatar_url': avatarUrl,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        debugPrint('Profile created successfully');
      }
    } catch (e) {
      debugPrint('Error ensuring profile exists: $e');
      // Don't rethrow - we'll try to update anyway
    }
  }

  /// Updates the user profile with language preferences from onboarding
  /// This is called after successful OAuth authentication
  Future<void> _updateProfileWithLanguages(User user) async {
    final supabase = Supabase.instance.client;
    
    try {
      // Update profile with language preferences
      // The profile should already exist (either from trigger or _ensureProfileExists)
      await supabase
          .from('profiles')
          .update({
            'target_language': widget.targetLanguage,
            'native_language': widget.nativeLanguage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      debugPrint('Error updating profile with languages: $e');
      // If update fails, try to create the profile with all data
      try {
        final metadata = user.userMetadata ?? {};
        final fullName = metadata['full_name'] ?? 
                        metadata['name'] ?? 
                        metadata['user_name'] ??
                        '${metadata['first_name'] ?? ''} ${metadata['last_name'] ?? ''}'.trim() ??
                        user.email?.split('@').first ??
                        'User';
        
        final avatarUrl = metadata['avatar_url'] ?? 
                         metadata['picture'] ??
                         metadata['picture_url'] ??
                         null;
        
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email ?? user.phone,
          'full_name': fullName.isEmpty ? 'User' : fullName,
          'avatar_url': avatarUrl,
          'target_language': widget.targetLanguage,
          'native_language': widget.nativeLanguage,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (insertError) {
        debugPrint('Error creating profile with languages: $insertError');
        // Don't rethrow - allow user to continue even if profile update fails
      }
    }
  }
}

