import 'dart:async';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../config/supabase_config.dart';
import '../home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../services/profile_service.dart';
import '../../services/notification_token_sync_service.dart';
import '../../services/onesignal_notification_service.dart';
import '../../stores/profile_store.dart';
import '../../utils/avatar.dart';
import 'welcome_page.dart';

enum RegistrationFlowMode { onboarding, loginOnly }

class RegistrationPage extends StatefulWidget {
  final RegistrationFlowMode flowMode;
  final String? targetLanguage;
  final String? nativeLanguage;
  final String? avatar;
  final List<String>? favoriteThemes;
  final int? weeklyGoalXP;
  final VoidCallback? onComplete;

  const RegistrationPage.onboarding({
    super.key,
    required String this.targetLanguage,
    required String this.nativeLanguage,
    this.avatar,
    this.favoriteThemes,
    this.weeklyGoalXP,
    this.onComplete,
  }) : flowMode = RegistrationFlowMode.onboarding;

  const RegistrationPage.loginOnly({
    super.key,
    this.onComplete,
  })  : flowMode = RegistrationFlowMode.loginOnly,
        targetLanguage = null,
        nativeLanguage = null,
        avatar = null,
        favoriteThemes = null,
        weeklyGoalXP = null;

  bool get isLoginOnly => flowMode == RegistrationFlowMode.loginOnly;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _isLoadingApple = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingEmail = false;
  bool _obscurePassword = true;
  StreamSubscription<AuthState>? _authSubscription;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final ProfileService _profileService =
      ProfileService(Supabase.instance.client);
  late final NotificationTokenSyncService _notificationTokenSyncService =
      NotificationTokenSyncService(_profileService);
  late final OneSignalNotificationService _oneSignalNotificationService =
      OneSignalNotificationService(_profileService);

  String? get _selectedAvatar {
    final value = widget.avatar?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get _selectedAvatarUrl {
    final avatar = _selectedAvatar;
    if (avatar == null) return null;
    return buildOpenPeepsAvatarUrl(avatar);
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          if (mounted) {
            _handleSignedIn(data.session!.user);
          }
        }
      },
      onError: (error) {
        debugPrint('Auth state change error: $error');
        if (mounted) {
          setState(() {
            _resetLoadingStates();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authenticationError),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleSignedIn(User user) async {
    try {
      await _upsertProfileFromOnboarding(user);

      // Fresh social signup on the login screen yields an incomplete profile.
      // Send those users through onboarding instead of into the main app.
      if (widget.isLoginOnly) {
        final complete = await _profileService.isProfileComplete();
        if (!complete) {
          await _redirectToOnboarding();
          return;
        }
      }

      await _oneSignalNotificationService.initialize();
      await _oneSignalNotificationService.loginWithSupabaseUserId(user.id);
      await _oneSignalNotificationService.requestPermission();
      await _oneSignalNotificationService.syncSubscriptionIdToProfile();
      await _notificationTokenSyncService.syncIfAvailable();

      // Populate ProfileStore before HomePage renders so premium-gated UI
      // (locker icons, paywalls) reflects the real subscription state from
      // the first frame instead of briefly flashing as free-tier.
      if (!mounted) return;
      try {
        await ProfileStoreScope.of(context).load();
      } catch (e) {
        debugPrint('Profile preload before HomePage navigation failed: $e');
      }

      if (!mounted) return;
      setState(() {
        _resetLoadingStates();
      });
      widget.onComplete?.call();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ProfileLoader(child: HomePage()),
        ),
        (route) => false,
      );
    } catch (error) {
      debugPrint('Error during signed-in flow: $error');
      if (!mounted) return;
      setState(() {
        _resetLoadingStates();
      });
      // Onboarding mode: profile write may have failed. Keep the user on this
      // screen so they can retry instead of landing in HomePage with a broken
      // profile. loginOnly mode also surfaces the error without navigating.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authenticationError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetLoadingStates() {
    _isLoadingApple = false;
    _isLoadingGoogle = false;
    _isLoadingEmail = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
            children: [
              const SizedBox(height: 36),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  AppLocalizations.of(context)!.connexion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE6E6EF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.signIn,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.enterEmailAndPassword,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.email,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) {
                              if (!_isLoadingEmail) {
                                _handleEmailLogin(context);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isLoadingEmail
                                  ? null
                                  : () => _handleEmailLogin(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoadingEmail
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.signInWithEmail,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDividerLabel(),
                    const SizedBox(height: 24),

                    // Social login buttons (Google & Apple: light style; Facebook: official blue)
                    _buildGoogleLightButton(
                      onTap: _isLoadingGoogle
                          ? null
                          : () => _handleGoogleLogin(context),
                      isLoading: _isLoadingGoogle,
                    ),
                    const SizedBox(height: 16),
                    _buildAppleButton(
                      onTap: _isLoadingApple
                          ? null
                          : () => _handleAppleLogin(context),
                      isLoading: _isLoadingApple,
                    ),
                    const SizedBox(height: 24),
                    _buildTermsAndPrivacy(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  static const Color _googleBorder = Color(0xFFDADCE0);
  static const Color _googleText = Color(0xFF3C4043);
  static const double _socialButtonHeight = 56;

  /// Google branded light button: white background, subtle border and Google "G" logo.
  Widget _buildGoogleLightButton({
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Container(
            width: double.infinity,
            height: _socialButtonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _googleBorder),
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
                        valueColor: AlwaysStoppedAnimation<Color>(_googleText),
                      ),
                    )
                  else
                    SvgPicture.asset(
                      'assets/logo/google.svg',
                      width: 18,
                      height: 18,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.continueWithGoogle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _googleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton({
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: SizedBox(
            width: double.infinity,
            height: _socialButtonHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(
                      FontAwesomeIcons.apple,
                      size: 20,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.continueWithApple,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerLabel() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE0E0E8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppLocalizations.of(context)!.orContinueWith,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE0E0E8))),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    final l10n = AppLocalizations.of(context)!;
    final fullText = l10n.termsAndPrivacyNotice;
    final termsLabel = l10n.termsOfService;
    final privacyLabel = l10n.privacyPolicy;

    final baseStyle = TextStyle(fontSize: 12, color: AppColors.textSecondary);
    final linkStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textSecondary,
      decoration: TextDecoration.underline,
    );

    final termsIndex = fullText.indexOf(termsLabel);
    final privacyIndex = fullText.indexOf(privacyLabel);

    // Fallback to plain text if localized substrings aren't found
    if (termsIndex < 0 || privacyIndex < 0) {
      return Text(fullText, textAlign: TextAlign.center, style: baseStyle);
    }

    // Build spans in text order
    final first = termsIndex < privacyIndex
        ? (label: termsLabel, url: 'https://fluemingo-app.com/terms')
        : (label: privacyLabel, url: 'https://fluemingo-app.com/privacy-policy');
    final second = termsIndex < privacyIndex
        ? (label: privacyLabel, url: 'https://fluemingo-app.com/privacy-policy')
        : (label: termsLabel, url: 'https://fluemingo-app.com/terms');

    final firstIndex = termsIndex < privacyIndex ? termsIndex : privacyIndex;
    final secondIndex = termsIndex < privacyIndex ? privacyIndex : termsIndex;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: fullText.substring(0, firstIndex)),
          TextSpan(
            text: first.label,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(Uri.parse(first.url)),
          ),
          TextSpan(
              text: fullText.substring(
                  firstIndex + first.label.length, secondIndex)),
          TextSpan(
            text: second.label,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(Uri.parse(second.url)),
          ),
          TextSpan(
              text: fullText.substring(secondIndex + second.label.length)),
        ],
      ),
    );
  }

  Future<void> _handleEmailLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterEmailAndPassword),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingEmail = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.signInFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    setState(() {
      _isLoadingGoogle = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Web: use Supabase OAuth redirect (no native Google Sign-In on web).
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(OAuthProvider.google);
        return; // Page redirects to Google and back; auth state listener handles success.
      }

      // Mobile (iOS/Android): native Google Sign-In. iOS clientId in Info.plist (GIDClientID).
      final googleSignIn = GoogleSignIn.instance;
      final serverClientId = SupabaseConfig.googleWebClientId.trim().isEmpty
          ? null
          : SupabaseConfig.googleWebClientId.trim();
      final iosClientId = SupabaseConfig.iosClientId.trim().isEmpty
          ? null
          : SupabaseConfig.iosClientId.trim();
      await googleSignIn.initialize(
        serverClientId: serverClientId,
        clientId: iosClientId,
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

        final l10n = AppLocalizations.of(context)!;
        final message = e.toString().contains('No host specified in URI')
            ? l10n.supabaseConfigMissing
            : l10n.signInFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
      if (defaultTargetPlatform == TargetPlatform.android ||
          !await SignInWithApple.isAvailable()) {
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
        fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
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
              await _profileService.updateFullName(fullName);
            } catch (e) {
              // If update fails, try to insert (profile might not exist yet)
              debugPrint(
                  'Profile update failed, will be created by listener: $e');
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
            content: Text(AppLocalizations.of(context)!.signInFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Writes the profile row atomically with whatever onboarding data is
  /// available. In loginOnly mode only basic identity fields are written so
  /// existing language/goal settings are preserved.
  Future<void> _upsertProfileFromOnboarding(User user) async {
    final metadata = user.userMetadata ?? {};
    final nameFromMetadata =
        metadata['full_name'] ?? metadata['name'] ?? metadata['user_name'];
    final firstName = metadata['first_name'] ?? '';
    final lastName = metadata['last_name'] ?? '';
    final nameFromParts = '$firstName $lastName'.trim();
    final fullNameRaw = nameFromMetadata ??
        (nameFromParts.isNotEmpty ? nameFromParts : null) ??
        user.email?.split('@').first ??
        'User';
    final fullName =
        fullNameRaw is String && fullNameRaw.isEmpty ? 'User' : fullNameRaw;
    final metadataAvatarUrl = metadata['avatar_url'] ??
        metadata['picture'] ??
        metadata['picture_url'];

    final data = <String, dynamic>{
      'id': user.id,
      'email': user.email ?? user.phone,
      'full_name': fullName,
      'avatar': _selectedAvatar,
      'avatar_url': _selectedAvatarUrl ?? metadataAvatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (!widget.isLoginOnly) {
      if (widget.targetLanguage != null) {
        data['target_language'] = widget.targetLanguage;
      }
      if (widget.nativeLanguage != null) {
        data['native_language'] = widget.nativeLanguage;
      }
      if (widget.weeklyGoalXP != null) {
        data['weekly_goal'] = widget.weeklyGoalXP;
      }
      if (widget.favoriteThemes != null && widget.favoriteThemes!.isNotEmpty) {
        final themes = widget.favoriteThemes!.take(5).toList();
        for (var i = 0; i < 5; i++) {
          data['theme_interest_${i + 1}'] =
              i < themes.length ? themes[i] : null;
        }
      }
    }

    await _profileService.upsertProfile(data);
  }

  /// Bail out of a loginOnly session that turned out to be a fresh signup:
  /// sign out, reset has_seen_welcome, and push the welcome flow.
  Future<void> _redirectToOnboarding() async {
    try {
      await _oneSignalNotificationService.logout();
    } catch (e) {
      debugPrint('OneSignal logout during redirect failed: $e');
    }
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut during redirect failed: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', false);

    if (!mounted) return;
    ProfileStoreScope.of(context).clear();
    setState(() {
      _resetLoadingStates();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.incompleteAccountSetup),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }
}
