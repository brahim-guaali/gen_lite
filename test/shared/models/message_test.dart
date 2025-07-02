import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/models/message.dart';

void main() {
  group('Message Model', () {
    test('should create message with required fields', () {
      final message = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      expect(message.content, equals('Test message'));
      expect(message.role, equals(MessageRole.user));
      expect(message.conversationId, equals('test-conversation-id'));
      expect(message.status, equals(MessageStatus.sent));
      expect(message.id, isNotEmpty);
      expect(message.timestamp, isNotNull);
    });

    test('should create assistant message', () {
      final message = Message.create(
        content: 'AI response',
        role: MessageRole.assistant,
        conversationId: 'test-conversation-id',
      );

      expect(message.role, equals(MessageRole.assistant));
      expect(message.content, equals('AI response'));
    });

    test('should copy message with new values', () {
      final original = Message.create(
        content: 'Original message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      final copied = original.copyWith(
        content: 'Updated message',
        status: MessageStatus.sending,
      );

      expect(copied.id, equals(original.id));
      expect(copied.content, equals('Updated message'));
      expect(copied.status, equals(MessageStatus.sending));
      expect(copied.role, equals(original.role));
      expect(copied.conversationId, equals(original.conversationId));
    });

    test('should handle empty content', () {
      final message = Message.create(
        content: '',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      expect(message.content, equals(''));
    });

    test('should handle long content', () {
      final longContent = 'A' * 1000;
      final message = Message.create(
        content: longContent,
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      expect(message.content, equals(longContent));
    });

    test('should have unique IDs', () {
      final message1 = Message.create(
        content: 'Message 1',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      final message2 = Message.create(
        content: 'Message 2',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      expect(message1.id, isNot(equals(message2.id)));
    });

    test('should handle different message statuses', () {
      final message = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      final sendingMessage = message.copyWith(status: MessageStatus.sending);
      final sentMessage = message.copyWith(status: MessageStatus.sent);
      final errorMessage = message.copyWith(status: MessageStatus.error);

      expect(sendingMessage.status, equals(MessageStatus.sending));
      expect(sentMessage.status, equals(MessageStatus.sent));
      expect(errorMessage.status, equals(MessageStatus.error));
    });

    test('should handle metadata', () {
      final metadata = {'key': 'value', 'number': 42};
      final message = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
        metadata: metadata,
      );

      expect(message.metadata, equals(metadata));
    });

    test('should handle null metadata', () {
      final message = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      expect(message.metadata, isNull);
    });

    test('should create message with custom timestamp', () {
      final customTimestamp = DateTime(2023, 1, 1, 12, 0, 0);
      final message = Message(
        id: 'test-id',
        content: 'Test message',
        role: MessageRole.user,
        timestamp: customTimestamp,
        status: MessageStatus.sent,
        conversationId: 'test-conversation-id',
        metadata: null,
      );

      expect(message.timestamp, equals(customTimestamp));
    });

    test('should handle equality correctly', () {
      final message1 = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      final message2 = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      // Messages with different IDs should not be equal
      expect(message1, isNot(equals(message2)));
    });

    test('should handle toString correctly', () {
      final message = Message.create(
        content: 'Test message',
        role: MessageRole.user,
        conversationId: 'test-conversation-id',
      );

      final string = message.toString();
      expect(string, contains('Test message'));
      expect(string, contains('user'));
      expect(string, contains('test-conversation-id'));
    });
  });

  group('MessageRole', () {
    test('should have correct enum values', () {
      expect(MessageRole.values, hasLength(3));
      expect(MessageRole.user, isA<MessageRole>());
      expect(MessageRole.assistant, isA<MessageRole>());
      expect(MessageRole.system, isA<MessageRole>());
    });
  });

  group('MessageStatus', () {
    test('should have correct enum values', () {
      expect(MessageStatus.values, hasLength(3));
      expect(MessageStatus.sending, isA<MessageStatus>());
      expect(MessageStatus.sent, isA<MessageStatus>());
      expect(MessageStatus.error, isA<MessageStatus>());
    });
  });
}
