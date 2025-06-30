# GenLite Architecture Flow Diagram

## Overview

This document provides a comprehensive view of GenLite's architecture, data flow, and component interactions. The application follows Clean Architecture principles with a focus on privacy, performance, and user experience.

## System Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[Unified UI Components]
        ChatUI[Chat Screen]
        FileUI[File Management Screen]
        SettingsUI[Settings Screen]
        DownloadUI[Download Screen]
    end
    
    subgraph "Business Logic Layer"
        ChatBLoC[Chat BLoC]
        FileBLoC[File BLoC]
        AgentBLoC[Agent BLoC]
        DownloadBLoC[Download State]
    end
    
    subgraph "Data Layer"
        LLMService[LLM Service]
        FileService[File Processing Service]
        StorageService[Storage Service]
        DownloadService[Enhanced Model Downloader]
    end
    
    subgraph "External Dependencies"
        GemmaModel[Gemma 2B Model]
        HuggingFace[Hugging Face API]
        LocalStorage[Local Storage]
    end
    
    UI --> ChatUI
    UI --> FileUI
    UI --> SettingsUI
    UI --> DownloadUI
    
    ChatUI --> ChatBLoC
    FileUI --> FileBLoC
    SettingsUI --> AgentBLoC
    DownloadUI --> DownloadBLoC
    
    ChatBLoC --> LLMService
    FileBLoC --> FileService
    AgentBLoC --> StorageService
    DownloadBLoC --> DownloadService
    
    LLMService --> GemmaModel
    DownloadService --> HuggingFace
    StorageService --> LocalStorage
    FileService --> LocalStorage
```

## Component Details

### 1. Unified UI Design System

```mermaid
graph LR
    subgraph "UI Components Library"
        Buttons[Button Components]
        Cards[Card Components]
        Progress[Progress Indicators]
        Icons[Icon Components]
        Utils[Utility Components]
    end
    
    subgraph "Design Principles"
        Consistency[Consistency]
        Accessibility[Accessibility]
        Responsiveness[Responsiveness]
        Performance[Performance]
    end
    
    Buttons --> Consistency
    Cards --> Accessibility
    Progress --> Responsiveness
    Icons --> Performance
    Utils --> Consistency
```

**Key Components:**
- `PrimaryButton`: Main action buttons with loading states
- `SecondaryButton`: Secondary actions with outline style
- `DangerButton`: Destructive actions with error styling
- `AppCard`: Consistent card styling with optional tap actions
- `AppProgressBar`: Animated progress bars with proper width calculation
- `AppIcon`: Consistent icon styling with background options
- `AppBadge`: Status indicators and labels
- `AppDivider`: Consistent dividers
- `AppSpacing`: Standardized spacing constants

### 2. Enhanced Model Downloader

```mermaid
sequenceDiagram
    participant User
    participant DownloadUI
    participant DownloadService
    participant HuggingFace
    participant LocalStorage
    
    User->>DownloadUI: Start Download
    DownloadUI->>DownloadService: Check Existing State
    DownloadService->>LocalStorage: Get Download State
    
    alt Has Incomplete Download
        DownloadService->>DownloadUI: Resume from Position
        DownloadUI->>User: Show Resume Status
    end
    
    DownloadService->>HuggingFace: Request Model (with Range if resuming)
    HuggingFace->>DownloadService: Stream Model Data
    DownloadService->>DownloadUI: Progress Updates
    DownloadService->>LocalStorage: Save Progress Periodically
    
    DownloadService->>DownloadUI: Download Complete
    DownloadUI->>User: Show Success
```

**Key Features:**
- **Resume Functionality**: HTTP Range requests for partial downloads
- **State Persistence**: Download progress saved to SharedPreferences
- **Error Recovery**: Automatic retry with exponential backoff
- **Progress Tracking**: Real-time speed, time, and percentage updates
- **File Integrity**: Validation of downloaded chunks

### 3. Application Flow

```mermaid
flowchart TD
    Start([App Launch]) --> Onboarding{First Launch?}
    Onboarding -->|Yes| Welcome[Welcome Screen]
    Onboarding -->|No| CheckModel{Model Downloaded?}
    
    Welcome --> Terms[Terms Acceptance]
    Terms --> Download[Model Download]
    
    CheckModel -->|Yes| MainApp[Main Application]
    CheckModel -->|No| Download
    
    Download --> DownloadComplete{Download Success?}
    DownloadComplete -->|Yes| MainApp
    DownloadComplete -->|No| Error[Error Screen]
    
    Error --> Retry{Retry?}
    Retry -->|Yes| Download
    Retry -->|No| Skip[Skip to App]
    
    MainApp --> Chat[Chat Interface]
    MainApp --> Files[File Management]
    MainApp --> Settings[Settings]
    
    Chat --> SendMessage[Send Message]
    SendMessage --> LLM[Local AI Processing]
    LLM --> Response[AI Response]
    
    Files --> Upload[Upload File]
    Upload --> Process[Process File]
    Process --> Query[Query File Content]
    Query --> LLM
    
    Skip --> MainApp
```

### 4. State Management Flow

```mermaid
graph TD
    subgraph "Chat Feature"
        ChatEvent[Chat Events]
        ChatBLoC[Chat BLoC]
        ChatState[Chat States]
        ChatUI[Chat UI]
    end
    
    subgraph "File Management"
        FileEvent[File Events]
        FileBLoC[File BLoC]
        FileState[File States]
        FileUI[File UI]
    end
    
    subgraph "Settings"
        AgentEvent[Agent Events]
        AgentBLoC[Agent BLoC]
        AgentState[Agent States]
        SettingsUI[Settings UI]
    end
    
    ChatEvent --> ChatBLoC
    ChatBLoC --> ChatState
    ChatState --> ChatUI
    
    FileEvent --> FileBLoC
    FileBLoC --> FileState
    FileState --> FileUI
    
    AgentEvent --> AgentBLoC
    AgentBLoC --> AgentState
    AgentState --> SettingsUI
```

### 5. Data Flow Architecture

```mermaid
graph LR
    subgraph "User Input"
        TextInput[Text Messages]
        FileInput[File Uploads]
        SettingsInput[Settings Changes]
    end
    
    subgraph "Processing"
        TextProcessing[Text Processing]
        FileProcessing[File Processing]
        SettingsProcessing[Settings Processing]
    end
    
    subgraph "Storage"
        ConversationDB[Conversation Storage]
        FileDB[File Storage]
        SettingsDB[Settings Storage]
    end
    
    subgraph "AI Processing"
        LocalLLM[Local LLM]
        Context[Context Management]
        Response[Response Generation]
    end
    
    TextInput --> TextProcessing
    FileInput --> FileProcessing
    SettingsInput --> SettingsProcessing
    
    TextProcessing --> ConversationDB
    FileProcessing --> FileDB
    SettingsProcessing --> SettingsDB
    
    ConversationDB --> LocalLLM
    FileDB --> Context
    Context --> LocalLLM
    LocalLLM --> Response
```

### 6. Error Handling Flow

```mermaid
flowchart TD
    Operation[Any Operation] --> Try{Try Operation}
    Try --> Success{Success?}
    
    Success -->|Yes| Continue[Continue Flow]
    Success -->|No| ErrorType{Error Type?}
    
    ErrorType -->|Network| NetworkError[Network Error Handler]
    ErrorType -->|File| FileError[File Error Handler]
    ErrorType -->|AI| AIError[AI Error Handler]
    ErrorType -->|General| GeneralError[General Error Handler]
    
    NetworkError --> Retry{Retry?}
    FileError --> Retry
    AIError --> Retry
    GeneralError --> Retry
    
    Retry -->|Yes| Try
    Retry -->|No| UserChoice{User Choice?}
    
    UserChoice -->|Skip| SkipOperation[Skip Operation]
    UserChoice -->|Cancel| CancelOperation[Cancel Operation]
    UserChoice -->|Manual Retry| Try
    
    SkipOperation --> Continue
    CancelOperation --> End[End Flow]
```

### 7. Security and Privacy Flow

```mermaid
graph TD
    subgraph "Data Input"
        UserData[User Input]
        FileData[File Data]
        SettingsData[Settings Data]
    end
    
    subgraph "Local Processing"
        LocalStorage[Local Storage Only]
        LocalAI[Local AI Processing]
        LocalFile[Local File Processing]
    end
    
    subgraph "No External Transmission"
        NoCloud[No Cloud Storage]
        NoAnalytics[No Analytics]
        NoTracking[No User Tracking]
    end
    
    UserData --> LocalStorage
    FileData --> LocalFile
    SettingsData --> LocalStorage
    
    LocalStorage --> LocalAI
    LocalFile --> LocalAI
    
    LocalAI --> NoCloud
    LocalAI --> NoAnalytics
    LocalAI --> NoTracking
```

## Technical Specifications

### Performance Characteristics

| Component | Response Time | Memory Usage | Storage |
|-----------|---------------|--------------|---------|
| App Launch | < 2 seconds | ~50MB | ~4GB (model) |
| Chat Response | < 3 seconds | ~100MB | Minimal |
| File Upload | < 5 seconds | ~20MB | File size |
| Model Download | Variable | ~50MB | ~4GB |

### Scalability Considerations

1. **Horizontal Scaling**: Not applicable (local-only)
2. **Vertical Scaling**: Limited by device capabilities
3. **Model Optimization**: Quantized models for efficiency
4. **Memory Management**: Efficient resource usage
5. **Storage Optimization**: Compressed model storage

### Reliability Features

1. **Download Resume**: Automatic resume of interrupted downloads
2. **Error Recovery**: Comprehensive error handling and retry logic
3. **State Persistence**: Critical state saved across app restarts
4. **Data Validation**: Input validation and file integrity checks
5. **Graceful Degradation**: App continues working with limited features

## Future Architecture Considerations

### Planned Enhancements

```mermaid
graph TD
    Current[Current Architecture] --> Voice[Voice Input/Output]
    Current --> Image[Image Analysis]
    Current --> MultiLang[Multi-language Support]
    Current --> CloudSync[Optional Cloud Sync]
    Current --> Plugins[Plugin System]
    
    Voice --> EnhancedUX[Enhanced UX]
    Image --> VisualAI[Visual AI Capabilities]
    MultiLang --> Global[Global Accessibility]
    CloudSync --> Backup[Data Backup]
    Plugins --> Extensible[Extensible Platform]
```

### Scalability Roadmap

1. **Model Optimization**: Smaller, faster models
2. **Memory Efficiency**: Reduced memory footprint
3. **Battery Optimization**: Power-efficient processing
4. **Startup Speed**: Faster app initialization
5. **Offline Capabilities**: Complete offline functionality

---

## Conclusion

GenLite's architecture prioritizes privacy, performance, and user experience while maintaining clean, maintainable code. The unified design system, enhanced download management, and robust error handling create a professional, reliable application that users can trust with their data.

**Key Architectural Principles:**
1. **Privacy First**: All processing happens locally
2. **User Experience**: Smooth, stable, and intuitive interface
3. **Maintainability**: Clean architecture and consistent patterns
4. **Reliability**: Robust error handling and recovery mechanisms
5. **Performance**: Optimized for mobile devices

**Document Version:** 2.0  
**Last Updated:** December 2024  
**Next Review:** January 2025 