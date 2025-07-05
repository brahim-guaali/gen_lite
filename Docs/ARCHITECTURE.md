# Architecture Document
## GenLite: Technical Architecture Guide

**Version:** 2.0  
**Date:** July 2025  
**Technical Lead:** Brahim Guaali  

---

## 1. System Architecture Overview

### 1.1 Clean Architecture Pattern
GenLite follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Chat UI   │  │  File UI    │  │ Settings UI │        │
│  │  + Voice    │  │             │  │  + Voice    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     Business Logic Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Chat BLoC  │  │ File BLoC   │  │ Agent BLoC  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│  ┌─────────────┐                                          │
│  │ Voice BLoC  │                                          │
│  └─────────────┘                                          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ LLM Service │  │File Service │  │Storage Svc  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│  ┌─────────────┐  ┌─────────────┐                        │
│  │Speech Svc   │  │ TTS Service │                        │
│  └─────────────┘  └─────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Project Structure
```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── theme/             # Material 3 theme setup
│   └── utils/             # Utility functions
├── features/
│   ├── chat/              # Chat feature module
│   ├── file_management/   # File management module
│   ├── onboarding/        # Onboarding feature
│   ├── settings/          # Settings and agents
│   └── voice/             # Voice input/output feature
└── shared/
    ├── models/            # Data models
    ├── services/          # Business logic services
    │   ├── speech_service.dart    # Speech recognition
    │   └── tts_service.dart       # Text-to-speech
    └── widgets/           # Unified UI components
        └── voice_components.dart  # Voice UI components
```

---

## 2. Key Architectural Decisions

### 2.1 BLoC Pattern for State Management
**Decision**: Use BLoC (Business Logic Component) pattern for all state management.

**Rationale**:
- Clean separation of business logic and UI
- Predictable state changes
- Excellent testability
- Reactive architecture

**Implementation**:
```dart
// Events
class SendMessage extends ChatEvent
class PickFile extends FileEvent
class CreateAgent extends AgentEvent

// States
class ChatLoaded extends ChatState
class FileLoaded extends FileState
class AgentLoaded extends AgentState
```

### 2.2 Unified UI Design System
**Decision**: Implement a unified UI design system with reusable components.

**Rationale**:
- Consistent look and feel across all screens
- Easier maintenance and updates
- Better developer experience
- Improved accessibility

**Components**:
```dart
// Button Components
class PrimaryButton extends StatelessWidget
class SecondaryButton extends StatelessWidget
class DangerButton extends StatelessWidget

// Card Components
class AppCard extends StatelessWidget

// Progress Indicators
class AppProgressBar extends StatelessWidget
```

### 2.3 Local-Only AI Processing
**Decision**: All AI processing happens locally using the Gemma 2B model.

**Rationale**:
- Complete privacy protection
- Works offline
- No ongoing costs
- No data transmission

**Implementation**:
```dart
class LLMService {
  Future<String> generateResponse(String prompt) // Local processing only
}
```

### 2.4 Enhanced Model Downloader
**Decision**: Implement smart download management with resume functionality.

**Rationale**:
- Users can resume interrupted downloads
- Download progress persists across app restarts
- Robust error handling with retry logic
- Better user experience for large downloads

**Features**:
- HTTP Range requests for partial downloads
- State persistence in SharedPreferences
- Automatic retry with exponential backoff
- Real-time progress tracking

---

## 3. Data Flow Architecture

### 3.1 Application Flow
```
App Launch → Onboarding Check → Model Download → Main App
     ↓
Chat Interface ← → File Management ← → Settings
     ↓              ↓                    ↓
LLM Service    File Service        Storage Service
     ↓              ↓                    ↓
Gemma Model    Local Storage      SharedPreferences
```

### 3.2 State Management Flow
```
User Action → Event → BLoC → State → UI Update
     ↓
Service Call → Data Processing → State Update
```

### 3.3 Download Flow
```
Check State → Resume/Start Download → Progress Updates → Completion
     ↓              ↓                      ↓              ↓
LocalStorage   HTTP Range Requests    UI Updates    Model Initialization
```

### 3.4 Voice Input Flow
```
User Tap Mic → Start Listening → Speech Recognition → Text Processing → Send Message
     ↓              ↓                    ↓                ↓              ↓
Voice BLoC    Speech Service      Device API        Voice BLoC    Chat BLoC
```

### 3.5 Voice Output Flow
```
AI Response → Check Voice Output → Text-to-Speech → Audio Playback
     ↓              ↓                    ↓              ↓
Chat BLoC     Voice BLoC         TTS Service    Device Audio
```

---

## 4. Component Architecture

### 4.1 Presentation Layer
**Responsibility**: UI components and user interaction

**Components**:
- **Chat Screen**: Message display and input with voice integration
- **File Management Screen**: File upload and management
- **Settings Screen**: App configuration, agents, and voice settings
- **Download Screen**: Model download with progress
- **Unified UI Components**: Reusable design system including voice components
  - **VoiceInputButton**: Microphone button for speech input
  - **VoiceOutputToggle**: Switch for enabling/disabling voice output
  - **VoiceSettingsPanel**: Configuration panel for voice settings

### 4.2 Business Logic Layer
**Responsibility**: State management and business rules

**Components**:
- **Chat BLoC**: Message handling and conversation management
- **File BLoC**: File upload, processing, and management
- **Agent BLoC**: AI agent creation and configuration
- **Voice BLoC**: Speech recognition and text-to-speech state management
- **Download State**: Download progress and state management

### 4.3 Data Layer
**Responsibility**: Data access and external services

**Components**:
- **LLM Service**: AI model interaction
- **File Processing Service**: Document analysis
- **Storage Service**: Local data persistence
- **Enhanced Model Downloader**: Smart download management
- **Speech Service**: Device-native speech recognition
- **TTS Service**: Device-native text-to-speech

---

## 5. Security Architecture

### 5.1 Data Protection
- **Local Processing**: No data transmission to external servers
- **Voice Data**: All speech recognition and TTS processing happens locally
- **No Cloud Storage**: Voice recordings are not stored or transmitted
- **Device Permissions**: Minimal required permissions for microphone access
- **Encrypted Storage**: Local data encrypted at rest
- **Token Security**: Secure API token handling
- **Model Security**: Verified model sources and integrity checks

### 5.2 Privacy Implementation
- **No Cloud Storage**: All data stays on device
- **No Analytics**: No user tracking or analytics
- **No External APIs**: Except for initial model download
- **User Control**: User controls all data

---

## 6. Performance Architecture

### 6.1 Memory Management
- **Model Loading**: Efficient model initialization
- **File Processing**: Streaming file operations
- **UI Rendering**: Optimized widget rebuilds
- **State Management**: Minimal memory footprint

### 6.2 Storage Optimization
- **Local Storage**: Efficient data persistence
- **Cache Management**: Smart cache invalidation
- **File Compression**: Optimized file storage
- **Download State**: Minimal state storage

### 6.3 Response Time Optimization
- **AI Processing**: Optimized inference pipeline
- **File Operations**: Background processing
- **UI Updates**: Efficient state management
- **Download Speed**: HTTP Range requests

---

## 7. Error Handling Architecture

### 7.1 Error Categories
- **Network Errors**: Download and connectivity issues
- **File Errors**: Processing and validation errors
- **AI Errors**: Model inference failures
- **System Errors**: App crashes and exceptions

### 7.2 Error Recovery Strategies
- **Automatic Retry**: Exponential backoff for network errors
- **Graceful Degradation**: Fallback options for AI failures
- **User Recovery**: Clear error messages and retry options
- **State Recovery**: Persist and restore app state

---

## 8. Scalability Considerations

### 8.1 Code Scalability
- **Modular Architecture**: Feature-based organization
- **Dependency Injection**: Loose coupling between components
- **Interface Design**: Future-proof service contracts
- **Component Reusability**: Shared UI components

### 8.2 Performance Scalability
- **Model Optimization**: Smaller, faster models
- **Memory Efficiency**: Reduced memory footprint
- **Processing Optimization**: Efficient algorithms
- **Storage Optimization**: Compressed data storage

### 8.3 Feature Scalability
- **Plugin System**: Extensible architecture
- **API Design**: Future-proof service interfaces
- **Data Models**: Flexible data structures
- **UI Components**: Reusable design system

---

**Document Version:** 2.0  
**Last Updated:** July 2025  
**Next Review:** August 2025 