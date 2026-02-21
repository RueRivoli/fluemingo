import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/profile.dart';
import '../widgets/article_card.dart';
import '../widgets/audiobook_card.dart';
import '../services/week_progress_service.dart';
import '../models/week_progress.dart';
import '../widgets/content_category.dart';
import '../models/content_category.dart' show ContentMenu;

class ProfileTopBar extends StatefulWidget {
  final bool isVisible;
  final Profile profile;

  const ProfileTopBar({super.key, this.isVisible = true, this.profile = null, this.category = null});

  @override
  State<ProfileTopBar> createState() => _ProfileTopBarState();
}


class _ProfileTopBarState extends State<ProfileTopBar> {
  late final ProfileService profileService =
      ProfileService(Supabase.instance.client);
  late final WeekProgressService weekProgressService =
      WeekProgressService(Supabase.instance.client);
  Profile? profile;
  bool isLoading = true;
  WeekProgress? _weekProgress;
  ContentMenu _selectedMenu = ContentMenu.inProgress;

  @override
  void initState() {
    super.initState();
  }


  /// Avatar URL from OAuth (profile or auth metadata).
  String? get _avatarUrl {
    final fromProfile = widget.profile?.avatarUrl;
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    if (metadata == null) return null;
    return metadata['avatar_url'] ?? metadata['picture'] ?? metadata['picture_url'];
  }

  /// Initials from full name (e.g. "John Doe" -> "JD").
  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }


  Widget _buildAvatar() {
    const double radius = 28;
    final url = _avatarUrl;
    final fullName = profile?.fullName ?? Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? '';
    final initials = fullName.isNotEmpty ? _initials(fullName) : '?';

    final initialsAvatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.neutral,
        child: ClipOval(
          child: Image.network(
            url,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => initialsAvatar,
          ),
        ),
      );
    }
    return initialsAvatar;
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header: avatar + week progress + settings icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildWeekProgress()),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Material(
                      color: AppColors.neutral,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          // TODO: Navigate to profile settings
                        },
                        customBorder: const CircleBorder(),
                        child: Icon(
                          Icons.settings_outlined,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
