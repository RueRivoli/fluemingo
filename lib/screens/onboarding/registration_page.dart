import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../constants/app_colors.dart';
import '../../config/supabase_config.dart';
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
  bool _isLoadingApple = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingFacebook = false;
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
                  _isLoadingFacebook = false;
                  _isLoadingApple = false;
                  _isLoadingGoogle = false;
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
                  _isLoadingFacebook = false;
                  _isLoadingApple = false;
                  _isLoadingGoogle = false;
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
            _isLoadingFacebook = false;
            _isLoadingApple = false;
            _isLoadingGoogle = false;
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
                    onTap: _isLoadingGoogle ? null : () => _handleGoogleLogin(context),
                    isLoading: _isLoadingGoogle,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/apple.png'),
                    label: 'Apple',
                    onTap: _isLoadingApple ? null : () => _handleAppleLogin(context),
                    isLoading: _isLoadingApple,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context: context,
                    icon: _buildLogoIcon('assets/logo/facebook.png'),
                    label: 'Facebook',
                    onTap: _isLoadingFacebook ? null : () => _handleFacebookLogin(context),
                    isLoading: _isLoadingFacebook,
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
      _isLoadingGoogle = true;
    });

    try {
      final supabase = Supabase.instance.client;
    
      // The iOS clientId is configured in Info.plist (GIDClientID)
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
          serverClientId: SupabaseConfig.googleWebClientId,
          clientId: SupabaseConfig.iosClientId
        );
      
      // Sign in with Google using the new authenticate() method
      final GoogleSignInAccount googleUser;
      try {
        googleUser = await googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        // User cancelled or other sign-in issue
        if (e.code == GoogleSignInExceptionCode.canceled) {
          if (mounted) {
            setState(() {
              _isLoadingGoogle = false;
            });
          }
          return;
        }
        rethrow;
      }
      
      // Obtain the auth details from the account
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Extract ID token (accessToken is no longer available in v7+)
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Impossible d\'obtenir le token ID de Google');
      }
      
      // Sign in to Supabase with the Google ID token
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
      // The auth state listener in initState will handle the callback
      // and profile creation/update
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGoogle = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la connexion Google: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleLogin(BuildContext context) async {
    setState(() {
      _isLoadingApple = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // On Android, use OAuth flow directly (native Apple Sign In requires webAuthenticationOptions)
      // On iOS, check if native Apple Sign In is available
      if (defaultTargetPlatform == TargetPlatform.android || !await SignInWithApple.isAvailable()) {
        // Fallback to OAuth flow if native Apple Sign In is not available or on Android
        const redirectUrl = 'com.fluemingo.app://login-callback';
        await supabase.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: redirectUrl,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
        return;
      }
      
      // Use native Apple Sign In (iOS only)
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Extract full name if available (only on first sign-in)
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
        if (fullName.isEmpty) {
          fullName = null;
        }
      }
      
      // Sign in to Supabase with the Apple ID token
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );
      
      // Update profile with full name if available
      // Note: fullName is only provided on first sign-in with Apple
      if (fullName != null) {
        try {
          final currentUser = supabase.auth.currentUser;
          if (currentUser != null) {
            // Store fullName in the profile
            // The auth state listener will also call _ensureProfileExists,
            // but we update it here to ensure the fullName is saved
            try {
              // Try to update existing profile
              await supabase.from('profiles').update({
                'full_name': fullName,
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('id', currentUser.id);
            } catch (e) {
              // If update fails, try to insert (profile might not exist yet)
              debugPrint('Profile update failed, will be created by listener: $e');
            }
          }
        } catch (e) {
          debugPrint('Error updating profile with fullName: $e');
          // Continue anyway - _ensureProfileExists will handle it
        }
      }
      
      // The auth state listener in initState will handle the callback
      // and profile creation/update
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApple = false;
        });
        
        // Handle user cancellation gracefully
        if (e is SignInWithAppleAuthorizationException) {
          if (e.code == AuthorizationErrorCode.canceled) {
            return; // User canceled, don't show error
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la connexion Apple: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleFacebookLogin(BuildContext context) async {
    setState(() {
      _isLoadingFacebook = true;
    });

    try {
      final supabase = Supabase.instance.client;
      const redirectUrl = 'com.fluemingo.app://login-callback';
        await supabase.auth.signInWithOAuth(
          OAuthProvider.facebook,
          redirectTo: redirectUrl,
          authScreenLaunchMode: LaunchMode.inAppBrowserView,
        );
        
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFacebook = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la connexion Facebook: ${e.toString()}'),
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
        
        // Facebook uses different field names
        final nameFromMetadata = metadata['full_name'] ?? 
                                 metadata['name'] ?? 
                                 metadata['user_name'];
        final firstName = metadata['first_name'] ?? '';
        final lastName = metadata['last_name'] ?? '';
        final nameFromParts = '$firstName $lastName'.trim();
        final fullName = nameFromMetadata ?? 
                        (nameFromParts.isNotEmpty ? nameFromParts : null) ??
                        user.email?.split('@').first ??
                        'User';
        
        final avatarUrl = metadata['avatar_url'] ?? 
                         metadata['picture'] ??
                         metadata['picture_url'];
        
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
        final nameFromMetadata = metadata['full_name'] ?? 
                                 metadata['name'] ?? 
                                 metadata['user_name'];
        final firstName = metadata['first_name'] ?? '';
        final lastName = metadata['last_name'] ?? '';
        final nameFromParts = '$firstName $lastName'.trim();
        final fullName = nameFromMetadata ?? 
                        (nameFromParts.isNotEmpty ? nameFromParts : null) ??
                        user.email?.split('@').first ??
                        'User';
        
        final avatarUrl = metadata['avatar_url'] ?? 
                         metadata['picture'] ??
                         metadata['picture_url'];
        
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

