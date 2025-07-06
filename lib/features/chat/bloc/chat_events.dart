import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class CreateNewConversation extends ChatEvent {
  final String title;

  const CreateNewConversation({required this.title});

  @override
  List<Object?> get props => [title];
}

class SendMessage extends ChatEvent {
  final String content;

  const SendMessage({required this.content});

  @override
  List<Object?> get props => [content];
}

class UpdateStreamingMessage extends ChatEvent {
  final String token;

  const UpdateStreamingMessage({required this.token});

  @override
  List<Object?> get props => [token];
}

class LoadConversation extends ChatEvent {
  final String conversationId;

  const LoadConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class UpdateConversationTitle extends ChatEvent {
  final String conversationId;
  final String newTitle;

  const UpdateConversationTitle({
    required this.conversationId,
    required this.newTitle,
  });

  @override
  List<Object?> get props => [conversationId, newTitle];
}

class ArchiveConversation extends ChatEvent {
  final String conversationId;

  const ArchiveConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class DeleteConversation extends ChatEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class LoadConversations extends ChatEvent {}

class SearchConversations extends ChatEvent {
  final String query;

  const SearchConversations(this.query);

  @override
  List<Object?> get props => [query];
}

class ExportConversation extends ChatEvent {
  final String conversationId;
  final String format; // 'txt', 'pdf', 'json'

  const ExportConversation({
    required this.conversationId,
    required this.format,
  });

  @override
  List<Object?> get props => [conversationId, format];
}

class ClearConversationHistory extends ChatEvent {}

class ClearCurrentConversation extends ChatEvent {}

class ClearAllConversations extends ChatEvent {}

class AddFileContext extends ChatEvent {
  final String fileId;
  final String fileContent;

  const AddFileContext({
    required this.fileId,
    required this.fileContent,
  });

  @override
  List<Object?> get props => [fileId, fileContent];
}

class RemoveFileContext extends ChatEvent {
  final String fileId;

  const RemoveFileContext(this.fileId);

  @override
  List<Object?> get props => [fileId];
}
