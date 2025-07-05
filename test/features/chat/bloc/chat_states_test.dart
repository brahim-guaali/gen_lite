import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/chat/bloc/chat_states.dart';
import 'package:genlite/shared/models/conversation.dart';

void main() {
  group('ChatState', () {
    group('ChatInitial', () {
      test('should be equatable', () {
        final state1 = ChatInitial();
        final state2 = ChatInitial();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = ChatInitial();
        expect(state.props, isEmpty);
      });
    });

    group('ChatLoading', () {
      test('should be equatable', () {
        final state1 = ChatLoading();
        final state2 = ChatLoading();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = ChatLoading();
        expect(state.props, isEmpty);
      });
    });

    group('ChatLoaded', () {
      late Conversation currentConversation;
      late List<Conversation> conversations;

      setUp(() {
        currentConversation = Conversation(
          id: 'conversation-1',
          title: 'Test Conversation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );
        conversations = [
          currentConversation,
          Conversation(
            id: 'conversation-2',
            title: 'Test Conversation 2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            messages: [],
          ),
        ];
      });

      test('should create with current conversation and conversations', () {
        final state = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
        );
        expect(state.currentConversation, currentConversation);
        expect(state.conversations, conversations);
        expect(state.isProcessing, false);
      });

      test('should create with isProcessing flag', () {
        final state = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
          isProcessing: true,
        );
        expect(state.isProcessing, true);
      });

      test('should be equatable', () {
        final state1 = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
        );
        final state2 = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
        );
        final state3 = ChatLoaded(
          currentConversation: currentConversation,
          conversations: [currentConversation],
        );

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final state = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
        );
        expect(state.props, [currentConversation, conversations, false]);
      });

      test('should copy with new values', () {
        final state = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
        );

        final newConversation = Conversation(
          id: 'conversation-3',
          title: 'New Conversation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );

        final copiedState = state.copyWith(
          currentConversation: newConversation,
          isProcessing: true,
        );

        expect(copiedState.currentConversation, newConversation);
        expect(copiedState.conversations, conversations);
        expect(copiedState.isProcessing, true);
      });

      test('should copy with partial values', () {
        final state = ChatLoaded(
          currentConversation: currentConversation,
          conversations: conversations,
          isProcessing: true,
        );

        final copiedState = state.copyWith(isProcessing: false);

        expect(copiedState.currentConversation, currentConversation);
        expect(copiedState.conversations, conversations);
        expect(copiedState.isProcessing, false);
      });
    });

    group('ChatError', () {
      test('should create with message', () {
        const message = 'Error occurred';
        final state = ChatError(message);
        expect(state.message, message);
      });

      test('should be equatable', () {
        final state1 = ChatError('Error 1');
        final state2 = ChatError('Error 1');
        final state3 = ChatError('Error 2');

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const message = 'Error occurred';
        final state = ChatError(message);
        expect(state.props, [message]);
      });
    });
  });
}
