import 'package:flutter_test/flutter_test.dart';
import '../../../lib/shared/services/tts_service.dart';

void main() {
  group('TTSService', () {
    test('should remove emojis from text before speaking', () {
      final textWithEmojis = 'Hello 👋, how are you? 😊🚀';
      final expected = 'Hello , how are you? ';
      final result = TTSService.removeEmojis(textWithEmojis);
      expect(result, expected);
    });

    test('should use more natural default TTS settings', () {
      expect(TTSService.defaultSpeechRate, closeTo(0.44, 0.01));
      expect(TTSService.defaultPitch, closeTo(1.15, 0.01));
      expect(TTSService.defaultVolume, closeTo(0.95, 0.01));
    });
  });
}
