import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/models/conversation.dart';
import 'package:genlite/shared/models/message.dart';

void main() {
  group('Conversation Model', () {
    test('should create conversation with required fields', () {
      final conversation = Conversation.create(
        title: 'Test Conversation',
      );

      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.messages, isEmpty);
      expect(conversation.id, isNotEmpty);
      expect(conversation.createdAt, isNotNull);
      expect(conversation.updatedAt, isNotNull);
      expect(conversation.isArchived, isFalse);
    });

    test('should create conversation with custom ID', () {
      final conversation = Conversation(
        id: 'custom-id',
        title: 'Test Conversation',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        messages: const [],
        metadata: null,
        isArchived: false,
      );

      expect(conversation.id, equals('custom-id'));
    });

    test('should add message to conversation', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      final message = Message.create(
        content: 'Hello',
        role: MessageRole.user,
        conversationId: conversation.id,
      );

      final updatedConversation = conversation.addMessage(message);

      expect(updatedConversation.messages.length, equals(1));
      expect(updatedConversation.messages.first, equals(message));
      expect(updatedConversation.updatedAt.isAfter(conversation.updatedAt),
          isTrue);
    });

    test('should add multiple messages to conversation', () {
      final conversation = Conversation.create(title: 'Test Conversation');

      final message1 = Message.create(
        content: 'Hello',
        role: MessageRole.user,
        conversationId: conversation.id,
      );

      final message2 = Message.create(
        content: 'Hi there!',
        role: MessageRole.assistant,
        conversationId: conversation.id,
      );

      final updatedConversation =
          conversation.addMessage(message1).addMessage(message2);

      expect(updatedConversation.messages.length, equals(2));
      expect(updatedConversation.messages.first, equals(message1));
      expect(updatedConversation.messages.last, equals(message2));
    });

    test('should update conversation title', () {
      final conversation = Conversation.create(title: 'Old Title');
      final updatedConversation = conversation.copyWith(title: 'New Title');

      expect(updatedConversation.title, equals('New Title'));
      expect(updatedConversation.id, equals(conversation.id));
      expect(updatedConversation.messages, equals(conversation.messages));
    });

    test('should archive conversation', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      final archivedConversation = conversation.copyWith(isArchived: true);

      expect(archivedConversation.isArchived, isTrue);
      expect(archivedConversation.id, equals(conversation.id));
    });

    test('should set metadata', () {
      final metadata = {'key': 'value', 'number': 42};
      final conversation = Conversation.create(
        title: 'Test Conversation',
        metadata: metadata,
      );

      expect(conversation.metadata, equals(metadata));
    });

    test('should handle empty title', () {
      final conversation = Conversation.create(title: '');

      expect(conversation.title, equals(''));
    });

    test('should handle long title', () {
      final longTitle = 'A' * 100;
      final conversation = Conversation.create(title: longTitle);

      expect(conversation.title, equals(longTitle));
    });

    test('should have unique IDs', () {
      final conversation1 = Conversation.create(title: 'Conversation 1');
      final conversation2 = Conversation.create(title: 'Conversation 2');

      expect(conversation1.id, isNot(equals(conversation2.id)));
    });

    test('should update timestamp when modified', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      final message = Message.create(
        content: 'Hello',
        role: MessageRole.user,
        conversationId: conversation.id,
      );

      final updatedConversation = conversation.addMessage(message);

      expect(updatedConversation.updatedAt.isAfter(conversation.updatedAt),
          isTrue);
    });

    test('should handle conversation with many messages', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      Conversation updatedConversation = conversation;

      for (int i = 0; i < 10; i++) {
        final message = Message.create(
          content: 'Message $i',
          role: i % 2 == 0 ? MessageRole.user : MessageRole.assistant,
          conversationId: conversation.id,
        );
        updatedConversation = updatedConversation.addMessage(message);
      }

      expect(updatedConversation.messages.length, equals(10));
    });

    test('should copy conversation with all fields', () {
      final original = Conversation.create(title: 'Original');
      final message = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: original.id,
      );
      final conversationWithMessage = original.addMessage(message);

      final copied = conversationWithMessage.copyWith(
        title: 'Copied',
        isArchived: true,
        metadata: {'copied': true},
      );

      expect(copied.title, equals('Copied'));
      expect(copied.isArchived, isTrue);
      expect(copied.metadata, equals({'copied': true}));
      expect(copied.messages, equals(conversationWithMessage.messages));
      expect(copied.id, equals(conversationWithMessage.id));
    });

    test('should handle equality correctly', () {
      final conversation1 = Conversation.create(title: 'Test Conversation');
      final conversation2 = Conversation.create(title: 'Test Conversation');

      // Conversations with different IDs should not be equal
      expect(conversation1, isNot(equals(conversation2)));
    });

    test('should handle toString correctly', () {
      final conversation = Conversation.create(title: 'Test Conversation');

      final string = conversation.toString();
      expect(string, contains('Test Conversation'));
      expect(string, contains(conversation.id));
    });

    test('should get conversation summary', () {
      final conversation = Conversation.create(title: 'Test Conversation');

      final message1 = Message.create(
        content: 'Hello, how are you?',
        role: MessageRole.user,
        conversationId: conversation.id,
      );

      final message2 = Message.create(
        content: 'I am doing well, thank you for asking!',
        role: MessageRole.assistant,
        conversationId: conversation.id,
      );

      final conversationWithMessages =
          conversation.addMessage(message1).addMessage(message2);

      expect(conversationWithMessages.messages.length, equals(2));
      expect(
          conversationWithMessages.messages.first.content, contains('Hello'));
      expect(conversationWithMessages.messages.last.content,
          contains('doing well'));
    });

    test('should calculate message count correctly', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      expect(conversation.messageCount, equals(0));

      final message = Message.create(
        content: 'Hello',
        role: MessageRole.user,
        conversationId: conversation.id,
      );
      final updatedConversation = conversation.addMessage(message);
      expect(updatedConversation.messageCount, equals(1));
    });

    test('should check if conversation is empty', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      expect(conversation.isEmpty, isTrue);

      final message = Message.create(
        content: 'Hello',
        role: MessageRole.user,
        conversationId: conversation.id,
      );
      final updatedConversation = conversation.addMessage(message);
      expect(updatedConversation.isEmpty, isFalse);
    });

    test('should check for user messages', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      expect(conversation.hasUserMessages, isFalse);

      final userMessage = Message.create(
        content: 'Hello',
        role: MessageRole.user,
        conversationId: conversation.id,
      );
      final conversationWithUserMessage = conversation.addMessage(userMessage);
      expect(conversationWithUserMessage.hasUserMessages, isTrue);
    });

    test('should check for assistant messages', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      expect(conversation.hasAssistantMessages, isFalse);

      final assistantMessage = Message.create(
        content: 'Hi there!',
        role: MessageRole.assistant,
        conversationId: conversation.id,
      );
      final conversationWithAssistantMessage =
          conversation.addMessage(assistantMessage);
      expect(conversationWithAssistantMessage.hasAssistantMessages, isTrue);
    });

    test('should archive and unarchive conversation', () {
      final conversation = Conversation.create(title: 'Test Conversation');
      expect(conversation.isArchived, isFalse);

      final archivedConversation = conversation.archive();
      expect(archivedConversation.isArchived, isTrue);

      final unarchivedConversation = archivedConversation.unarchive();
      expect(unarchivedConversation.isArchived, isFalse);
    });

    test('should update title using updateTitle method', () {
      final conversation = Conversation.create(title: 'Old Title');
      final updatedConversation = conversation.updateTitle('New Title');

      expect(updatedConversation.title, equals('New Title'));
      expect(updatedConversation.updatedAt.isAfter(conversation.updatedAt),
          isTrue);
    });
  });
}
