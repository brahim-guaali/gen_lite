import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/shared/services/llm_service.dart';
import 'package:genlite/shared/services/gemma_downloader.dart';
import 'package:genlite/shared/services/enhanced_model_downloader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/file_management/bloc/file_bloc.dart';
import 'package:genlite/features/settings/bloc/agent_bloc.dart';
import 'package:genlite/features/settings/bloc/agent_events.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';

class AppConfigurationService {
  static List<BlocProvider> getAppBlocProviders() {
    print('Providing AgentBloc, ChatBloc, FileBloc, VoiceBloc');
    return [
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
    ];
  }
}
