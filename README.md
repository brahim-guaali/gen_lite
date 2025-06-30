# GenLite - Offline AI Assistant

A lightweight, privacy-focused AI assistant that runs entirely on your device using the Gemma 2B language model.

## 🚀 Features

### 🤖 **AI Capabilities**
- **100% Offline**: All AI processing happens locally on your device
- **Privacy First**: No data sent to external servers
- **Fast Processing**: Optimized local inference with Gemma 2B
- **Document Analysis**: Upload and analyze PDF, TXT, and DOCX files
- **Conversation Memory**: Maintains context across chat sessions

### 📱 **User Experience**
- **Unified Design System**: Consistent, modern UI across all screens
- **Smart Download Management**: Resume interrupted downloads automatically
- **Progress Tracking**: Real-time download progress with speed and time estimates
- **Error Recovery**: Robust error handling with retry options
- **Responsive Layout**: Works seamlessly across different screen sizes

### 🔧 **Technical Features**
- **Download Resume**: Continue downloads from where they left off
- **State Persistence**: Download progress saved across app restarts
- **Model Management**: Automatic model download and initialization
- **File Processing**: Extract and analyze document content
- **Clean Architecture**: Well-structured codebase with BLoC pattern

## 📋 Requirements

- **iOS**: iOS 16.0 or later
- **Android**: Android 8.0 (API level 26) or later
- **Storage**: ~4GB free space for the AI model
- **Memory**: 4GB RAM recommended
- **Network**: Initial download requires internet connection

## 🛠 Installation

### Prerequisites
- Flutter SDK 3.2.0 or later
- Dart SDK 3.2.0 or later
- iOS: Xcode 14.0 or later
- Android: Android Studio with Android SDK

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/brahim-guaali/gen_lite.git
   cd gen_lite
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Create a `.env` file in the root directory
   - Add your Hugging Face token:
     ```
     HUGGINGFACE_TOKEN=your_token_here
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Getting Started

### First Launch
1. **Welcome Screen**: Learn about GenLite's features and privacy
2. **Terms Acceptance**: Accept the Gemma Terms of Use
3. **Model Download**: The app will download the AI model (~4GB)
   - Download can be resumed if interrupted
   - Progress is saved across app restarts
4. **Ready to Chat**: Start using your offline AI assistant!

### Using the App

#### 💬 **Chat Interface**
- Start conversations with natural language
- Get instant responses from the local AI model
- View conversation history and context

#### 📁 **File Management**
- Upload PDF, TXT, or DOCX files
- Ask questions about document content
- Get AI-powered analysis and insights

#### ⚙️ **Settings & Agents**
- Configure AI behavior and parameters
- Create custom AI agents for specific tasks
- Manage conversation preferences

## 🏗 Architecture

### **Clean Architecture Pattern**
```
lib/
├── core/           # App-wide constants, themes, utilities
├── features/       # Feature modules (chat, files, settings)
│   ├── chat/       # Chat functionality
│   ├── file_management/  # File processing
│   └── settings/   # App configuration
└── shared/         # Shared services and widgets
    ├── services/   # Business logic services
    └── widgets/    # Reusable UI components
```

### **State Management**
- **BLoC Pattern**: Clean separation of business logic and UI
- **Event-Driven**: Reactive architecture with event streams
- **Predictable State**: Immutable state management

### **UI Design System**
- **Unified Components**: Consistent buttons, cards, and indicators
- **Theme Support**: Light and dark mode compatibility
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: Proper contrast and touch targets

## 🔒 Privacy & Security

### **Data Protection**
- **Local Processing**: All AI inference happens on your device
- **No Cloud Storage**: Conversations and files stay local
- **No Tracking**: No analytics or user tracking
- **Secure Storage**: Local data encrypted at rest

### **Model Security**
- **Verified Source**: Gemma model from Google's official repository
- **Hash Verification**: Model integrity checks
- **Secure Download**: HTTPS with token authentication

## 🛠 Development

### **Project Structure**
```
GenLite/
├── lib/
│   ├── core/           # App constants, themes, utilities
│   ├── features/       # Feature modules
│   └── shared/         # Shared services and widgets
├── test/               # Unit and widget tests
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
└── docs/               # Documentation
```

### **Key Technologies**
- **Flutter**: Cross-platform UI framework
- **flutter_gemma**: Local AI model integration
- **BLoC**: State management
- **Hive**: Local data storage
- **HTTP**: Model downloading and API calls

### **Testing**
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📱 Screenshots

*Screenshots will be added here*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Flutter best practices
- Use the established UI design system
- Write tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google**: For the Gemma language model
- **Flutter Team**: For the amazing framework
- **Hugging Face**: For model hosting and distribution

## 📞 Support

- **Issues**: Report bugs and feature requests on GitHub
- **Discussions**: Join community discussions
- **Documentation**: Check the [docs/](docs/) folder for detailed guides

---

**GenLite** - Your private, offline AI companion 🤖✨
