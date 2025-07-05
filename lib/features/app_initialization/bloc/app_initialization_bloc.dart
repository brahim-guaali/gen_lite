import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/shared/services/llm_service.dart';
import 'package:genlite/features/app_initialization/bloc/app_initialization_event.dart';
import 'package:genlite/features/app_initialization/bloc/app_initialization_state.dart';

class AppInitializationBloc
    extends Bloc<AppInitializationEvent, AppInitializationState> {
  AppInitializationBloc() : super(AppInitializationInitial()) {
    on<InitializeApp>(_onInitializeApp);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<ModelDownloadComplete>(_onModelDownloadComplete);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<AppInitializationState> emit,
  ) async {
    emit(AppInitializationLoading());

    try {
      // Check onboarding status
      final hasCompletedOnboarding =
          await StorageService.getSetting<bool>('hasCompletedOnboarding') ??
              false;

      if (!hasCompletedOnboarding) {
        emit(AppOnboardingRequired());
        return;
      }

      // Check if model is ready
      emit(AppCheckingModel());
      await _checkModelStatus(emit);
    } catch (e) {
      emit(AppInitializationError(e.toString()));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<AppInitializationState> emit,
  ) async {
    try {
      await StorageService.saveSetting('hasCompletedOnboarding', true);
      emit(AppCheckingModel());
      await _checkModelStatus(emit);
    } catch (e) {
      emit(AppInitializationError(e.toString()));
    }
  }

  Future<void> _onModelDownloadComplete(
    ModelDownloadComplete event,
    Emitter<AppInitializationState> emit,
  ) async {
    emit(AppReady());
  }

  Future<void> _checkModelStatus(Emitter<AppInitializationState> emit) async {
    try {
      // Try to initialize LLM service to check if model exists
      await LLMService().initialize();
      emit(AppReady());
    } catch (e) {
      // Model not found or not ready
      emit(AppModelDownloadRequired());
    }
  }
}
