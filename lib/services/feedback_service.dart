import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  AudioPlayer? _player;

  /// Light haptic tick, e.g. when advancing to the next onboarding step.
  /// Haptic only — no sound.
  void tapNext() {
    HapticFeedback.lightImpact();
  }

  Future<void> playSuccess() async {
    HapticFeedback.mediumImpact();
    try {
      _player ??= AudioPlayer();
      await _player!.setAsset('assets/sounds/success.mp3');
      await _player!.play();
    } catch (_) {
      // Sound is non-critical; never block the UI
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
