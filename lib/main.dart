import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';
import 'screens/welcome_page.dart';
import 'constants/app_colors.dart';
import 'config/supabase_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluemingo',
      debugShowCheckedModeBanner: false,
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
  bool _isFirstTime = true;
  
  // Mode debug : mettre à true pour forcer l'affichage de l'onboarding
  static const bool _forceOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndOnboarding();
  }

  Future<void> _checkAuthAndOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    
    // En mode debug avec _forceOnboarding, réinitialiser les préférences
    if (kDebugMode && _forceOnboarding) {
      await prefs.remove('has_seen_welcome');
      debugPrint('🔄 Debug mode: Reset has_seen_welcome');
    }
    
    final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;
    
    // Vérifier l'état d'authentification Supabase
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final isAuthenticated = session != null;
    
    debugPrint('📱 Auth check - hasSeenWelcome: $hasSeenWelcome, isAuthenticated: $isAuthenticated, session: ${session?.user.email}');
    
    // Afficher l'onboarding si:
    // 1. L'utilisateur n'a jamais vu le welcome, OU
    // 2. L'utilisateur n'est pas authentifié (même s'il a vu le welcome), OU
    // 3. En mode debug avec _forceOnboarding activé
    final shouldShowOnboarding = !hasSeenWelcome || 
        !isAuthenticated ||
        (kDebugMode && _forceOnboarding);
    
    debugPrint('📱 shouldShowOnboarding: $shouldShowOnboarding');
    
    setState(() {
      _isFirstTime = shouldShowOnboarding;
      _isLoading = false;
    });
  }

  Future<void> _onWelcomeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);
    
    if (mounted) {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isFirstTime) {
      return WelcomePage(onComplete: _onWelcomeComplete);
    }

    return const HomePage();
  }
}
