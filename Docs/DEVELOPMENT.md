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

#### Audio Feature Setup

**iOS Audio Permissions** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice input.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert voice to text.</string>
```

**Android Audio Permissions** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

**Audio Dependencies** (`pubspec.yaml`):
```yaml
dependencies:
  # Speech recognition
  speech_to_text: ^6.6.0
  
  # Text-to-speech
  flutter_tts: ^3.8.5
  
  # Audio recording (alternative)
  record: ^5.0.4
  
  # Audio playback
  audioplayers: ^5.2.1
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

### 2.4 Speech Recognition Service
**Location**: `lib/shared/services/speech_service.dart`

**Dependencies**:
```yaml
speech_to_text: ^6.6.0
```

**Key Methods**:
```dart
class SpeechService {
  Future<bool> initialize()
  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onError,
  })
  Future<void> stopListening()
  Future<bool> isListening()
  Future<List<LocaleName>> getAvailableLocales()
}
```

**Implementation Details**:
- Uses device-native speech recognition APIs
- Supports multiple languages and locales
- Real-time speech-to-text conversion
- Error handling for recognition failures
- Visual feedback during recording

**Platform Permissions**:
- **iOS**: `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`
- **Android**: `RECORD_AUDIO`, `INTERNET` permissions

### 2.5 Text-to-Speech Service
**Location**: `lib/shared/services/tts_service.dart`

**Dependencies**:
```yaml
flutter_tts: ^3.8.5
```

**Key Methods**:
```dart
class TTSService {
  Future<void> initialize()
  Future<void> speak(String text)
  Future<void> stop()
  Future<bool> isSpeaking()
  Future<void> setLanguage(String language)
  Future<void> setSpeechRate(double rate)
  Future<void> setVolume(double volume)
  Future<void> setPitch(double pitch)
}
```

**Implementation Details**:
- Uses device-native text-to-speech engines
- Configurable speech rate, volume, and pitch
- Multiple language support
- Background audio playback
- Error handling for TTS failures

**Supported Features**:
- **Speech Rate**: 0.1 to 1.0 (slow to fast)
- **Volume**: 0.0 to 1.0 (mute to full volume)
- **Pitch**: 0.5 to 2.0 (low to high pitch)
- **Languages**: Device-supported languages

---

## 3. State Management Implementation

### 3.1 Chat BLoC
**Location**: `lib/features/chat/bloc/`

**Events**:
```dart
class CreateNewConversation extends ChatEvent
class SendMessage extends ChatEvent
class LoadConversation extends ChatEvent
class LoadConversations extends ChatEvent
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

**State Persistence & Tab Navigation**:
- **Chat State Persistence**: Chat state is preserved when switching between tabs using `IndexedStack` in `MainScreen`
- **Scroll Position Preservation**: Scroll position in chat is maintained across tab switches
- **Service-Based Architecture**: Uses singleton `ChatService` to maintain conversation data in memory
- **Automatic State Restoration**: `LoadConversations` event automatically restores chat state on bloc initialization
- **BLoC Lifecycle Management**: ChatBloc is provided at app level to prevent recreation during tab switches

**Key Implementation Details**:
```dart
// MainScreen uses IndexedStack for persistent tab state
body: IndexedStack(
  index: _currentIndex,
  children: _screens,
),

// ChatBloc automatically loads existing conversations
ChatBloc() : super(ChatInitial()) {
  _chatService.initialize().then((_) {
    add(LoadConversations());
  });
}

// ChatService maintains in-memory state
class ChatService {
  static final ChatService _instance = ChatService._internal();
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
}
```

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

### 3.4 Voice BLoC
**Location**: `lib/features/voice/bloc/`

**Events**:
```dart
class StartListening extends VoiceEvent
class StopListening extends VoiceEvent
class VoiceInputReceived extends VoiceEvent {
  final String text;
  const VoiceInputReceived(this.text);
}
class ToggleVoiceOutput extends VoiceEvent {
  final bool enabled;
  const ToggleVoiceOutput(this.enabled);
}
class SpeakText extends VoiceEvent {
  final String text;
  const SpeakText(this.text);
}
class UpdateVoiceSettings extends VoiceEvent {
  final String language;
  final double speechRate;
  final double volume;
  final double pitch;
}
```

**States**:
```dart
class VoiceInitial extends VoiceState
class VoiceListening extends VoiceState
class VoiceProcessing extends VoiceState
class VoiceOutputEnabled extends VoiceState {
  final bool enabled;
  final String language;
  final double speechRate;
  final double volume;
  final double pitch;
}
class VoiceError extends VoiceState {
  final String message;
  const VoiceError(this.message);
}
```

**Implementation**:
- Manages speech recognition state and audio input
- Controls text-to-speech output settings
- Integrates with chat for voice input/output
- Handles voice recognition errors and recovery
- Persists voice settings locally

**Integration with Chat**:
```dart
// Auto-speak AI responses when voice output is enabled
BlocListener<ChatBloc, ChatState>(
  listener: (context, state) {
    if (state is ChatLoaded && 
        state.currentConversation.messages.isNotEmpty &&
        context.read<VoiceBloc>().state.voiceOutputEnabled) {
      final lastMessage = state.currentConversation.messages.last;
      if (lastMessage.role == MessageRole.assistant) {
        context.read<VoiceBloc>().add(SpeakText(lastMessage.content));
      }
    }
  },
)
```

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

### 4.4 Tab Navigation Implementation
**Location**: `lib/main.dart` - `MainScreen`

**Key Features**:
- **Persistent Tab State**: Uses `IndexedStack` to preserve widget state across tab switches
- **Scroll Position Preservation**: Chat scroll position is maintained when switching tabs
- **BLoC Lifecycle Management**: ChatBloc is provided at app level to prevent recreation

**Implementation**:
```dart
class MainScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // [ChatScreen(), FileManagementScreen(), AgentManagementScreen()]
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Files'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

**Benefits**:
- **Performance**: No widget recreation during tab switches
- **User Experience**: Seamless navigation with preserved state
- **Memory Efficiency**: Only active tab is rendered, others are kept in memory
- **Scroll Position**: Chat scroll position is maintained across tab switches

### 4.5 Voice UI Components
**Location**: `lib/shared/widgets/voice_components.dart`

**Voice Input Button**:
```dart
class VoiceInputButton extends StatefulWidget {
  final Function(String text) onVoiceInput;
  final bool isListening;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            state.isListening ? Icons.mic : Icons.mic_none,
            color: state.isListening ? Colors.red : null,
          ),
          onPressed: () {
            if (state.isListening) {
              context.read<VoiceBloc>().add(StopListening());
            } else {
              context.read<VoiceBloc>().add(StartListening());
            }
          },
        );
      },
    );
  }
}
```

**Voice Output Toggle**:
```dart
class VoiceOutputToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text('Voice Output'),
          subtitle: Text('Read AI responses aloud'),
          value: state.voiceOutputEnabled,
          onChanged: (value) {
            context.read<VoiceBloc>().add(ToggleVoiceOutput(value));
          },
        );
      },
    );
  }
}
```

**Voice Settings Panel**:
```dart
class VoiceSettingsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        return Column(
          children: [
            ListTile(
              title: Text('Speech Language'),
              subtitle: Text(state.language),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguageSelector(context),
            ),
            ListTile(
              title: Text('Speech Rate'),
              subtitle: Slider(
                value: state.speechRate,
                min: 0.1,
                max: 1.0,
                onChanged: (value) {
                  context.read<VoiceBloc>().add(
                    UpdateVoiceSettings(speechRate: value),
                  );
                },
              ),
            ),
            ListTile(
              title: Text('Volume'),
              subtitle: Slider(
                value: state.volume,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  context.read<VoiceBloc>().add(
                    UpdateVoiceSettings(volume: value),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

**Integration with Chat Screen**:
```dart
// Updated message input with voice button
Widget _buildMessageInput() {
  return Container(
    padding: const EdgeInsets.all(AppConstants.paddingMedium),
    child: SafeArea(
      child: Row(
        children: [
          // Voice input button
          VoiceInputButton(
            onVoiceInput: (text) {
              _messageController.text = text;
              _handleSubmitted(text);
            },
          ),
          const SizedBox(width: 8),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: InputDecoration(
                hintText: 'Type a message or tap the mic...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Send button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing ? () => _handleSubmitted(_messageController.text) : null,
          ),
        ],
      ),
    ),
  );
}
```

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

// Chat State Persistence Testing
blocTest<ChatBloc, ChatState>(
  'should not emit anything when LoadConversations called with no conversations',
  build: () => ChatBloc(),
  act: (bloc) => bloc.add(LoadConversations()),
  expect: () => [], // No state change when already in ChatInitial
);

blocTest<ChatBloc, ChatState>(
  'should restore chat state when switching tabs',
  build: () => ChatBloc(),
  act: (bloc) async {
    // Create conversation first
    bloc.add(const CreateNewConversation(title: 'Test Conversation'));
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Send a message
    bloc.add(const SendMessage(content: 'Hello AI'));
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simulate tab switch by loading conversations
    bloc.add(LoadConversations());
  },
  expect: () => [
    isA<ChatLoaded>(), // From CreateNewConversation
    isA<ChatLoaded>(), // From SendMessage
    isA<ChatLoaded>(), // From LoadConversations (restored state)
  ],
);

// Voice Feature Testing
blocTest<VoiceBloc, VoiceState>(
  'should emit VoiceListening when StartListening is added',
  build: () => VoiceBloc(),
  act: (bloc) => bloc.add(StartListening()),
  expect: () => [isA<VoiceListening>()],
);

blocTest<VoiceBloc, VoiceState>(
  'should emit VoiceOutputEnabled when ToggleVoiceOutput is added',
  build: () => VoiceBloc(),
  act: (bloc) => bloc.add(const ToggleVoiceOutput(true)),
  expect: () => [isA<VoiceOutputEnabled>()],
);

blocTest<VoiceBloc, VoiceState>(
  'should handle voice input and emit VoiceInputReceived',
  build: () => VoiceBloc(),
  act: (bloc) => bloc.add(const VoiceInputReceived('Hello AI')),
  expect: () => [isA<VoiceInputReceived>()],
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

// Integration Testing
testWidgets('Voice input button shows correct state', (tester) async {
  await tester.pumpWidget(
    TestConfig.createTestAppWithBloc(
      VoiceInputButton(onVoiceInput: (text) {}),
      [BlocProvider(create: (context) => VoiceBloc())],
    ),
  );
  
  // Initially should show mic_none icon
  expect(find.byIcon(Icons.mic_none), findsOneWidget);
  
  // Tap to start listening
  await tester.tap(find.byType(IconButton));
  await tester.pump();
  
  // Should show mic icon (listening state)
  expect(find.byIcon(Icons.mic), findsOneWidget);
});

testWidgets('Voice output toggle works correctly', (tester) async {
  await tester.pumpWidget(
    TestConfig.createTestAppWithBloc(
      VoiceOutputToggle(),
      [BlocProvider(create: (context) => VoiceBloc())],
    ),
  );
  
  // Initially should be disabled
  expect(find.byType(Switch), findsOneWidget);
  
  // Tap to enable
  await tester.tap(find.byType(Switch));
  await tester.pump();
  
  // Should be enabled
  expect(tester.widget<Switch>(find.byType(Switch)).value, true);
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

## 11. Audio Feature Implementation Roadmap

### Phase 1: Core Services (Week 1)
1. **Add Dependencies**
   - Update `pubspec.yaml` with audio packages
   - Run `flutter pub get`
   - Add platform permissions

2. **Create Speech Recognition Service**
   - Implement `SpeechService` class
   - Add initialization and permission handling
   - Implement start/stop listening methods
   - Add error handling and callbacks

3. **Create Text-to-Speech Service**
   - Implement `TTSService` class
   - Add initialization and configuration
   - Implement speak/stop methods
   - Add settings management (rate, volume, pitch)

### Phase 2: State Management (Week 2)
1. **Create Voice BLoC**
   - Implement `VoiceEvent` classes
   - Implement `VoiceState` classes
   - Create `VoiceBloc` with event handlers
   - Add integration with speech and TTS services

2. **Add Voice Settings**
   - Implement voice settings persistence
   - Add language selection functionality
   - Create settings management in BLoC

### Phase 3: UI Components (Week 3)
1. **Create Voice UI Components**
   - Implement `VoiceInputButton`
   - Implement `VoiceOutputToggle`
   - Create `VoiceSettingsPanel`
   - Add visual feedback for recording state

2. **Integrate with Chat Screen**
   - Update chat message input with voice button
   - Add auto-speak functionality for AI responses
   - Implement voice input callback handling

### Phase 4: Settings Integration (Week 4)
1. **Add Voice Settings to Settings Screen**
   - Create voice settings section
   - Add language selector
   - Add speech rate and volume controls
   - Implement settings persistence

2. **Add Voice Settings to Agent Management**
   - Integrate voice settings with agent configuration
   - Add agent-specific voice preferences

### Phase 5: Testing and Refinement (Week 5)
1. **Unit Testing**
   - Test speech recognition service
   - Test TTS service
   - Test Voice BLoC functionality
   - Test voice settings management

2. **Widget Testing**
   - Test voice input button
   - Test voice output toggle
   - Test voice settings panel
   - Test chat integration

3. **Integration Testing**
   - Test complete voice input/output flow
   - Test voice settings persistence
   - Test error handling scenarios

### Phase 6: Polish and Documentation (Week 6)
1. **Error Handling**
   - Improve error messages
   - Add retry mechanisms
   - Handle edge cases

2. **Performance Optimization**
   - Optimize audio processing
   - Reduce memory usage
   - Improve response times

3. **Documentation**
   - Update API documentation
   - Add usage examples
   - Create troubleshooting guide

### Success Criteria
- [ ] Voice input works reliably across devices
- [ ] Voice output quality is acceptable
- [ ] Settings are properly persisted
- [ ] Error handling is robust
- [ ] Performance impact is minimal
- [ ] Accessibility requirements are met
- [ ] All tests pass
- [ ] Documentation is complete

### Risk Mitigation
- **Device Compatibility**: Test on multiple devices and OS versions
- **Performance Impact**: Monitor memory and CPU usage
- **User Experience**: Conduct usability testing
- **Accessibility**: Ensure WCAG compliance
- **Error Handling**: Comprehensive error scenarios covered

---

**Document Version:** 2.0  
**Last Updated:** July 2025  
**Next Review:** August 2025