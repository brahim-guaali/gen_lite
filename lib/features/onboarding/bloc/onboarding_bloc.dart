import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/features/onboarding/bloc/onboarding_event.dart';
import 'package:genlite/features/onboarding/bloc/onboarding_state.dart';

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<AcceptTerms>(_onAcceptTerms);
    on<CompleteDownload>(_onCompleteDownload);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    try {
      final hasCompletedOnboarding =
          await StorageService.getSetting<bool>('hasCompletedOnboarding') ??
              false;

      if (hasCompletedOnboarding) {
        emit(OnboardingComplete());
      } else {
        emit(OnboardingTermsScreen());
      }
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onAcceptTerms(
    AcceptTerms event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await StorageService.saveSetting('hasCompletedOnboarding', true);
      emit(OnboardingComplete());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onCompleteDownload(
    CompleteDownload event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await StorageService.saveSetting('hasCompletedOnboarding', true);
      emit(OnboardingComplete());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
