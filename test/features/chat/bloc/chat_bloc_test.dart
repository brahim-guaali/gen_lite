import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_events.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import 'package:genlite/shared/models/message.dart';
import 'package:genlite/shared/models/conversation.dart';

void main() {
  group('ChatBloc', () {
    late ChatBloc chatBloc;

    setUp(() {
      chatBloc = ChatBloc();
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initial state should be ChatInitial', () {
      expect(chatBloc.state, isA<ChatInitial>());
    });

    group('CreateNewConversation', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatLoaded with new conversation when creating first conversation',
        build: () => chatBloc,
        act: (bloc) =>
            bloc.add(const CreateNewConversation(title: 'Test Conversation')),
        expect: () => [
          isA<ChatLoaded>()
              .having(
                (state) => state.currentConversation.title,
                'currentConversation.title',
                'Test Conversation',
              )
              .having(
                (state) => state.conversations.length,
                'conversations.length',
                1,
              ),
        ],
      );
    });

    group('SendMessage', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatLoaded with processing state and then with AI response',
        build: () => chatBloc,
        seed: () => ChatLoaded(
          currentConversation: Conversation.create(title: 'Test Conversation'),
          conversations: [Conversation.create(title: 'Test Conversation')],
        ),
        act: (bloc) => bloc.add(const SendMessage(content: 'Hello AI')),
        expect: () => [
          isA<ChatLoaded>()
              .having(
                (state) => state.isProcessing,
                'isProcessing',
                true,
              )
              .having(
                (state) => state.currentConversation.messages.length,
                'messages.length',
                1,
              ),
          isA<ChatLoaded>()
              .having(
                (state) => state.isProcessing,
                'isProcessing',
                false,
              )
              .having(
                (state) => state.currentConversation.messages.length,
                'messages.length',
                2,
              ),
        ],
        wait: const Duration(milliseconds: 150),
      );

      blocTest<ChatBloc, ChatState>(
        'should not emit anything when state is not ChatLoaded',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const SendMessage(content: 'Hello AI')),
        expect: () => [],
      );
    });

    group('LoadConversation', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatError when conversation not found',
        build: () => chatBloc,
        seed: () => ChatLoaded(
          currentConversation: Conversation.create(title: 'First Conversation'),
          conversations: [Conversation.create(title: 'First Conversation')],
        ),
        act: (bloc) => bloc.add(const LoadConversation('non-existent')),
        expect: () => [
          isA<ChatError>(),
        ],
      );
    });
  });
}
