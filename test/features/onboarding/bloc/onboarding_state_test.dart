import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/onboarding/bloc/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    group('OnboardingInitial', () {
      test('should be equatable', () {
        final state1 = OnboardingInitial();
        final state2 = OnboardingInitial();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = OnboardingInitial();
        expect(state.props, isEmpty);
      });
    });

    group('OnboardingLoading', () {
      test('should be equatable', () {
        final state1 = OnboardingLoading();
        final state2 = OnboardingLoading();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = OnboardingLoading();
        expect(state.props, isEmpty);
      });
    });

    group('OnboardingWelcomeScreen', () {
      test('should be equatable', () {
        final state1 = OnboardingWelcomeScreen();
        final state2 = OnboardingWelcomeScreen();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = OnboardingWelcomeScreen();
        expect(state.props, isEmpty);
      });
    });

    group('OnboardingTermsScreen', () {
      test('should be equatable', () {
        final state1 = OnboardingTermsScreen();
        final state2 = OnboardingTermsScreen();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = OnboardingTermsScreen();
        expect(state.props, isEmpty);
      });
    });

    group('OnboardingDownloadScreen', () {
      test('should be equatable', () {
        final state1 = OnboardingDownloadScreen();
        final state2 = OnboardingDownloadScreen();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = OnboardingDownloadScreen();
        expect(state.props, isEmpty);
      });
    });

    group('OnboardingComplete', () {
      test('should be equatable', () {
        final state1 = OnboardingComplete();
        final state2 = OnboardingComplete();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = OnboardingComplete();
        expect(state.props, isEmpty);
      });
    });

    group('OnboardingError', () {
      test('should create with error message', () {
        const errorMessage = 'Onboarding failed';
        final state = OnboardingError(errorMessage);
        expect(state.message, errorMessage);
      });

      test('should be equatable', () {
        final state1 = OnboardingError('Error 1');
        final state2 = OnboardingError('Error 1');
        final state3 = OnboardingError('Error 2');

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const errorMessage = 'Onboarding failed';
        final state = OnboardingError(errorMessage);
        expect(state.props, [errorMessage]);
      });
    });
  });
}
