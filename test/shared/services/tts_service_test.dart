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
  });
}
