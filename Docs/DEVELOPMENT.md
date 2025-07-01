# Development Guide
## GenLite: Implementation and Development Guide

**Version:** 2.0  
**Date:** July 2025  
**Technical Lead:** Brahim Guaali  

---

## 1. Development Setup

### 1.1 Prerequisites
- **Flutter**: 3.2.0 or higher
- **Dart**: 3.0.0 or higher
- **Platforms**: iOS 16.0+, Android 8.0+
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

### 1.2 Environment Setup
```bash
# Clone the repository
git clone https://github.com/brahim-guaali/GenLite.git
cd GenLite

# Install dependencies
flutter pub get

# Set up Hugging Face token
echo "HUGGING_FACE_TOKEN=your_token_here" > .env
```

### 1.3 Platform-Specific Setup

#### iOS Setup
```bash
cd ios
pod install
cd ..
flutter run
```

#### Android Setup
```bash
flutter run
```

---

## 2. Core Services Implementation

### 2.1 LLM Service
**Location**: `lib/shared/services/llm_service.dart`

**Key Methods**:
```dart
class LLMService {
  Future<void> initialize({String? modelPath})
  Future<String> generateResponse(String prompt)
  Future<void> addContext(String context)
  Future<void> dispose()
}
```

**Implementation Details**:
- Uses `flutter_gemma` package for local inference
- Supports streaming responses with token callbacks
- Handles model initialization and cleanup
- Manages conversation context

### 2.2 Enhanced Model Downloader
**Location**: `lib/shared/services/enhanced_model_downloader.dart`

**Key Methods**:
```dart
class EnhancedModelDownloader {
  static Future<String> ensureGemmaModel({
    bool allowResume = true,
    void Function(ProgressInfo info)? onProgress,
  })
  
  static Future<DownloadState?> getDownloadState()
  static Future<void> saveDownloadState(DownloadState state)
}
```

**Features**:
- HTTP Range requests for resume functionality
- Progress tracking with speed and time estimates
- State persistence in SharedPreferences
- Error recovery with exponential backoff

### 2.3 File Processing Service
**Location**: `lib/shared/services/file_processing_service.dart`

**Supported Formats**:
- **PDF**: Text extraction using `pdf_text`
- **TXT**: Direct text processing
- **DOCX**: Document parsing using `docx`

**Implementation**:
```dart
class FileProcessingService {
  Future<String> extractText(String filePath, String fileType)
  Future<void> processFile(File file)
  Future<bool> isValidFileType(String fileType)
}
```

---

## 3. State Management Implementation

### 3.1 Chat BLoC
**Location**: `lib/features/chat/bloc/`

**Events**:
```dart
class CreateNewConversation extends ChatEvent
class SendMessage extends ChatEvent
class LoadConversation extends ChatEvent
class ClearConversation extends ChatEvent
```

**States**:
```dart
class ChatInitial extends ChatState
class ChatLoading extends ChatState
class ChatLoaded extends ChatState
class ChatError extends ChatState
```

**Implementation**:
- Manages conversation state and message history
- Integrates with LLMService for AI responses
- Supports streaming responses with real-time updates
- Handles error states and recovery

### 3.2 File Management BLoC
**Location**: `lib/features/file_management/bloc/`

**Events**:
```dart
class PickFile extends FileEvent
class ProcessFile extends FileEvent
class DeleteFile extends FileEvent
class LoadFiles extends FileEvent
```

**States**:
```dart
class FileInitial extends FileState
class FileLoading extends FileState
class FileLoaded extends FileState
class FileError extends FileState
```

**Implementation**:
- Manages file upload and processing
- Integrates with FileProcessingService
- Tracks file processing progress
- Handles file validation and errors

### 3.3 Agent BLoC
**Location**: `lib/features/settings/bloc/`

**Events**:
```dart
class CreateAgent extends AgentEvent
class UpdateAgent extends AgentEvent
class DeleteAgent extends AgentEvent
class SetActiveAgent extends AgentEvent
```

**States**:
```dart
class AgentInitial extends AgentState
class AgentLoading extends AgentState
class AgentLoaded extends AgentState
class AgentError extends AgentState
```

**Implementation**:
- Manages AI agent creation and configuration
- Integrates with chat for agent switching
- Persists agent data locally
- Provides pre-built agent templates

---

## 4. UI Components Implementation

### 4.1 Unified Design System
**Location**: `lib/shared/widgets/ui_components.dart`

**Button Components**:
```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
}
```

**Card Components**:
```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isElevated;
}
```

**Progress Components**:
```dart
class AppProgressBar extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double height;
}
```

### 4.2 Chat UI Components
**Location**: `lib/shared/widgets/message_bubble.dart`

**Features**:
- Message bubbles for user and AI
- Typing indicators during AI processing
- Streaming response display
- Message timestamp and status

### 4.3 Download Screen
**Location**: `lib/shared/widgets/download_screen.dart`

**Features**:
- Real-time progress tracking
- Resume functionality indication
- Error handling and retry options
- Skip option with confirmation

---

## 5. Data Models

### 5.1 Message Model
**Location**: `lib/shared/models/message.dart`

```dart
class Message {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isStreaming;
  final String? agentId;
}
```

### 5.2 Conversation Model
**Location**: `lib/shared/models/conversation.dart`

```dart
class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? activeAgentId;
}
```

### 5.3 Agent Model
**Location**: `lib/features/settings/models/agent_model.dart`

```dart
class Agent {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final bool isDefault;
  final DateTime createdAt;
}
```

---

## 6. Error Handling Implementation

### 6.1 Error Types
```dart
enum ErrorType {
  network,
  file,
  ai,
  system,
  validation
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final bool isRecoverable;
}
```

### 6.2 Error Recovery Strategies

#### Network Errors
```dart
// Automatic retry with exponential backoff
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  // Implementation
}
```

#### File Errors
```dart
// Clear error messages and recovery options
void handleFileError(FileError error) {
  switch (error.type) {
    case FileErrorType.invalidFormat:
      showFormatErrorDialog();
      break;
    case FileErrorType.tooLarge:
      showSizeErrorDialog();
      break;
    // ...
  }
}
```

#### AI Errors
```dart
// Graceful degradation with retry mechanisms
void handleAIError(AIError error) {
  if (error.isRecoverable) {
    showRetryDialog();
  } else {
    showErrorDialog(error.message);
  }
}
```

---

## 7. Testing Implementation

### 7.1 Unit Testing
**Location**: `test/`

**BLoC Testing**:
```dart
blocTest<ChatBloc, ChatState>(
  'emits [ChatLoading, ChatLoaded] when SendMessage is added',
  build: () => ChatBloc(),
  act: (bloc) => bloc.add(SendMessage(content: 'Hello')),
  expect: () => [ChatLoading(), ChatLoaded()],
);
```

**Service Testing**:
```dart
test('LLMService generates response', () async {
  final service = LLMService();
  await service.initialize();
  
  final response = await service.generateResponse('Hello');
  expect(response, isNotEmpty);
});
```

### 7.2 Widget Testing
**Location**: `test/widget_test.dart`

```dart
testWidgets('PrimaryButton shows loading state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: PrimaryButton(text: 'Test', isLoading: true)),
  );
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### 7.3 Integration Testing
**Location**: `integration_test/`

```dart
testWidgets('Complete chat flow', (tester) async {
  // Test complete user journey
  await tester.tap(find.byType(FloatingActionButton));
  await tester.enterText(find.byType(TextField), 'Hello AI');
  await tester.tap(find.text('Send'));
  
  // Verify AI response
  await tester.pumpAndSettle();
  expect(find.text('AI Response'), findsOneWidget);
});
```

---

## 8. Performance Optimization

### 8.1 Memory Management
```dart
// Efficient model loading
class LLMService {
  static LLMService? _instance;
  
  factory LLMService() {
    _instance ??= LLMService._internal();
    return _instance!;
  }
  
  Future<void> dispose() async {
    // Clean up resources
    _instance = null;
  }
}
```

### 8.2 UI Optimization
```dart
// Optimized widget rebuilds
class OptimizedMessageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) {
        return previous.messages != current.messages;
      },
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            return MessageBubble(message: state.messages[index]);
          },
        );
      },
    );
  }
}
```

### 8.3 Storage Optimization
```dart
// Efficient data persistence
class StorageService {
  static const String _conversationsKey = 'conversations';
  static const String _agentsKey = 'agents';
  
  Future<void> saveConversations(List<Conversation> conversations) async {
    final json = conversations.map((c) => c.toJson()).toList();
    await _prefs.setString(_conversationsKey, jsonEncode(json));
  }
}
```

---

## 9. Deployment Guide

### 9.1 Build Configuration

#### iOS Build
```bash
# Build for release
flutter build ios --release

# Archive for App Store
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/Runner.xcarchive
```

#### Android Build
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### 9.2 App Store Deployment

#### iOS App Store
1. Create app in App Store Connect
2. Upload build using Xcode or Transporter
3. Configure app metadata and screenshots
4. Submit for review

#### Google Play Store
1. Create app in Google Play Console
2. Upload AAB file
3. Configure app metadata and screenshots
4. Submit for review

### 9.3 Release Checklist
- [ ] All tests passing
- [ ] Performance testing completed
- [ ] Security review completed
- [ ] Privacy policy updated
- [ ] App store metadata prepared
- [ ] Screenshots and videos ready
- [ ] Release notes written

---

## 10. Maintenance and Updates

### 10.1 Dependency Management
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  flutter_gemma: ^0.1.0
  dio: ^5.3.2
  shared_preferences: ^2.2.2
```

### 10.2 Version Management
- **Semantic Versioning**: MAJOR.MINOR.PATCH
- **Changelog**: Track all changes
- **Migration Guide**: For breaking changes
- **Backward Compatibility**: Maintain API stability

### 10.3 Monitoring and Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Performance Monitoring**: Firebase Performance
- **User Feedback**: In-app feedback system
- **Privacy Compliance**: No user tracking

---

**Document Version:** 2.0  
**Last Updated:** July 2025  
**Next Review:** August 2025 