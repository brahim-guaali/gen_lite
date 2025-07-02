import 'package:equatable/equatable.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class CheckOnboardingStatus extends OnboardingEvent {}

class AcceptTerms extends OnboardingEvent {}

class CompleteDownload extends OnboardingEvent {}
