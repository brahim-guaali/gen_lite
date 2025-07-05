import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/file_management/bloc/file_bloc.dart';
import 'features/file_management/presentation/file_management_screen.dart';
import 'features/settings/bloc/agent_bloc.dart';
import 'features/settings/bloc/agent_events.dart';
import 'features/settings/bloc/agent_states.dart';
import 'features/settings/presentation/agent_management_screen.dart';
import 'features/settings/presentation/settings_home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/voice/bloc/voice_bloc.dart';
import 'features/voice/bloc/voice_event.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/llm_service.dart';
import 'shared/widgets/download_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first, before any other initialization
  await dotenv.load();

  // Initialize other services after dotenv is loaded
  await StorageService.initialize();

  runApp(const GenLiteApp());
}

class GenLiteApp extends StatefulWidget {
  const GenLiteApp({super.key});

  @override
  State<GenLiteApp> createState() => _GenLiteAppState();
}

class _GenLiteAppState extends State<GenLiteApp> {
  bool _hasCompletedOnboarding = false;
  bool _isModelReady = false;
  bool _isCheckingModel = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check onboarding status
    final hasCompletedOnboarding =
        await StorageService.getSetting<bool>('hasCompletedOnboarding') ??
            false;

    setState(() {
      _hasCompletedOnboarding = hasCompletedOnboarding;
    });

    // Check if model is ready
    if (_hasCompletedOnboarding) {
      await _checkModelStatus();
    } else {
      setState(() {
        _isCheckingModel = false;
      });
    }
  }

  Future<void> _checkModelStatus() async {
    try {
      // Try to initialize LLM service to check if model exists
      await LLMService().initialize();
      setState(() {
        _isModelReady = true;
        _isCheckingModel = false;
      });
    } catch (e) {
      // Model not found or not ready
      setState(() {
        _isModelReady = false;
        _isCheckingModel = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    await StorageService.saveSetting('hasCompletedOnboarding', true);
    setState(() {
      _hasCompletedOnboarding = true;
    });
    // Check model status after onboarding
    await _checkModelStatus();
  }

  void _onModelDownloadComplete() {
    setState(() {
      _isModelReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatBloc()),
        BlocProvider(create: (context) => FileBloc()),
        BlocProvider(
            create: (context) => AgentBloc()..add(LoadAgentTemplates())),
        BlocProvider(
          create: (context) =>
              VoiceBloc()..add(const InitializeVoiceServices()),
        ),
      ],
      child: MaterialApp(
        title: 'GenLite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_isCheckingModel) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasCompletedOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    if (!_isModelReady) {
      return DownloadScreen(onDownloadComplete: _onModelDownloadComplete);
    }

    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const FileManagementScreen(),
    const SettingsHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AgentBloc, AgentState>(
          listener: (context, state) {
            if (state is AgentLoaded) {
              // Update the chat bloc with the active agent
              final chatBloc = context.read<ChatBloc>();
              chatBloc.setActiveAgent(state.activeAgent);
            }
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
