import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class HapticsService {
  Future<void> playToastHaptic() async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) return;

      await Vibration.vibrate(pattern: [0, 80, 100, 80], intensities: [0, 200, 0, 200]);
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }

  Future<void> playNearHaptic() async {
    try {
      await Vibration.vibrate(duration: 30, amplitude: 100);
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }
}
