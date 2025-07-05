import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_terms_screen.dart' as terms_widget;
import '../widgets/onboarding_welcome_screen.dart';
import '../widgets/onboarding_error_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    print('[OnboardingScreen] Building OnboardingScreen');
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(CheckOnboardingStatus()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingComplete) {
            print('[OnboardingScreen] OnboardingComplete - calling onComplete');
            onComplete();
          }
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            print('[OnboardingScreen] State: [35m${state.runtimeType}[0m');
            if (state is OnboardingInitial || state is OnboardingLoading) {
              print('[OnboardingScreen] Showing loading spinner');
              return const Scaffold(
                backgroundColor: Color(0xFF6366F1), //
                body: Center(
                  child: Text(''),
                ),
              );
            }

            if (state is OnboardingTermsScreen) {
              print('[OnboardingScreen] Showing OnboardingTermsScreen');
              return terms_widget.OnboardingTermsScreen(onComplete: onComplete);
            }

            if (state is OnboardingError) {
              print('[OnboardingScreen] Showing OnboardingErrorScreen');
              return OnboardingErrorScreen(
                message: state.message,
                onRetry: () =>
                    context.read<OnboardingBloc>().add(CheckOnboardingStatus()),
              );
            }

            print('[OnboardingScreen] Unknown state - showing fallback');
            return const Scaffold(
              body: Center(
                child: Text('Unknown state'),
              ),
            );
          },
        ),
      ),
    );
  }
}
