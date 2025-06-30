# GenLite 🚀

**Your offline AI assistant, running entirely on your device.**

GenLite is a lightweight Flutter application that brings AI capabilities directly to your device using local language models. No internet required, no data shared, no ongoing costs.

## ✨ Features

- 🤖 **Offline AI Assistant** - Powered by local Gemma 2B model
- 💬 **Intuitive Chat Interface** - Clean, familiar chat UI similar to ChatGPT
- 📁 **File Upload & Q&A** - Upload documents and ask questions about their content
- 🎭 **Custom Agents** - Create and switch between different AI personalities
- 🔒 **100% Private** - All processing happens locally on your device
- 📱 **Cross-Platform** - Works on iOS, Android, and Web
- 🌙 **Dark/Light Theme** - Beautiful UI with theme support

## 🏗️ Architecture

GenLite follows Clean Architecture principles with BLoC state management:

```
lib/
├── core/           # App constants, theme, utilities
├── features/       # Feature modules (chat, file management, settings)
├── shared/         # Shared models, widgets, services
└── main.dart       # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.2.0 or higher)
- Android Studio / VS Code
- iOS Simulator (for iOS development)
- Android Emulator (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gen_lite.git
   cd gen_lite
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   
   # For Web
   flutter run -d chrome
   ```

## 📱 Usage

### Starting a Conversation
1. Launch GenLite
2. Type your message in the input field
3. Press send or use quick start prompts
4. Get instant AI responses

### File Upload
1. Tap the attachment icon
2. Select a document (PDF, TXT, DOCX)
3. Ask questions about the uploaded content
4. Get context-aware responses

### Custom Agents
1. Create different AI personalities
2. Switch between agents for different tasks
3. Customize behavior and responses

## 🛠️ Development

### Project Structure

```
GenLite/
├── lib/
│   ├── core/
│   │   ├── constants/     # App constants
│   │   ├── theme/         # App theme configuration
│   │   └── utils/         # Utility functions
│   ├── features/
│   │   ├── chat/          # Chat functionality
│   │   ├── file_management/ # File upload and processing
│   │   └── settings/      # App settings
│   ├── shared/
│   │   ├── models/        # Data models
│   │   ├── services/      # Shared services
│   │   └── widgets/       # Reusable widgets
│   └── main.dart
├── test/                  # Test files (mirrors lib structure)
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── web/                   # Web-specific files
└── pubspec.yaml           # Dependencies
```

### Testing

Run the test suite:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

### Code Style

The project follows Flutter's official style guide. Run the linter:
```bash
flutter analyze
```

## 🔧 Configuration

### Model Settings

Configure the local model in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String defaultModelName = 'gemma-2b-q4_k_m';
  static const int maxTokens = 2048;
  static const double temperature = 0.7;
}
```

### Supported File Types

- PDF (.pdf)
- Text (.txt)
- Word documents (.docx)
- Maximum file size: 10MB

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clean Architecture principles
- Write tests for new features
- Use BLoC for state management
- Follow Flutter's style guide
- Add documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - The UI framework
- [flutter_gemma](https://pub.dev/packages/flutter_gemma) - Local LLM integration
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - State management
- [Gemma](https://ai.google.dev/gemma) - The language model

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/gen_lite/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/gen_lite/discussions)
- **Email**: support@genlite.app

## 🗺️ Roadmap

- [ ] Voice input/output
- [ ] Image analysis capabilities
- [ ] Cloud backup/sync (optional)
- [ ] Plugin ecosystem
- [ ] Enterprise features
- [ ] Multi-language support

---

**Made with ❤️ for privacy-conscious AI users**
