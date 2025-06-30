// This service integrates flutter_gemma for local LLM inference.
// Ensure you have a compatible Gemma model file (e.g., gemma-2b-it-q4_k_m.bin) at the expected path.

import 'dart:async';
import 'dart:io';

import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart'
    show
        FlutterGemmaPlugin,
        InferenceModel,
        ModelType,
        PreferredBackend,
        Message;
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:path_provider/path_provider.dart';

class LLMService {
  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  InferenceModel? _model;
  bool _isLoading = false;
  bool _isReady = false;
  String? _modelPath;

  /// Initialize and load the Gemma model from the given path (or default location)
  Future<void> initialize({String? modelPath}) async {
    if (_isReady || _isLoading) return;
    _isLoading = true;
    try {
      // Use provided modelPath or default app directory
      _modelPath = modelPath ?? await _getDefaultModelPath();
      print('[LLMService] Model path: $_modelPath');
      final modelFile = File(_modelPath!);
      if (await modelFile.exists()) {
        final size = await modelFile.length();
        print(
            '[LLMService] Model file exists. Size: ${size / (1024 * 1024)} MB');
      } else {
        print('[LLMService] Model file does NOT exist at path: $_modelPath');
      }
      // Only load if not already loaded
      if (_model == null) {
        _model = await FlutterGemmaPlugin.instance.createModel(
          modelType: ModelType.gemmaIt, // Use Gemma 2B IT for chat
          preferredBackend: PreferredBackend.gpu, // Use GPU if available
          maxTokens: 1024,
        );
      }
      _isReady = true;
    } catch (e) {
      _isReady = false;
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Get the default model path (e.g., app documents directory + /gemma2b/model.bin)
  Future<String> _getDefaultModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/gemma2b/model.bin';
  }

  /// Check if the model is ready
  Future<bool> isReady() async {
    return _isReady;
  }

  /// Generate a response for a chat message (single-turn, not streaming)
  Future<String> processMessage(String message,
      {String? agentPrompt, String? fileContext}) async {
    if (!_isReady) {
      throw Exception('LLM model not loaded. Call initialize() first.');
    }
    // Compose prompt with agent or file context if provided
    String prompt = message;
    if (agentPrompt != null) {
      prompt = '$agentPrompt\n$message';
    } else if (fileContext != null) {
      prompt = 'Document context: $fileContext\n$message';
    }
    final session = await _model!.createSession();
    await session.addQueryChunk(Message.text(text: prompt, isUser: true));
    final response = await session.getResponse();
    await session.close();
    return response;
  }

  /// Stream response for real-time output (token streaming)
  Stream<String> streamResponse(String message,
      {String? agentPrompt, String? fileContext}) async* {
    if (!_isReady) {
      throw Exception('LLM model not loaded. Call initialize() first.');
    }
    String prompt = message;
    if (agentPrompt != null) {
      prompt = '$agentPrompt\n$message';
    } else if (fileContext != null) {
      prompt = 'Document context: $fileContext\n$message';
    }
    final session = await _model!.createSession();
    await session.addQueryChunk(Message.text(text: prompt, isUser: true));
    await for (final token in session.getResponseAsync()) {
      yield token;
    }
    await session.close();
  }

  /// Get model information
  Map<String, dynamic> getModelInfo() {
    return {
      'name': 'Gemma 2B',
      'version': 'real',
      'parameters': '2B',
      'context_length': 8192,
      'status': _isReady ? 'ready' : 'not ready',
      'model_path': _modelPath,
    };
  }
}
