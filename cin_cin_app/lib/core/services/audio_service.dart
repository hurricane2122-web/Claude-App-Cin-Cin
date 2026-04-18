import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playCinCin() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/cincin.wav'));
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
