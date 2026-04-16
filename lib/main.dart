import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';
import 'screens/onboarding/registration_page.dart';
import 'screens/onboarding/welcome_page.dart';
import 'constants/app_colors.dart';
import 'config/supabase_config.dart';
import 'config/revenue_cat_config.dart';
import 'stores/profile_store.dart';
import 'services/profile_service.dart';
import 'services/week_progress_service.dart';
import 'l10n/app_localizations.dart';
import 'services/app_review_service.dart';
import 'widgets/animated_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.hasSupabaseConfig) {
    runApp(const _ConfigurationErrorApp());
    return;
  }

  // Initialize RevenueCat (no-op on non-iOS/Android)
  await initializeRevenueCat();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabasePublishableKey,
  );

  final profileService = ProfileService(Supabase.instance.client);
  final weekProgressService = WeekProgressService(Supabase.instance.client);
  final profileStore = ProfileStore(profileService, weekProgressService);

  runApp(ProfileStoreScope(
    profileStore: profileStore,
    child: const MyApp(),
  ));
}

/// Maps profile native language code (backend) to a supported [Locale], or null to use system.
Locale? _localeFromLanguageCode(String? languageCode) {
  if (languageCode == null || languageCode.isEmpty) return null;
  const supported = {'en', 'fr', 'es', 'de', 'nl', 'it', 'pt', 'ja'};
  final code = languageCode;
  if (supported.contains(code)) return Locale(code);
  return null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileStore = ProfileStoreScope.of(context);
    final locale = _localeFromLanguageCode(profileStore.uiLanguageCode);

    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.wixMadeforTextTextTheme(),
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  _AppLaunchDestination _destination = _AppLaunchDestination.welcome;
  bool _hasInitialized = false;
  late final ProfileStore _profileStore;

  // Mode debug : mettre à true pour forcer l'affichage de l'onboarding
  static const bool _forceOnboarding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitialized) return;

    _hasInitialized = true;
    _profileStore = ProfileStoreScope.of(context);
    _checkAuthAndOnboarding();
  }

  Future<void> _checkAuthAndOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // En mode debug avec _forceOnboarding, réinitialiser les préférences
    if (kDebugMode && _forceOnboarding) {
      await prefs.remove('has_seen_welcome');
    }

    var hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

    // Vérifier l'état d'authentification Supabase
    final supabase = Supabase.instance.client;
    var session = supabase.auth.currentSession;
    var isAuthenticated = session != null;
    late final _AppLaunchDestination destination;

    if (isAuthenticated) {
      await _profileStore.load();

      // Safety net: if the authenticated user has an incomplete profile (e.g.
      // crashed mid-onboarding, half-written upsert, legacy broken row), sign
      // them out and funnel through onboarding instead of into the main app.
      if (!kDebugMode || !_forceOnboarding) {
        if (!_isProfileComplete(_profileStore)) {
          await supabase.auth.signOut();
          _profileStore.clear();
          await prefs.setBool('has_seen_welcome', false);
          session = null;
          isAuthenticated = false;
          hasSeenWelcome = false;
        }
      }
    }

    if (kDebugMode && _forceOnboarding) {
      destination = _AppLaunchDestination.welcome;
    } else if (isAuthenticated) {
      destination = _AppLaunchDestination.home;
    } else if (hasSeenWelcome) {
      destination = _AppLaunchDestination.registration;
    } else {
      destination = _AppLaunchDestination.welcome;
    }

    if (!mounted) return;
    setState(() {
      _destination = destination;
      _isLoading = false;
    });
  }

  bool _isProfileComplete(ProfileStore store) {
    // If the profile load itself failed (network, etc.), don't interpret that
    // as "incomplete" — that would sign the user out on transient errors.
    if (store.loadError != null) return true;
    final profile = store.profile;
    if (profile == null) return false;
    return profile.targetLanguage.trim().isNotEmpty &&
        profile.nativeLanguage.trim().isNotEmpty &&
        profile.weeklyGoalXP != null;
  }

  Future<void> _onWelcomeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);

    if (mounted) {
      setState(() {
        _destination = _AppLaunchDestination.home;
      });
      AppReviewService.instance.requestReviewIfAppropriate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AnimatedSplash();
    }

    switch (_destination) {
      case _AppLaunchDestination.welcome:
        return WelcomePage(onComplete: _onWelcomeComplete);
      case _AppLaunchDestination.registration:
        return const RegistrationPage.loginOnly();
      case _AppLaunchDestination.home:
        return const ProfileLoader(child: HomePage());
    }
  }
}

enum _AppLaunchDestination { welcome, registration, home }

class _ConfigurationErrorApp extends StatelessWidget {
  const _ConfigurationErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 12),
                Text(
                  'Configuration manquante',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text(
                  'SUPABASE_URL ou SB_PUBLISHABLE_KEY est vide. '
                  'Relancez l’app avec vos dart-defines.',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                SizedBox(height: 16),
                SelectableText(
                  'flutter run --dart-define-from-file=.env',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
