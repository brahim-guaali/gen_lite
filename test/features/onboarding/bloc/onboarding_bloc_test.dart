import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:genlite/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:genlite/features/onboarding/bloc/onboarding_event.dart';
import 'package:genlite/features/onboarding/bloc/onboarding_state.dart';
import 'package:genlite/shared/services/storage_service.dart';
import '../../../test_config.dart';

void main() {
  group('OnboardingBloc', () {
    late OnboardingBloc onboardingBloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    setUp(() {
      onboardingBloc = OnboardingBloc();
    });

    tearDown(() {
      onboardingBloc.close();
    });

    test('initial state should be OnboardingInitial', () {
      expect(onboardingBloc.state, isA<OnboardingInitial>());
    });

    group('CheckOnboardingStatus', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingLoading then OnboardingTermsScreen when onboarding not completed',
        build: () => onboardingBloc,
        act: (bloc) => bloc.add(CheckOnboardingStatus()),
        expect: () => [
          isA<OnboardingLoading>(),
          isA<OnboardingTermsScreen>(),
        ],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingLoading then OnboardingComplete when onboarding completed',
        build: () => onboardingBloc,
        seed: () => OnboardingInitial(),
        act: (bloc) async {
          await StorageService.saveSetting('hasCompletedOnboarding', true);
          bloc.add(CheckOnboardingStatus());
        },
        expect: () => [
          isA<OnboardingLoading>(),
          isA<OnboardingComplete>(),
        ],
      );
    });

    group('AcceptTerms', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingComplete when terms are accepted',
        build: () => onboardingBloc,
        seed: () => OnboardingTermsScreen(),
        act: (bloc) => bloc.add(AcceptTerms()),
        expect: () => [
          isA<OnboardingComplete>(),
        ],
        wait: const Duration(milliseconds: 100),
      );

      test('should save onboarding completion to storage', () async {
        final bloc = OnboardingBloc();
        bloc.emit(OnboardingTermsScreen());

        bloc.add(AcceptTerms());
        await Future.delayed(const Duration(milliseconds: 200));

        final hasCompletedOnboarding =
            await StorageService.getSetting<bool>('hasCompletedOnboarding');
        expect(hasCompletedOnboarding, isTrue);

        bloc.close();
      });
    });

    group('CompleteDownload', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingComplete when download is completed',
        build: () => onboardingBloc,
        seed: () => OnboardingTermsScreen(),
        act: (bloc) => bloc.add(CompleteDownload()),
        expect: () => [
          isA<OnboardingComplete>(),
        ],
        wait: const Duration(milliseconds: 100),
      );

      test('should save onboarding completion to storage', () async {
        final bloc = OnboardingBloc();
        bloc.emit(OnboardingTermsScreen());

        bloc.add(CompleteDownload());
        await Future.delayed(const Duration(milliseconds: 200));

        final hasCompletedOnboarding =
            await StorageService.getSetting<bool>('hasCompletedOnboarding');
        expect(hasCompletedOnboarding, isTrue);

        bloc.close();
      });
    });

    group('State Equality', () {
      test('OnboardingError states should be equal with same message', () {
        const error1 = OnboardingError('Test error');
        const error2 = OnboardingError('Test error');
        expect(error1, equals(error2));
      });

      test('OnboardingError states should not be equal with different messages',
          () {
        const error1 = OnboardingError('Test error 1');
        const error2 = OnboardingError('Test error 2');
        expect(error1, isNot(equals(error2)));
      });

      test('OnboardingInitial states should be equal', () {
        final state1 = OnboardingInitial();
        final state2 = OnboardingInitial();
        expect(state1, equals(state2));
      });
    });

    group('Event Equality', () {
      test('CheckOnboardingStatus events should be equal', () {
        final event1 = CheckOnboardingStatus();
        final event2 = CheckOnboardingStatus();
        expect(event1, equals(event2));
      });

      test('AcceptTerms events should be equal', () {
        final event1 = AcceptTerms();
        final event2 = AcceptTerms();
        expect(event1, equals(event2));
      });

      test('CompleteDownload events should be equal', () {
        final event1 = CompleteDownload();
        final event2 = CompleteDownload();
        expect(event1, equals(event2));
      });
    });
  });
}
