import 'package:equatable/equatable.dart';

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
