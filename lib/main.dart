import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/file_management/bloc/file_bloc.dart';
import 'features/file_management/presentation/file_management_screen.dart';
import 'features/settings/bloc/agent_bloc.dart';
import 'features/settings/presentation/agent_management_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'shared/services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final hasCompletedOnboarding =
        await StorageService.getSetting<bool>('hasCompletedOnboarding') ??
            false;

    setState(() {
      _hasCompletedOnboarding = hasCompletedOnboarding;
    });
  }

  Future<void> _completeOnboarding() async {
    await StorageService.saveSetting('hasCompletedOnboarding', true);
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GenLite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _hasCompletedOnboarding
          ? _buildMainApp()
          : OnboardingScreen(onComplete: _completeOnboarding),
    );
  }

  Widget _buildMainApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatBloc()),
        BlocProvider(create: (context) => FileBloc()),
        BlocProvider(create: (context) => AgentBloc()),
      ],
      child: const MainScreen(),
    );
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
    const AgentManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
    );
  }
}
