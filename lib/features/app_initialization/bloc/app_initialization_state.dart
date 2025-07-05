import 'package:equatable/equatable.dart';

abstract class AppInitializationState extends Equatable {
  const AppInitializationState();

  @override
  List<Object?> get props => [];
}

class AppInitializationInitial extends AppInitializationState {}

class AppInitializationLoading extends AppInitializationState {}

class AppCheckingModel extends AppInitializationState {}

class AppOnboardingRequired extends AppInitializationState {}

class AppModelDownloadRequired extends AppInitializationState {}

class AppReady extends AppInitializationState {}

class AppInitializationError extends AppInitializationState {
  final String message;

  const AppInitializationError(this.message);

  @override
  List<Object?> get props => [message];
}
