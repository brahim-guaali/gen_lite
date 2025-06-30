import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

enum MessageStatus {
  sending,
  sent,
  error,
}

class Message extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final String? conversationId;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.conversationId,
    this.metadata,
  });

  factory Message.create({
    required String content,
    required MessageRole role,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: const Uuid().v4(),
      content: content,
      role: role,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      metadata: metadata,
    );
  }

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'conversationId': conversationId,
      'metadata': metadata,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      conversationId: json['conversationId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        role,
        timestamp,
        status,
        conversationId,
        metadata,
      ];
}
