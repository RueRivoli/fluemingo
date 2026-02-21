import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Reusable badge showing content progress: "Not Started", "In Progress", "Finished".
/// Use on top of cover images (e.g. article overview, library cards, audiobook cards).
class ContentStatusBadge extends StatelessWidget {
  /// Reading status from API: null / '' = not started, 'started' = in progress, 'finished' = finished.
  final String? status;

  /// When true, uses smaller padding and font (e.g. for cards). Default false for overview.
  final bool compact;

  /// When true, shows an icon to the right of the status that opens a menu to change status.
  final bool showStatusMenu;

  /// When true, only the status (icon + label) is shown in one box. Use with a separate menu box.
  final bool showOnlyStatus;

  /// When true, only the menu trigger icon is shown in one box. Requires [onStatusChange].
  final bool showOnlyMenu;

  /// Called when the user picks a new status from the menu. API values: 'not_started', 'started', 'finished'.
  final void Function(String newStatus)? onStatusChange;

  const ContentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.showStatusMenu = false,
    this.showOnlyStatus = false,
    this.showOnlyMenu = false,
    this.onStatusChange,
  });

  static const Color _orange = Color(0xFFE67E22);

  String get _label {
    final s = status?.toLowerCase().trim();
    if (s == 'started') return 'In Progress';
    if (s == 'finished') return 'Finished';
    return 'Not Started';
  }

  Widget? get _icon {
    final s = status?.toLowerCase().trim();
    if (s == 'started') {
      return Icon(
        Icons.more_horiz,
        size: compact ? 14 : 16,
        color: _orange,
      );
    }
    if (s == 'finished') {
      return Icon(
        FontAwesomeIcons.badgeCheck,
        size: compact ? 14 : 16,
        color: AppColors.success,
      );
    }
    return null;
  }

  /// Menu items for the status popup. Returns list of (displayLabel, apiStatus).
  List<({String displayLabel, String apiStatus})> get _menuItems {
    final s = status?.toLowerCase().trim();
    if (s == 'started') {
      return [
        (displayLabel: 'Not Started', apiStatus: 'not_started'),
        (displayLabel: 'Finished', apiStatus: 'finished'),
      ];
    }
    if (s == 'finished') {
      return [
        (displayLabel: 'Not Started', apiStatus: 'not_started'),
        (displayLabel: 'In Progress', apiStatus: 'started'),
      ];
    }
    return [
      (displayLabel: 'In Progress', apiStatus: 'started'),
      (displayLabel: 'Finished', apiStatus: 'finished'),
    ];
  }

  /// Icon for a given status (for menu items).
  Widget? _iconForStatus(String apiStatus) {
    switch (apiStatus) {
      case 'started':
        return Icon(Icons.more_horiz, size: compact ? 14 : 16, color: _orange);
      case 'finished':
        return Icon(FontAwesomeIcons.badgeCheck, size: compact ? 14 : 16, color: AppColors.success);
      default:
        return null;
    }
  }

  Widget _buildBox({required Widget child, bool tight = false}) {
    final padding = tight
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
        : (compact
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    final fontSize = compact ? 11.0 : 13.0;

    if (showOnlyStatus) {
      return _buildBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_icon != null) ...[
              _icon!,
              SizedBox(width: compact ? 3 : 4),
            ],
            Text(
              _label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (showOnlyMenu && onStatusChange != null) {
      return _buildBox(
        tight: true,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_drop_down,
            size: compact ? 14 : 16,
            color: Colors.white,
          ),
          color: Colors.black.withOpacity(0.92),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (String apiStatus) => onStatusChange!(apiStatus),
          itemBuilder: (context) => _menuItems
              .map((e) => PopupMenuItem<String>(
                    value: e.apiStatus,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_iconForStatus(e.apiStatus) != null) ...[
                            _iconForStatus(e.apiStatus)!,
                            const SizedBox(width: 6),
                          ],
                          Text(
                            e.displayLabel,
                            style: TextStyle(
                              fontSize: compact ? 12 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return _buildBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_icon != null) ...[
            _icon!,
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            _label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (showStatusMenu && onStatusChange != null) ...[
            SizedBox(width: compact ? 3 : 4),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_drop_down,
                size: compact ? 16 : 18,
                color: Colors.white,
              ),
              color: Colors.black.withOpacity(0.92),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (String apiStatus) => onStatusChange!(apiStatus),
              itemBuilder: (context) => _menuItems
                  .map((e) => PopupMenuItem<String>(
                        value: e.apiStatus,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_iconForStatus(e.apiStatus) != null) ...[
                                _iconForStatus(e.apiStatus)!,
                                const SizedBox(width: 6),
                              ],
                              Text(
                                e.displayLabel,
                                style: TextStyle(
                                  fontSize: compact ? 12 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
