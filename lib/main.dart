import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/file_management/bloc/file_bloc.dart';
import 'features/file_management/presentation/file_management_screen.dart';
import 'features/settings/bloc/agent_bloc.dart';
import 'features/settings/presentation/agent_management_screen.dart';
import 'shared/services/storage_service.dart';
import 'shared/widgets/download_screen.dart';
import 'shared/widgets/ui_components.dart';

const String gemmaTermsMarkdown = '''
# Gemma Terms of Use

## License Agreement

This software is licensed under the Gemma License Agreement. By using this software, you agree to be bound by the terms of this license.

## Key Terms

1. **Permitted Uses**: You may use, reproduce, distribute, and create derivative works of the Software for any lawful purpose, subject to the restrictions below.

2. **Restrictions**: You may not:
   - Use the Software for any illegal or harmful purpose
   - Attempt to reverse engineer or decompile the Software
   - Remove or alter any proprietary notices

3. **Attribution**: When distributing the Software, you must include a copy of this license.

4. **No Warranty**: The Software is provided "as is" without warranty of any kind.

5. **Limitation of Liability**: In no event shall the authors be liable for any damages arising from the use of the Software.

## Full License

For the complete Gemma License Agreement, please visit: https://ai.google.dev/gemma/terms

By accepting these terms, you acknowledge that you have read, understood, and agree to be bound by the Gemma License Agreement.
''';

class GemmaTermsScreen extends StatelessWidget {
  const GemmaTermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gemma Terms of Use',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const AppDivider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Markdown(
                  data: gemmaTermsMarkdown,
                  selectable: true,
                  shrinkWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await StorageService.initialize();
  runApp(const GenLiteApp());
}

class GenLiteApp extends StatefulWidget {
  const GenLiteApp({super.key});

  @override
  State<GenLiteApp> createState() => _GenLiteAppState();
}

class _GenLiteAppState extends State<GenLiteApp> {
  bool _isReady = false;
  String? _error;
  bool _showOnboarding = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    // Check if model is already downloaded and ready
    try {
      // This will be handled by the download screen
      setState(() {
        _isReady = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _onDownloadComplete() {
    setState(() {
      _isReady = true;
    });
  }

  void _onSkip() {
    setState(() {
      _isReady = true;
    });
  }

  Widget _buildOnboardingScreen() {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    (AppConstants.paddingLarge * 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: 60,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  AppSpacing.lg,

                  // Title
                  Text(
                    'Welcome to GenLite',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.md,

                  // Description
                  Text(
                    'GenLite is a lightweight, offline AI assistant that runs entirely on your device.\n\n'
                    'To enable AI features, the app will download a large language model (Gemma 2B) from Hugging Face.\n\n'
                    'This download may take several minutes and require several GB of storage. All processing stays on your device.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.lg,

                  // Features
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Features',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        AppSpacing.sm,
                        _buildFeatureRow(Icons.security,
                            '100% Offline - No data sent to servers'),
                        _buildFeatureRow(Icons.speed, 'Fast local processing'),
                        _buildFeatureRow(
                            Icons.privacy_tip, 'Complete privacy protection'),
                        _buildFeatureRow(
                            Icons.file_copy, 'Document analysis support'),
                      ],
                    ),
                  ),
                  AppSpacing.lg,

                  // Terms acceptance
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                        },
                        activeColor: AppConstants.primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _termsAccepted = !_termsAccepted;
                            });
                          },
                          child: Text(
                            'I accept the Gemma Terms of Use',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.sm,

                  // Terms link
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const GemmaTermsScreen(),
                      );
                    },
                    child: const Text('Read Terms of Use'),
                  ),
                  AppSpacing.lg,

                  // Continue button
                  PrimaryButton(
                    text: 'Continue',
                    icon: Icons.arrow_forward,
                    onPressed: _termsAccepted
                        ? () => setState(() => _showOnboarding = false)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                icon: Icons.error_outline,
                size: 80,
                color: AppConstants.errorColor,
              ),
              AppSpacing.lg,
              Text(
                'Setup Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.errorColor,
                    ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.md,
              Text(
                _error ?? 'An unknown error occurred during setup.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.xl,
              PrimaryButton(
                text: 'Retry Setup',
                icon: Icons.refresh,
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _checkModelStatus();
                },
              ),
              AppSpacing.md,
              SecondaryButton(
                text: 'Skip for Now',
                icon: Icons.skip_next,
                onPressed: _onSkip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => FileBloc()),
        BlocProvider(create: (_) => AgentBloc()),
      ],
      child: const ChatScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _showOnboarding
          ? _buildOnboardingScreen()
          : _error != null
              ? _buildErrorScreen()
              : !_isReady
                  ? DownloadScreen(
                      onDownloadComplete: _onDownloadComplete,
                      onSkip: _onSkip,
                    )
                  : _buildMainApp(),
      routes: {
        '/chat': (_) => const ChatScreen(),
        '/files': (_) => const FileManagementScreen(),
        '/agents': (_) => const AgentManagementScreen(),
      },
    );
  }
}
