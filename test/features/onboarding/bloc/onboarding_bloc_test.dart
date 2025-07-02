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
        'should emit OnboardingLoading then OnboardingTermsScreen when terms not accepted',
        build: () => onboardingBloc,
        act: (bloc) => bloc.add(CheckOnboardingStatus()),
        expect: () => [
          isA<OnboardingLoading>(),
          isA<OnboardingTermsScreen>(),
        ],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingLoading then OnboardingDownloadScreen when terms accepted but download not completed',
        build: () => onboardingBloc,
        seed: () => OnboardingInitial(),
        act: (bloc) async {
          await StorageService.saveSetting('hasAcceptedTerms', true);
          bloc.add(CheckOnboardingStatus());
        },
        expect: () => [
          isA<OnboardingLoading>(),
          isA<OnboardingDownloadScreen>(),
        ],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingLoading then OnboardingWelcomeScreen when both terms and download completed',
        build: () => onboardingBloc,
        seed: () => OnboardingInitial(),
        act: (bloc) async {
          await StorageService.saveSetting('hasAcceptedTerms', true);
          await StorageService.saveSetting('hasCompletedDownload', true);
          bloc.add(CheckOnboardingStatus());
        },
        expect: () => [
          isA<OnboardingLoading>(),
          isA<OnboardingWelcomeScreen>(),
        ],
      );
    });

    group('AcceptTerms', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingDownloadScreen when terms are accepted',
        build: () => onboardingBloc,
        seed: () => OnboardingTermsScreen(),
        act: (bloc) => bloc.add(AcceptTerms()),
        expect: () => [
          isA<OnboardingDownloadScreen>(),
        ],
        wait: const Duration(milliseconds: 100),
      );

      test('should save terms acceptance to storage', () async {
        final bloc = OnboardingBloc();
        bloc.emit(OnboardingTermsScreen());

        bloc.add(AcceptTerms());
        await Future.delayed(const Duration(milliseconds: 200));

        final hasAcceptedTerms =
            await StorageService.getSetting<bool>('hasAcceptedTerms');
        expect(hasAcceptedTerms, isTrue);

        bloc.close();
      });
    });

    group('CompleteDownload', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should emit OnboardingWelcomeScreen when download is completed',
        build: () => onboardingBloc,
        seed: () => OnboardingDownloadScreen(),
        act: (bloc) => bloc.add(CompleteDownload()),
        expect: () => [
          isA<OnboardingWelcomeScreen>(),
        ],
        wait: const Duration(milliseconds: 100),
      );

      test('should save download completion to storage', () async {
        final bloc = OnboardingBloc();
        bloc.emit(OnboardingDownloadScreen());

        bloc.add(CompleteDownload());
        await Future.delayed(const Duration(milliseconds: 200));

        final hasCompletedDownload =
            await StorageService.getSetting<bool>('hasCompletedDownload');
        expect(hasCompletedDownload, isTrue);

        bloc.close();
      });
    });

    group('State Equality', () {
      test('OnboardingError states should be equal with same message', () {
        final error1 = OnboardingError('Test error');
        final error2 = OnboardingError('Test error');
        expect(error1, equals(error2));
      });

      test('OnboardingError states should not be equal with different messages',
          () {
        final error1 = OnboardingError('Test error 1');
        final error2 = OnboardingError('Test error 2');
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
