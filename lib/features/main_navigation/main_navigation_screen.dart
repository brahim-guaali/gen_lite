import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../chat/presentation/chat_screen.dart';
import '../file_management/presentation/file_management_screen.dart';
import '../settings/presentation/settings_home_screen.dart';
import '../settings/bloc/agent_bloc.dart';
import '../settings/bloc/agent_states.dart';
import '../chat/bloc/chat_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const FileManagementScreen(),
    const SettingsHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    print(
        'AgentBloc found: [32m${BlocProvider.of<AgentBloc>(context, listen: false) != null}[0m');
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
