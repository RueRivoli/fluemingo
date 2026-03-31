import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';

/// Bottom audio player bar with progress slider and transport controls.
class AudioPlaybackControls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final bool repeatMode;
  final double playbackSpeed;
  final VoidCallback onPlayPause;
  final VoidCallback onRewind;
  final VoidCallback onForward;
  final VoidCallback onRepeatToggle;
  final VoidCallback onSpeedTap;

  const AudioPlaybackControls({
    super.key,
    required this.audioPlayer,
    required this.isPlaying,
    required this.repeatMode,
    required this.playbackSpeed,
    required this.onPlayPause,
    required this.onRewind,
    required this.onForward,
    required this.onRepeatToggle,
    required this.onSpeedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AudioProgressBar(audioPlayer: audioPlayer),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Speed button
                GestureDetector(
                  onTap: onSpeedTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.neutral,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'x$playbackSpeed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Rewind 10s
                GestureDetector(
                  onTap: onRewind,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(
                      FontAwesomeIcons.arrowRotateLeft10,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                ),
                // Play/Pause
                GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? FontAwesomeIcons.pause
                          : FontAwesomeIcons.play,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                // Forward 10s
                GestureDetector(
                  onTap: onForward,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(
                      FontAwesomeIcons.arrowRotateRight10,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                ),
                // Repeat
                GestureDetector(
                  onTap: onRepeatToggle,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: repeatMode ? AppColors.primary : AppColors.neutral,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.repeat,
                      color:
                          repeatMode ? Colors.white : AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioProgressBar extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const _AudioProgressBar({required this.audioPlayer});

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes;
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      final mins =
          duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      return '$hours:$mins:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: audioPlayer.durationStream,
      initialData: audioPlayer.duration,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: audioPlayer.positionStream,
          initialData: audioPlayer.position,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final maxMs = duration.inMilliseconds.toDouble();
            final currentMs = maxMs > 0
                ? position.inMilliseconds
                    .clamp(0, duration.inMilliseconds)
                    .toDouble()
                : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: currentMs,
                    min: 0,
                    max: maxMs > 0 ? maxMs : 1,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.neutral,
                    onChanged: maxMs > 0
                        ? (value) {
                            audioPlayer.seek(
                                Duration(milliseconds: value.round()));
                          }
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(
                            Duration(milliseconds: currentMs.round())),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
