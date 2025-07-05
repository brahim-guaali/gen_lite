import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_events.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import 'package:genlite/shared/models/message.dart';
import 'package:genlite/shared/models/conversation.dart';
import 'package:genlite/features/settings/models/agent_model.dart';
import 'package:genlite/shared/services/chat_service.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/shared/services/llm_service.dart';
import 'package:genlite/shared/services/tts_service.dart';
import '../../../test_config.dart';

void main() {
  group('ChatBloc', () {
    late ChatBloc chatBloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    setUp(() async {
      // Wait a bit for Hive to be ready
      await Future.delayed(const Duration(milliseconds: 100));
      chatBloc = ChatBloc();
      // Wait for bloc initialization
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      await chatBloc.close();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    test('initial state should be ChatInitial', () {
      expect(chatBloc.state, isA<ChatInitial>());
    });

    group('Event Handling', () {
      test('should handle CreateNewConversation event', () {
        expect(() {
          chatBloc.add(const CreateNewConversation(title: 'Test Conversation'));
        }, returnsNormally);
      });

      test('should handle LoadConversations event', () {
        expect(() {
          chatBloc.add(LoadConversations());
        }, returnsNormally);
      });

      test('should handle SendMessage event', () {
        expect(() {
          chatBloc.add(const SendMessage(content: 'Hello AI'));
        }, returnsNormally);
      });

      test('should handle LoadConversation event', () {
        expect(() {
          chatBloc.add(const LoadConversation('test-id'));
        }, returnsNormally);
      });

      test('should handle UpdateConversationTitle event', () {
        expect(() {
          chatBloc.add(const UpdateConversationTitle(
            conversationId: 'test-id',
            newTitle: 'New Title',
          ));
        }, returnsNormally);
      });

      test('should handle ArchiveConversation event', () {
        expect(() {
          chatBloc.add(const ArchiveConversation('test-id'));
        }, returnsNormally);
      });

      test('should handle DeleteConversation event', () {
        expect(() {
          chatBloc.add(const DeleteConversation('test-id'));
        }, returnsNormally);
      });

      test('should handle UpdateStreamingMessage event', () {
        expect(() {
          chatBloc.add(const UpdateStreamingMessage(token: 'Hello'));
        }, returnsNormally);
      });
    });

    group('State Transitions', () {
      test('should handle multiple events without crashing', () {
        expect(() {
          chatBloc.add(const CreateNewConversation(title: 'Test'));
          chatBloc.add(LoadConversations());
          chatBloc.add(const SendMessage(content: 'Hello'));
        }, returnsNormally);
      });

      test('should maintain state consistency', () async {
        chatBloc.add(const CreateNewConversation(title: 'Test'));
        await Future.delayed(const Duration(milliseconds: 200));
        expect(chatBloc.state, isA<ChatLoaded>());
      });
    });

    group('Event Properties', () {
      test('CreateNewConversation should have correct title property', () {
        const event = CreateNewConversation(title: 'Test Conversation');
        expect(event.title, equals('Test Conversation'));
      });

      test('SendMessage should have correct content property', () {
        const event = SendMessage(content: 'Hello AI');
        expect(event.content, equals('Hello AI'));
      });

      test('LoadConversation should have correct conversationId property', () {
        const event = LoadConversation('test-conversation-id');
        expect(event.conversationId, equals('test-conversation-id'));
      });

      test('UpdateConversationTitle should have correct properties', () {
        const event = UpdateConversationTitle(
          conversationId: 'test-id',
          newTitle: 'New Title',
        );
        expect(event.conversationId, equals('test-id'));
        expect(event.newTitle, equals('New Title'));
      });

      test('UpdateStreamingMessage should have correct token property', () {
        const event = UpdateStreamingMessage(token: 'Hello');
        expect(event.token, equals('Hello'));
      });
    });
  });
}
