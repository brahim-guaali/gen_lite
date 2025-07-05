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
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(CheckOnboardingStatus()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingComplete) {
            onComplete();
          }
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state is OnboardingInitial || state is OnboardingLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is OnboardingTermsScreen) {
              return terms_widget.OnboardingTermsScreen(onComplete: onComplete);
            }

            if (state is OnboardingError) {
              return OnboardingErrorScreen(
                message: state.message,
                onRetry: () =>
                    context.read<OnboardingBloc>().add(CheckOnboardingStatus()),
              );
            }

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
