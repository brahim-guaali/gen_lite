import 'package:equatable/equatable.dart';

abstract class AppInitializationEvent extends Equatable {
  const AppInitializationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeApp extends AppInitializationEvent {}

class CompleteOnboarding extends AppInitializationEvent {}

class ModelDownloadComplete extends AppInitializationEvent {}
