// This service integrates flutter_gemma for local LLM inference.
// Ensure you have a compatible Gemma model file (e.g., gemma-3n-E4B-it-int4.task) at the expected path.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/flutter_gemma.dart'
    show FlutterGemmaPlugin, InferenceModel, Message;
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
    if (_isLoading) {
      print('[LLMService] Already initializing...');
      return;
    }

    if (_isReady && _model != null) {
      print('[LLMService] Model already initialized');
      return;
    }

    _isLoading = true;
    print('[LLMService] Initializing LLM service...');

    try {
      // Use provided model path or default to the expected location
      _modelPath = modelPath ?? await _getDefaultModelPath();

      print('[LLMService] Using model path: $_modelPath');

      // Check if model file exists
      final modelFile = File(_modelPath!);
      if (!await modelFile.exists()) {
        throw Exception('Model file not found at: $_modelPath');
      }

      final fileSize = await modelFile.length();
      print('[LLMService] Model file size: ${_formatBytes(fileSize)}');

      // Initialize the FlutterGemma plugin
      final gemma = FlutterGemmaPlugin.instance;

      // Register the model path with the modelManager before loading
      print('[LLMService] Registering model path with modelManager...');
      await gemma.modelManager.setModelPath(_modelPath!);
      print('[LLMService] Model path registered successfully');

      // Create model with the correct type for Gemma 3N
      _model = await gemma.createModel(
        modelType: ModelType.gemmaIt,
        supportImage: true,
        maxTokens: 2048,
      );

      print('[LLMService] Model created successfully');
      _isReady = true;
      _isLoading = false;

      print('[LLMService] LLM service initialized successfully');
    } catch (e) {
      _isLoading = false;
      _isReady = false;
      print('[LLMService] Error initializing LLM service: $e');
      rethrow;
    }
  }

  /// Get the default model path based on the expected location
  Future<String> _getDefaultModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/gemma-3n-E4B-it-int4.task';
  }

  /// Check if the service is ready to process requests
  bool get isReady => _isReady && _model != null;

  /// Get the current model instance
  InferenceModel? get model => _model;

  /// Create a new chat session
  Future<InferenceChat?> createChat({bool supportImage = true}) async {
    if (!isReady) {
      print('[LLMService] Service not ready. Call initialize() first.');
      return null;
    }

    try {
      final chat = await _model!.createChat(supportImage: supportImage);
      print('[LLMService] Chat session created successfully');
      return chat;
    } catch (e) {
      print('[LLMService] Error creating chat session: $e');
      return null;
    }
  }

  /// Process a text message with streaming support
  Future<String?> processMessage(
    String message, {
    InferenceChat? chat,
    Function(String token)? onTokenReceived,
  }) async {
    if (!isReady) {
      print('[LLMService] Service not ready. Call initialize() first.');
      return null;
    }

    try {
      print(
          '[LLMService] Processing message: "${message.substring(0, message.length > 50 ? 50 : message.length)}..."');

      final chatSession = chat ?? await createChat();
      if (chatSession == null) {
        throw Exception('Failed to create chat session');
      }

      print('[LLMService] Chat session ready, creating message object...');

      // Create message object
      final messageObj = Message(text: message, isUser: true);

      print('[LLMService] Adding message to chat...');
      // Add message to chat
      await chatSession.addQueryChunk(messageObj);

      print('[LLMService] Starting response generation...');
      // Generate response
      final responseStream = chatSession.generateChatResponseAsync();

      String response = '';
      bool hasReceivedTokens = false;

      // Process stream with timeout
      try {
        await for (final token in responseStream.timeout(
          const Duration(seconds: 30),
        )) {
          hasReceivedTokens = true;
          response += token;

          // Call the callback function if provided
          if (onTokenReceived != null) {
            onTokenReceived(token);
          }

          print('[LLMService] Received token: "$token"');
        }
      } on TimeoutException {
        print('[LLMService] Response generation timed out after 30 seconds');
        return 'I apologize, but the response is taking too long. Please try a shorter message or try again later.';
      }

      if (!hasReceivedTokens) {
        print('[LLMService] No tokens received from response stream');
        return 'I apologize, but I was unable to generate a response. Please try again.';
      }

      print(
          '[LLMService] Response generation completed. Total response length: ${response.length}');
      return response;
    } catch (e) {
      print('[LLMService] Error processing message: $e');
      return 'Sorry, I encountered an error while processing your message. Please try again.';
    }
  }

  /// Process a message with image
  Future<String?> processMessageWithImage(String message, Uint8List imageBytes,
      {InferenceChat? chat}) async {
    if (!isReady) {
      print('[LLMService] Service not ready. Call initialize() first.');
      return null;
    }

    try {
      final chatSession = chat ?? await createChat(supportImage: true);
      if (chatSession == null) {
        throw Exception('Failed to create chat session');
      }

      // Create message object with image
      final messageObj = Message.withImage(
        text: message,
        imageBytes: imageBytes,
        isUser: true,
      );

      // Add message to chat
      await chatSession.addQueryChunk(messageObj);

      // Generate response
      final responseStream = chatSession.generateChatResponseAsync();

      String response = '';
      await for (final token in responseStream) {
        response += token;
      }

      return response;
    } catch (e) {
      print('[LLMService] Error processing message with image: $e');
      return null;
    }
  }

  /// Dispose of the model and clean up resources
  Future<void> dispose() async {
    try {
      _model = null;
      _isReady = false;
      _isLoading = false;
      print('[LLMService] Service disposed successfully');
    } catch (e) {
      print('[LLMService] Error disposing service: $e');
    }
  }

  /// Get model information
  Map<String, dynamic> getModelInfo() {
    return {
      'name': 'Gemma 3N',
      'version': '3N',
      'parameters': '3B',
      'context_length': 8192,
      'status': _isReady ? 'ready' : 'not ready',
      'model_path': _modelPath,
    };
  }

  /// Helper method to format bytes
  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }
}
