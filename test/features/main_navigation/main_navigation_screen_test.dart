import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/features/main_navigation/main_navigation_screen.dart';
import 'package:genlite/features/app_initialization/bloc/app_initialization_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/file_management/bloc/file_bloc.dart';
import 'package:genlite/features/settings/bloc/agent_bloc.dart';
import '../../test_config.dart';

void main() {
  group('MainNavigationScreen', () {
    late AgentBloc agentBloc;
    late ChatBloc chatBloc;
    late VoiceBloc voiceBloc;
    late FileBloc fileBloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    setUp(() {
      agentBloc = AgentBloc();
      chatBloc = ChatBloc();
      voiceBloc = VoiceBloc();
      fileBloc = FileBloc();
    });

    tearDown(() {
      agentBloc.close();
      chatBloc.close();
      voiceBloc.close();
      fileBloc.close();
    });

    testWidgets('renders and shows navigation bar', (tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          MultiBlocProvider(
            providers: [
              BlocProvider<AgentBloc>.value(value: agentBloc),
              BlocProvider<ChatBloc>.value(value: chatBloc),
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
              BlocProvider<FileBloc>.value(value: fileBloc),
            ],
            child: const MainNavigationScreen(),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
