import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/app_initialization/bloc/app_initialization_bloc.dart';
import 'features/app_initialization/bloc/app_initialization_event.dart';
import 'features/app_initialization/bloc/app_initialization_state.dart';
import 'features/app_initialization/presentation/initialization_screen.dart';
import 'features/main_navigation/main_navigation_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'shared/widgets/download_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppInitializationBloc, AppInitializationState>(
      builder: (context, state) {
        print('[AppRouter] State: [33m${state.runtimeType}[0m');
        if (state is AppInitializationInitial ||
            state is AppInitializationLoading) {
          print('[AppRouter] Showing InitializationScreen');
          return const InitializationScreen();
        }

        if (state is AppCheckingModel) {
          print('[AppRouter] Showing InitializationScreen (CheckingModel)');
          return const InitializationScreen();
        }

        if (state is AppOnboardingRequired) {
          print('[AppRouter] Showing OnboardingScreen');
          return OnboardingScreen(
            onComplete: () {
              context.read<AppInitializationBloc>().add(CompleteOnboarding());
            },
          );
        }

        if (state is AppModelDownloadRequired) {
          print('[AppRouter] Showing DownloadScreen');
          return DownloadScreen(
            onDownloadComplete: () {
              context
                  .read<AppInitializationBloc>()
                  .add(ModelDownloadComplete());
            },
          );
        }

        if (state is AppReady) {
          print('[AppRouter] Showing MainNavigationScreen');
          return Builder(
            builder: (context) => const MainNavigationScreen(),
          );
        }

        if (state is AppInitializationError) {
          print('[AppRouter] Showing InitializationError');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initialization Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<AppInitializationBloc>()
                          .add(InitializeApp());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Fallback
        print('[AppRouter] Fallback to InitializationScreen');
        return const InitializationScreen();
      },
    );
  }
}
