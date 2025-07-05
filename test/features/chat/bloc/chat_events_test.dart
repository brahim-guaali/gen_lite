import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/chat/bloc/chat_events.dart';

void main() {
  group('ChatEvent', () {
    group('CreateNewConversation', () {
      test('should create with title', () {
        const event = CreateNewConversation(title: 'Test Conversation');
        expect(event.title, 'Test Conversation');
      });

      test('should be equatable', () {
        const event1 = CreateNewConversation(title: 'Conversation 1');
        const event2 = CreateNewConversation(title: 'Conversation 1');
        const event3 = CreateNewConversation(title: 'Conversation 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = CreateNewConversation(title: 'Test Conversation');
        expect(event.props, ['Test Conversation']);
      });
    });

    group('LoadConversations', () {
      test('should be equatable', () {
        final event1 = LoadConversations();
        final event2 = LoadConversations();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = LoadConversations();
        expect(event.props, isEmpty);
      });
    });

    group('LoadConversation', () {
      test('should create with conversationId', () {
        const event = LoadConversation('conversation-1');
        expect(event.conversationId, 'conversation-1');
      });

      test('should be equatable', () {
        const event1 = LoadConversation('conversation-1');
        const event2 = LoadConversation('conversation-1');
        const event3 = LoadConversation('conversation-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = LoadConversation('conversation-1');
        expect(event.props, ['conversation-1']);
      });
    });

    group('SendMessage', () {
      test('should create with content', () {
        const event = SendMessage(content: 'Hello AI');
        expect(event.content, 'Hello AI');
      });

      test('should be equatable', () {
        const event1 = SendMessage(content: 'Message 1');
        const event2 = SendMessage(content: 'Message 1');
        const event3 = SendMessage(content: 'Message 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = SendMessage(content: 'Hello AI');
        expect(event.props, ['Hello AI']);
      });
    });

    group('UpdateConversationTitle', () {
      test('should create with conversationId and new title', () {
        const event = UpdateConversationTitle(
          conversationId: 'conversation-1',
          newTitle: 'New Title',
        );
        expect(event.conversationId, 'conversation-1');
        expect(event.newTitle, 'New Title');
      });

      test('should be equatable', () {
        const event1 = UpdateConversationTitle(
          conversationId: 'conversation-1',
          newTitle: 'Title 1',
        );
        const event2 = UpdateConversationTitle(
          conversationId: 'conversation-1',
          newTitle: 'Title 1',
        );
        const event3 = UpdateConversationTitle(
          conversationId: 'conversation-2',
          newTitle: 'Title 2',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = UpdateConversationTitle(
          conversationId: 'conversation-1',
          newTitle: 'New Title',
        );
        expect(event.props, ['conversation-1', 'New Title']);
      });
    });

    group('ArchiveConversation', () {
      test('should create with conversationId', () {
        const event = ArchiveConversation('conversation-1');
        expect(event.conversationId, 'conversation-1');
      });

      test('should be equatable', () {
        const event1 = ArchiveConversation('conversation-1');
        const event2 = ArchiveConversation('conversation-1');
        const event3 = ArchiveConversation('conversation-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = ArchiveConversation('conversation-1');
        expect(event.props, ['conversation-1']);
      });
    });

    group('DeleteConversation', () {
      test('should create with conversationId', () {
        const event = DeleteConversation('conversation-1');
        expect(event.conversationId, 'conversation-1');
      });

      test('should be equatable', () {
        const event1 = DeleteConversation('conversation-1');
        const event2 = DeleteConversation('conversation-1');
        const event3 = DeleteConversation('conversation-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = DeleteConversation('conversation-1');
        expect(event.props, ['conversation-1']);
      });
    });

    group('UpdateStreamingMessage', () {
      test('should create with token', () {
        const event = UpdateStreamingMessage(token: 'Hello');
        expect(event.token, 'Hello');
      });

      test('should be equatable', () {
        const event1 = UpdateStreamingMessage(token: 'Token 1');
        const event2 = UpdateStreamingMessage(token: 'Token 1');
        const event3 = UpdateStreamingMessage(token: 'Token 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = UpdateStreamingMessage(token: 'Hello');
        expect(event.props, ['Hello']);
      });
    });

    group('ClearConversationHistory', () {
      test('should be equatable', () {
        final event1 = ClearConversationHistory();
        final event2 = ClearConversationHistory();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = ClearConversationHistory();
        expect(event.props, isEmpty);
      });
    });

    group('ExportConversation', () {
      test('should create with conversationId and format', () {
        const event = ExportConversation(
          conversationId: 'conversation-1',
          format: 'json',
        );
        expect(event.conversationId, 'conversation-1');
        expect(event.format, 'json');
      });

      test('should be equatable', () {
        const event1 = ExportConversation(
          conversationId: 'conversation-1',
          format: 'json',
        );
        const event2 = ExportConversation(
          conversationId: 'conversation-1',
          format: 'json',
        );
        const event3 = ExportConversation(
          conversationId: 'conversation-2',
          format: 'txt',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = ExportConversation(
          conversationId: 'conversation-1',
          format: 'json',
        );
        expect(event.props, ['conversation-1', 'json']);
      });
    });

    group('SearchConversations', () {
      test('should create with query', () {
        const event = SearchConversations('test query');
        expect(event.query, 'test query');
      });

      test('should be equatable', () {
        const event1 = SearchConversations('query 1');
        const event2 = SearchConversations('query 1');
        const event3 = SearchConversations('query 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = SearchConversations('test query');
        expect(event.props, ['test query']);
      });
    });

    group('AddFileContext', () {
      test('should create with fileId and fileContent', () {
        const event = AddFileContext(
          fileId: 'file-1',
          fileContent: 'file content',
        );
        expect(event.fileId, 'file-1');
        expect(event.fileContent, 'file content');
      });

      test('should be equatable', () {
        const event1 = AddFileContext(
          fileId: 'file-1',
          fileContent: 'content 1',
        );
        const event2 = AddFileContext(
          fileId: 'file-1',
          fileContent: 'content 1',
        );
        const event3 = AddFileContext(
          fileId: 'file-2',
          fileContent: 'content 2',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = AddFileContext(
          fileId: 'file-1',
          fileContent: 'file content',
        );
        expect(event.props, ['file-1', 'file content']);
      });
    });

    group('RemoveFileContext', () {
      test('should create with fileId', () {
        const event = RemoveFileContext('file-1');
        expect(event.fileId, 'file-1');
      });

      test('should be equatable', () {
        const event1 = RemoveFileContext('file-1');
        const event2 = RemoveFileContext('file-1');
        const event3 = RemoveFileContext('file-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = RemoveFileContext('file-1');
        expect(event.props, ['file-1']);
      });
    });
  });
}
