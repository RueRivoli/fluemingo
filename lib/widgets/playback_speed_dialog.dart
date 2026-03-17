import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A dialog widget for selecting playback speed.
///
/// This widget displays a bottom sheet with playback speed options
/// and allows the user to select a new speed.
class PlaybackSpeedDialog {
  /// Shows a modal bottom sheet with playback speed options.
  ///
  /// [context] - The build context to show the dialog in.
  /// [currentSpeed] - The currently selected playback speed.
  /// [onSpeedChanged] - Callback function called when a new speed is selected.
  ///                    The callback receives the new speed value.
  static void show(
    BuildContext context, {
    required double currentSpeed,
    required Function(double) onSpeedChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _PlaybackSpeedDialogContent(
          currentSpeed: currentSpeed,
          onSpeedChanged: onSpeedChanged,
        );
      },
    );
  }
}

/// Internal widget that displays the playback speed options.
class _PlaybackSpeedDialogContent extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedChanged;

  const _PlaybackSpeedDialogContent({
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  /// Available playback speed options
  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playback Speed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ..._speedOptions.map((speed) {
            final isSelected = currentSpeed == speed;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                onSpeedChanged(speed);
                Navigator.pop(context);
              },
              child: SizedBox(
                height: 48,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'x$speed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: isSelected
                          ? const Center(
                              child: FaIcon(
                                FontAwesomeIcons.check,
                                color: AppColors.textPrimary,
                                size: 14,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
