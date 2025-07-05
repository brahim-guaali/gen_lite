import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/onboarding/bloc/onboarding_event.dart';

void main() {
  group('OnboardingEvent', () {
    group('CheckOnboardingStatus', () {
      test('should be equatable', () {
        final event1 = CheckOnboardingStatus();
        final event2 = CheckOnboardingStatus();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = CheckOnboardingStatus();
        expect(event.props, isEmpty);
      });
    });

    group('AcceptTerms', () {
      test('should be equatable', () {
        final event1 = AcceptTerms();
        final event2 = AcceptTerms();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = AcceptTerms();
        expect(event.props, isEmpty);
      });
    });

    group('CompleteDownload', () {
      test('should be equatable', () {
        final event1 = CompleteDownload();
        final event2 = CompleteDownload();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = CompleteDownload();
        expect(event.props, isEmpty);
      });
    });
  });
}
