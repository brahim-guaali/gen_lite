import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'message.dart';

class Conversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;
  final Map<String, dynamic>? metadata;
  final bool isArchived;

  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.metadata,
    this.isArchived = false,
  });

  factory Conversation.create({
    required String title,
    List<Message> messages = const [],
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return Conversation(
      id: const Uuid().v4(),
      title: title,
      createdAt: now,
      updatedAt: now,
      messages: messages,
      metadata: metadata,
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    Map<String, dynamic>? metadata,
    bool? isArchived,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      metadata: metadata ?? this.metadata,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Conversation addMessage(Message message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  Conversation updateTitle(String newTitle) {
    return copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
  }

  Conversation archive() {
    return copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
  }

  Conversation unarchive() {
    return copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
  }

  int get messageCount => messages.length;

  bool get isEmpty => messages.isEmpty;

  bool get hasUserMessages => messages.any((m) => m.role == MessageRole.user);

  bool get hasAssistantMessages =>
      messages.any((m) => m.role == MessageRole.assistant);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'metadata': metadata,
      'isArchived': isArchived,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        updatedAt,
        messages,
        metadata,
        isArchived,
      ];
}
