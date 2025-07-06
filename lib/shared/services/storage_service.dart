import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/chat/bloc/chat_states.dart';
import '../../features/file_management/models/file_model.dart';
import '../../features/settings/models/agent_model.dart';

class StorageService {
  static const String _conversationsBox = 'conversations';
  static const String _filesBox = 'files';
  static const String _agentsBox = 'agents';
  static const String _settingsBox = 'settings';

  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    await Hive.openBox(_conversationsBox);
    await Hive.openBox(_filesBox);
    await Hive.openBox(_agentsBox);
    await Hive.openBox(_settingsBox);
  }

  // Conversation Storage
  static Future<void> saveConversation(ChatLoaded conversation) async {
    final box = Hive.box(_conversationsBox);
    final key = conversation.currentConversation.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(key, {
      'id': key,
      'title': conversation.currentConversation.title ?? 'New Conversation',
      'messages': conversation.currentConversation.messages
              .map((m) => m.toJson())
              .toList() ??
          [],
      'createdAt':
          conversation.currentConversation.createdAt.toIso8601String() ??
              DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic> _deepConvertKeysToString(
      Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _deepConvertKeysToString(value));
      } else if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((item) {
            if (item is Map) {
              return _deepConvertKeysToString(item);
            }
            return item;
          }).toList(),
        );
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> loadConversations() async {
    final box = Hive.box(_conversationsBox);
    final List<Map<String, dynamic>> conversations = [];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        conversations
            .add(_deepConvertKeysToString(Map<dynamic, dynamic>.from(data)));
      }
    }

    return conversations;
  }

  static Future<void> deleteConversation(String id) async {
    final box = Hive.box(_conversationsBox);
    await box.delete(id);
  }

  static Future<void> updateConversationTitle(
      String id, String newTitle) async {
    final box = Hive.box(_conversationsBox);
    final data = box.get(id);
    if (data != null) {
      data['title'] = newTitle;
      data['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, data);
    }
  }

  // File Storage
  static Future<void> saveFile(FileModel file) async {
    final box = Hive.box(_filesBox);
    await box.put(file.id, file.toJson());
  }

  static Future<List<FileModel>> loadFiles() async {
    final box = Hive.box(_filesBox);
    final List<FileModel> files = [];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          files.add(FileModel.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // Skip corrupted data
          continue;
        }
      }
    }

    return files;
  }

  static Future<void> deleteFile(String id) async {
    final box = Hive.box(_filesBox);
    await box.delete(id);
  }

  static Future<void> updateFile(FileModel file) async {
    final box = Hive.box(_filesBox);
    await box.put(file.id, file.toJson());
  }

  // Agent Storage
  static Future<void> saveAgent(AgentModel agent) async {
    final box = Hive.box(_agentsBox);
    await box.put(agent.id, agent.toJson());
  }

  static Future<List<AgentModel>> loadAgents() async {
    final box = Hive.box(_agentsBox);
    final List<AgentModel> agents = [];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          agents.add(AgentModel.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // Skip corrupted data
          continue;
        }
      }
    }

    return agents;
  }

  static Future<void> deleteAgent(String id) async {
    final box = Hive.box(_agentsBox);
    await box.delete(id);
  }

  static Future<void> updateAgent(AgentModel agent) async {
    final box = Hive.box(_agentsBox);
    await box.put(agent.id, agent.toJson());
  }

  // Settings Storage
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  static Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    final box = Hive.box(_settingsBox);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    final box = Hive.box(_settingsBox);
    await box.delete(key);
  }

  // Search functionality
  static Future<List<Map<String, dynamic>>> searchConversations(
      String query) async {
    final conversations = await loadConversations();
    final lowercaseQuery = query.toLowerCase();

    return conversations.where((conversation) {
      final title = conversation['title']?.toString().toLowerCase() ?? '';
      final messages = conversation['messages'] as List? ?? [];

      // Search in title
      if (title.contains(lowercaseQuery)) return true;

      // Search in messages
      for (final message in messages) {
        final content = message['content']?.toString().toLowerCase() ?? '';
        if (content.contains(lowercaseQuery)) return true;
      }

      return false;
    }).toList();
  }

  // Export functionality
  static String exportConversationToText(Map<String, dynamic> conversation) {
    final title = conversation['title'] ?? 'Conversation';
    final messages = conversation['messages'] as List? ?? [];

    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln();
    buffer.writeln('Generated on: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    for (final message in messages) {
      final role = message['role'] ?? 'user';
      final content = message['content'] ?? '';
      final timestamp = message['timestamp'] ?? '';

      buffer.writeln('## ${role.toUpperCase()}');
      if (timestamp.isNotEmpty) {
        buffer.writeln('*$timestamp*');
      }
      buffer.writeln();
      buffer.writeln(content);
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String exportConversationToJson(Map<String, dynamic> conversation) {
    return jsonEncode(conversation);
  }

  // Cleanup
  static Future<void> clearAllData() async {
    await Hive.box(_conversationsBox).clear();
    await Hive.box(_filesBox).clear();
    await Hive.box(_agentsBox).clear();
    await Hive.box(_settingsBox).clear();
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
