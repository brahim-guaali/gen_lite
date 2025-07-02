import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/services/storage_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

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
      final hasAcceptedTerms =
          await StorageService.getSetting<bool>('hasAcceptedTerms') ?? false;
      final hasCompletedDownload =
          await StorageService.getSetting<bool>('hasCompletedDownload') ??
              false;

      if (!hasAcceptedTerms) {
        emit(OnboardingTermsScreen());
      } else if (!hasCompletedDownload) {
        emit(OnboardingDownloadScreen());
      } else {
        emit(OnboardingWelcomeScreen());
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
      await StorageService.saveSetting('hasAcceptedTerms', true);
      emit(OnboardingDownloadScreen());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onCompleteDownload(
    CompleteDownload event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await StorageService.saveSetting('hasCompletedDownload', true);
      emit(OnboardingWelcomeScreen());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
