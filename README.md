# GenLite: Offline AI Assistant

**Version:** 2.0  
**Date:** July 2025  
**Status:** Production Ready  

A privacy-focused, offline AI assistant that runs entirely on your device using the Gemma 2B language model. No data leaves your device - complete privacy guaranteed.

## 🎯 Key Features

- **🔒 100% Privacy**: All AI processing happens locally on your device
- **📱 Offline Functionality**: Works without internet connection after initial download
- **💬 Natural Conversations**: Chat with AI using natural language
- **📄 Document Analysis**: Upload and query PDF, TXT, and DOCX files
- **🤖 Custom Agents**: Create and switch between different AI personalities
- **⬇️ Smart Downloads**: Resume interrupted model downloads automatically
- **🎨 Professional UX**: Unified design system with smooth interactions



https://github.com/user-attachments/assets/62d33866-872f-4295-9ae8-91752b4d980e



## 🚀 Quick Start

### Prerequisites
- iOS 16.0+ or Android 8.0+
- ~4GB free storage space
- 4GB RAM recommended
- Internet connection for initial model download

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/brahim-guaali/GenLite.git
   cd GenLite
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Hugging Face token**
   - Create a `.env` file in the project root
   - Add your Hugging Face token: `HUGGING_FACE_TOKEN=your_token_here`

4. **Run the app**
   ```bash
   flutter run
   ```

### First Launch
1. **Welcome Screen**: Learn about app features and privacy
2. **Terms Acceptance**: Accept Gemma license terms
3. **Model Download**: Download the ~4GB AI model (can be resumed if interrupted)
4. **Start Chatting**: Begin using the AI assistant

## 🏗 Architecture Overview

GenLite follows Clean Architecture principles with a focus on privacy and performance:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Chat UI   │  │  File UI    │  │ Settings UI │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     Business Logic Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Chat BLoC  │  │ File BLoC   │  │ Agent BLoC  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ LLM Service │  │File Service │  │Storage Svc  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

- **BLoC Pattern**: Predictable state management across all features
- **Unified UI System**: Consistent, reusable components
- **Local-Only Processing**: No cloud dependencies for AI inference
- **Resume Downloads**: HTTP Range requests for interrupted downloads
- **Material 3**: Modern, accessible design system

## 📱 User Guide

### Chat Interface
- **Natural Conversations**: Type naturally and get intelligent responses
- **Streaming Responses**: See AI responses as they're generated
- **Conversation History**: All chats saved locally on your device
- **Quick Prompts**: Suggested conversation starters

### File Management
- **Supported Formats**: PDF, TXT, DOCX files
- **Upload & Process**: Drag and drop or select files
- **AI Analysis**: Ask questions about your documents
- **Local Storage**: Files processed and stored locally

### Custom Agents
- **Pre-built Templates**: Choose from various AI personalities
- **Custom Creation**: Create your own AI agents
- **Easy Switching**: Switch agents during conversations
- **Persistent Settings**: Agent preferences saved locally

### Settings
- **Agent Management**: Create, edit, and delete AI agents
- **Download Management**: Resume interrupted downloads
- **Privacy Controls**: All data stays on your device
- **App Preferences**: Customize your experience

## 🔧 Development

### Project Structure
```
lib/
├── core/           # App constants, themes, utilities
├── features/       # Feature modules (chat, files, settings)
└── shared/         # Shared services and widgets
    ├── services/   # Business logic services
    └── widgets/    # Unified UI components
```

### Key Services

#### LLM Service
```dart
class LLMService {
  Future<void> initialize({String? modelPath})
  Future<String> generateResponse(String prompt)
  Future<void> addContext(String context)
}
```

#### Enhanced Model Downloader
```dart
class EnhancedModelDownloader {
  static Future<String> ensureGemmaModel({
    bool allowResume = true,
    void Function(ProgressInfo info)? onProgress,
  })
}
```

#### File Processing Service
```dart
class FileProcessingService {
  Future<String> extractText(String filePath, String fileType)
  Future<void> processFile(File file)
}
```

### State Management
- **Chat BLoC**: Message handling and conversation management
- **File BLoC**: File upload, processing, and management
- **Agent BLoC**: AI agent creation and configuration

### Error Handling
- **Network Errors**: Automatic retry with exponential backoff
- **Download Errors**: Resume functionality and skip options
- **File Errors**: Clear error messages and recovery
- **AI Errors**: Graceful degradation with retry mechanisms

## 🔒 Privacy & Security

### Data Protection
- **Local Processing**: All AI inference happens on your device
- **No Cloud Storage**: Conversations and files never leave your device
- **No Tracking**: No analytics or user behavior tracking
- **Secure Storage**: Local data encrypted at rest

### Model Security
- **Verified Source**: Gemma model from Google's official repository
- **Hash Verification**: Model integrity checks
- **Secure Download**: HTTPS with token authentication

## 📊 Performance

| Component | Response Time | Memory Usage | Storage |
|-----------|---------------|--------------|---------|
| App Launch | < 2 seconds | ~50MB | ~4GB |
| AI Response | < 3 seconds | ~100MB | - |
| File Upload | < 5 seconds | ~20MB | Varies |
| Model Download | ~10-30 min | ~50MB | 4GB |

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Coverage
- **BLoC Testing**: State management logic
- **Service Testing**: Business logic services
- **Widget Testing**: UI components and screens
- **Integration Testing**: End-to-end workflows

## 🚀 Deployment

### iOS
- **Minimum Version**: iOS 16.0
- **Deployment Target**: iOS 16.0+
- **Architecture**: ARM64

### Android
- **Minimum SDK**: API 26 (Android 8.0)
- **Target SDK**: API 34 (Android 14)
- **Architecture**: ARM64, x86_64

### Build Commands
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Add tests for new functionality
5. Run tests: `flutter test`
6. Commit changes: `git commit -m 'Add feature'`
7. Push to branch: `git push origin feature-name`
8. Submit a pull request

### Development Guidelines
- Follow Clean Architecture principles
- Use BLoC pattern for state management
- Maintain unified UI design system
- Write comprehensive tests
- Ensure privacy-first design

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google**: Gemma 2B language model
- **Hugging Face**: Model hosting and API
- **Flutter Team**: Cross-platform framework
- **Open Source Community**: Various dependencies and tools

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/brahim-guaali/GenLite/issues)
- **Discussions**: [GitHub Discussions](https://github.com/brahim-guaali/GenLite/discussions)
- **Documentation**: See [DEVELOPMENT.md](DEVELOPMENT.md) for technical details

---

**Made with ❤️ for privacy-conscious users**
