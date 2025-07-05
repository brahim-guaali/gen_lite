import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_events.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import '../../../test_config.dart';

void main() {
  group('ChatBloc', () {
    late ChatBloc chatBloc;

    setUpAll(() {
      TestConfig.initialize();
    });

    setUp(() {
      chatBloc = ChatBloc();
    });

    tearDown(() {
      chatBloc.close();
    });

    tearDownAll(() {
      TestConfig.cleanup();
    });

    test('initial state should be ChatInitial', () {
      expect(chatBloc.state, isA<ChatInitial>());
    });

    group('CreateNewConversation', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatLoaded with new conversation',
        build: () => chatBloc,
        act: (bloc) =>
            bloc.add(const CreateNewConversation(title: 'Test Conversation')),
        expect: () => [
          isA<ChatLoaded>(),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit ChatError when title is empty',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const CreateNewConversation(title: '')),
        expect: () => [
          isA<ChatError>(),
        ],
      );
    });

    group('LoadConversations', () {
      blocTest<ChatBloc, ChatState>(
        'should not emit anything when no conversations exist and already in initial state',
        build: () => chatBloc,
        act: (bloc) => bloc.add(LoadConversations()),
        expect: () => [],
      );
    });

    group('SendMessage', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatLoaded with error message when no active conversation',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const SendMessage(content: 'Hello AI')),
        expect: () => [
          isA<ChatLoaded>(),
        ],
      );
    });

    group('LoadConversation', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatError when conversation not found',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const LoadConversation('non-existent')),
        expect: () => [
          isA<ChatError>(),
        ],
      );
    });

    group('UpdateConversationTitle', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatError when conversation not found',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const UpdateConversationTitle(
          conversationId: 'test-id',
          newTitle: 'New Title',
        )),
        expect: () => [
          isA<ChatError>(),
        ],
      );
    });

    group('ArchiveConversation', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatError when conversation not found',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const ArchiveConversation('test-id')),
        expect: () => [
          isA<ChatError>(),
        ],
      );
    });

    group('DeleteConversation', () {
      blocTest<ChatBloc, ChatState>(
        'should emit ChatError when conversation not found',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const DeleteConversation('test-id')),
        expect: () => [
          isA<ChatError>(),
        ],
      );
    });

    group('UpdateStreamingMessage', () {
      blocTest<ChatBloc, ChatState>(
        'should not emit anything when no active conversation',
        build: () => chatBloc,
        act: (bloc) => bloc.add(const UpdateStreamingMessage(token: 'Hello')),
        expect: () => [],
      );
    });
  });
}
