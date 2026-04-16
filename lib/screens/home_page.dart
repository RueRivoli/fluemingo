import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'library_page.dart';
import 'audiobooks_page.dart';
import 'flashcards_page.dart';
import 'profile_page.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/profile_service.dart';
import '../services/notification_token_sync_service.dart';
import '../services/onesignal_notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final ProfileService _profileService =
      ProfileService(Supabase.instance.client);
  late final NotificationTokenSyncService _notificationTokenSyncService =
      NotificationTokenSyncService(_profileService);
  late final OneSignalNotificationService _oneSignalNotificationService =
      OneSignalNotificationService(_profileService);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;

    try {
      await _oneSignalNotificationService.initialize();
      if (user != null) {
        await _oneSignalNotificationService.loginWithSupabaseUserId(user.id);
      }
      await _oneSignalNotificationService.requestPermission();
      await _oneSignalNotificationService.syncSubscriptionIdToProfile();
    } catch (e) {
      debugPrint('OneSignal notification setup failed: $e');
    }
    try {
      // Backward-compatible fallback for older locally stored token keys.
      await _notificationTokenSyncService.syncIfAvailable();
    } catch (e) {
      debugPrint('Fallback notification token sync failed: $e');
    }
  }

  List<Widget> get _pages => [
        LibraryPage(isVisible: _currentIndex == 0),
        AudiobooksPage(isVisible: _currentIndex == 1),
        FlashcardsPage(
          key: const ValueKey('flashcards'),
          isVisible: _currentIndex == 2,
        ),
        ProfilePage(isVisible: _currentIndex == 3),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 12 : 8,
            ),
            child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(FontAwesomeIcons.fileLines, 0,
                    AppLocalizations.of(context)!.navLibrary),
                _buildNavItem(FontAwesomeIcons.headphones, 1,
                    AppLocalizations.of(context)!.navAudiobooks),
                _buildNavItem(FontAwesomeIcons.cardsBlank, 2,
                    AppLocalizations.of(context)!.navFlashcards),
                _buildNavItem(FontAwesomeIcons.user, 3,
                    AppLocalizations.of(context)!.navProfile),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.secondary : Colors.white70,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.secondary : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
