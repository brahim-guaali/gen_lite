import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/services/storage_service.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class CheckOnboardingStatus extends OnboardingEvent {}

class AcceptTerms extends OnboardingEvent {}

class CompleteDownload extends OnboardingEvent {}

class SkipDownload extends OnboardingEvent {}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingTermsScreen extends OnboardingState {}

class OnboardingDownloadScreen extends OnboardingState {}

class OnboardingWelcomeScreen extends OnboardingState {}

class OnboardingComplete extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<AcceptTerms>(_onAcceptTerms);
    on<CompleteDownload>(_onCompleteDownload);
    on<SkipDownload>(_onSkipDownload);
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

  Future<void> _onSkipDownload(
    SkipDownload event,
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
