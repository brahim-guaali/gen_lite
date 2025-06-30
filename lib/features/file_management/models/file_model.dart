import 'package:equatable/equatable.dart';

class FileModel extends Equatable {
  final String id;
  final String name;
  final String path;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final String? content;
  final bool isProcessed;

  const FileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.content,
    this.isProcessed = false,
  });

  FileModel copyWith({
    String? id,
    String? name,
    String? path,
    String? type,
    int? size,
    DateTime? uploadedAt,
    String? content,
    bool? isProcessed,
  }) {
    return FileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      content: content ?? this.content,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
      'content': content,
      'isProcessed': isProcessed,
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      content: json['content'] as String?,
      isProcessed: json['isProcessed'] as bool? ?? false,
    );
  }

  factory FileModel.create({
    required String name,
    required String path,
    required String type,
    required int size,
  }) {
    return FileModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      path: path,
      type: type,
      size: size,
      uploadedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        type,
        size,
        uploadedAt,
        content,
        isProcessed,
      ];
}
