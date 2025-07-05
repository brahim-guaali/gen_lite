import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:genlite/features/app_initialization/bloc/app_initialization_bloc.dart';
import 'package:genlite/features/app_initialization/bloc/app_initialization_event.dart';
import 'package:genlite/features/app_initialization/bloc/app_initialization_state.dart';
import '../../../test_config.dart';

void main() {
  group('AppInitializationBloc', () {
    late AppInitializationBloc bloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    setUp(() {
      bloc = AppInitializationBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AppInitializationInitial', () {
      expect(bloc.state, isA<AppInitializationInitial>());
    });

    blocTest<AppInitializationBloc, AppInitializationState>(
      'emits [AppInitializationLoading, AppOnboardingRequired] when InitializeApp is added and onboarding not complete',
      build: () => AppInitializationBloc(),
      act: (bloc) => bloc.add(InitializeApp()),
      expect: () =>
          [isA<AppInitializationLoading>(), isA<AppOnboardingRequired>()],
    );

    blocTest<AppInitializationBloc, AppInitializationState>(
      'emits [AppReady] when ModelDownloadComplete is added',
      build: () => AppInitializationBloc(),
      act: (bloc) => bloc.add(ModelDownloadComplete()),
      expect: () => [isA<AppReady>()],
    );
  });
}
