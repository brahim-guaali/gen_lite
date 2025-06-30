import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/models/message.dart';

void main() {
  group('Message', () {
    test('should create message with required parameters', () {
      const content = 'Test message';
      const role = MessageRole.user;
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);

      final message = Message(
        id: 'test-id',
        content: content,
        role: role,
        timestamp: timestamp,
      );

      expect(message.id, equals('test-id'));
      expect(message.content, equals(content));
      expect(message.role, equals(role));
      expect(message.timestamp, equals(timestamp));
      expect(message.status, equals(MessageStatus.sent));
    });

    test('should create message using factory method', () {
      const content = 'Test message';
      const role = MessageRole.assistant;
      const conversationId = 'conv-123';

      final message = Message.create(
        content: content,
        role: role,
        conversationId: conversationId,
      );

      expect(message.content, equals(content));
      expect(message.role, equals(role));
      expect(message.conversationId, equals(conversationId));
      expect(message.id, isNotEmpty);
      expect(message.timestamp, isA<DateTime>());
      expect(message.status, equals(MessageStatus.sent));
    });

    test('should serialize and deserialize message', () {
      final originalMessage = Message(
        id: 'test-id',
        content: 'Test message content',
        role: MessageRole.assistant,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        status: MessageStatus.sent,
        conversationId: 'conv-123',
        metadata: {'key': 'value'},
      );

      final json = originalMessage.toJson();
      final deserializedMessage = Message.fromJson(json);

      expect(deserializedMessage.id, equals(originalMessage.id));
      expect(deserializedMessage.content, equals(originalMessage.content));
      expect(deserializedMessage.role, equals(originalMessage.role));
      expect(deserializedMessage.timestamp, equals(originalMessage.timestamp));
      expect(deserializedMessage.status, equals(originalMessage.status));
      expect(deserializedMessage.conversationId,
          equals(originalMessage.conversationId));
      expect(deserializedMessage.metadata, equals(originalMessage.metadata));
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
