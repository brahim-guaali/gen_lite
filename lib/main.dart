import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/app_initialization/bloc/app_initialization_bloc.dart';
import 'features/app_initialization/bloc/app_initialization_event.dart';
import 'features/app_initialization/presentation/app_router.dart';
import 'shared/services/storage_service.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/file_management/bloc/file_bloc.dart';
import 'features/settings/bloc/agent_bloc.dart';
import 'features/settings/bloc/agent_events.dart';
import 'features/voice/bloc/voice_bloc.dart';
import 'features/voice/bloc/voice_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first, before any other initialization
  await dotenv.load();

  // Initialize other services after dotenv is loaded
  await StorageService.initialize();

  print('Starting GenLiteApp with MultiBlocProvider');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            print('Creating AppInitializationBloc');
            return AppInitializationBloc()..add(InitializeApp());
          },
        ),
        BlocProvider(create: (context) {
          print('Creating ChatBloc');
          return ChatBloc();
        }),
        BlocProvider(create: (context) {
          print('Creating FileBloc');
          return FileBloc();
        }),
        BlocProvider(create: (context) {
          print('Creating AgentBloc');
          return AgentBloc()..add(LoadAgentTemplates());
        }),
        BlocProvider(create: (context) {
          print('Creating VoiceBloc');
          return VoiceBloc()..add(const InitializeVoiceServices());
        }),
      ],
      child: const GenLiteApp(),
    ),
  );
}

class GenLiteApp extends StatelessWidget {
  const GenLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building GenLiteApp (MaterialApp)');
    return MaterialApp(
      title: 'GenLite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AppRouter(),
    );
  }
}
