# GenLite Architecture Flow Diagram

## 🏗️ Overall Architecture Flow

```mermaid
graph TB
    subgraph "User Interface Layer"
        CS[Chat Screen]
        FMS[File Management Screen]
        AMS[Agent Management Screen]
        MS[Main Screen]
    end

    subgraph "State Management Layer"
        CB[ChatBloc]
        FB[FileBloc]
        AB[AgentBloc]
    end

    subgraph "Domain Layer"
        CM[Conversation Model]
        MM[Message Model]
        FM[File Model]
        AM[Agent Model]
    end

    subgraph "Infrastructure Layer"
        LLM[Local LLM - Gemma 2B]
        FS[File System]
        DB[Local Database]
    end

    MS --> CS
    MS --> FMS
    MS --> AMS

    CS --> CB
    FMS --> FB
    AMS --> AB

    CB --> CM
    CB --> MM
    FB --> FM
    AB --> AM

    CB --> LLM
    FB --> FS
    AB --> DB
    CB --> DB
```

## 🔄 P0 - Chat Interface Flow

```mermaid
sequenceDiagram
    participant U as User
    participant CS as Chat Screen
    participant CB as ChatBloc
    participant LLM as Local LLM
    participant DB as Database

    U->>CS: Type message & send
    CS->>CB: SendMessage event
    CB->>CB: Update state to loading
    CS->>CS: Show typing indicator
    
    CB->>LLM: Process message
    LLM->>CB: Return AI response
    CB->>CB: Add message to conversation
    CB->>DB: Save conversation
    CB->>CS: Update state with response
    CS->>CS: Display message bubble
    CS->>CS: Hide typing indicator
```

## 📁 P1 - File Upload & Q&A Flow

```mermaid
sequenceDiagram
    participant U as User
    participant FMS as File Management Screen
    participant FB as FileBloc
    participant FP as File Picker
    participant FS as File System
    participant CS as Chat Screen

    U->>FMS: Tap upload button
    FMS->>FP: Pick file
    FP->>FB: PickFile event
    FB->>FS: Save file locally
    FB->>FB: Create FileModel
    FB->>FMS: Update state with file
    
    FB->>FB: ProcessFile event
    FB->>FB: Extract content (TXT/PDF/DOCX)
    FB->>FB: Mark as processed
    FMS->>FMS: Show "Ready for Q&A" badge
    
    U->>FMS: Tap processed file
    FMS->>CS: Navigate to chat with file context
    CS->>CB: AddFileContext event
    CB->>CB: Include file content in conversation
    U->>CS: Ask questions about file
    CS->>LLM: Send question with file context
    LLM->>CS: Return contextual response
```

## 🤖 P2 - Custom Agents Flow

```mermaid
sequenceDiagram
    participant U as User
    participant AMS as Agent Management Screen
    participant AB as AgentBloc
    participant CS as Chat Screen
    participant LLM as Local LLM

    U->>AMS: Create custom agent
    AMS->>AB: CreateAgent event
    AB->>AB: Create AgentModel
    AB->>AMS: Update state
    
    U->>AMS: Activate agent
    AMS->>AB: SetActiveAgent event
    AB->>AB: Set as active agent
    AB->>CS: Update chat context
    
    U->>CS: Send message
    CS->>CB: SendMessage with active agent
    CB->>LLM: Send message + agent system prompt
    LLM->>CS: Return agent-specific response
    
    U->>AMS: Use template
    AMS->>AB: LoadAgentTemplates event
    AB->>AB: Load predefined templates
    AB->>AMS: Display templates
    U->>AMS: Select template
    AMS->>AB: CreateFromTemplate
    AB->>AB: Create agent from template
```

## 🔍 P1 - Conversation Management Flow

```mermaid
sequenceDiagram
    participant U as User
    participant CS as Chat Screen
    participant CB as ChatBloc
    participant DB as Database

    U->>CS: Search conversations
    CS->>CB: SearchConversations event
    CB->>DB: Query conversations
    DB->>CB: Return filtered results
    CB->>CS: Update state with results
    
    U->>CS: Export conversation
    CS->>CB: ExportConversation event
    CB->>CB: Format conversation (TXT/PDF/JSON)
    CB->>FS: Save export file
    CB->>CS: Show export success
    
    U->>CS: Delete conversation
    CS->>CB: DeleteConversation event
    CB->>DB: Remove conversation
    CB->>CS: Update state
    CS->>CS: Remove from UI
```

## 🏛️ Clean Architecture Layers

```mermaid
graph LR
    subgraph "Presentation Layer"
        UI[UI Components]
        BLoC[BLoC Consumers]
    end

    subgraph "Domain Layer"
        UC[Use Cases]
        EN[Entities]
        REP[Repository Interfaces]
    end

    subgraph "Data Layer"
        DS[Data Sources]
        DM[Data Models]
        REP_IMPL[Repository Implementations]
    end

    subgraph "Infrastructure Layer"
        EX[External Dependencies]
        ST[Storage]
        NET[Network]
    end

    UI --> BLoC
    BLoC --> UC
    UC --> EN
    UC --> REP
    REP --> REP_IMPL
    REP_IMPL --> DS
    DS --> EX
    DS --> ST
```

## 📊 State Management Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading : Load event
    Loading --> Loaded : Success
    Loading --> Error : Failure
    Error --> Loading : Retry
    
    Loaded --> Creating : Create event
    Creating --> Loaded : Success
    Creating --> Error : Failure
    
    Loaded --> Updating : Update event
    Updating --> Loaded : Success
    Updating --> Error : Failure
    
    Loaded --> Deleting : Delete event
    Deleting --> Loaded : Success
    Deleting --> Error : Failure
    
    Loaded --> Processing : Process event
    Processing --> Loaded : Success
    Processing --> Error : Failure
```

## 🔗 Feature Integration Points

```mermaid
graph TB
    subgraph "Core Features"
        CHAT[P0: Chat Interface]
        FILE[P1: File Management]
        AGENT[P2: Custom Agents]
        CONV[P1: Conversation Management]
    end

    subgraph "Integration Points"
        IP1[File Context in Chat]
        IP2[Agent Context in Chat]
        IP3[Conversation Export]
        IP4[Agent Templates]
    end

    CHAT --> IP1
    FILE --> IP1
    
    CHAT --> IP2
    AGENT --> IP2
    
    CHAT --> IP3
    CONV --> IP3
    
    AGENT --> IP4
    CONV --> IP4
```

## 🎯 User Journey Flow

```mermaid
journey
    title GenLite User Journey
    section Onboarding
      Open App: 5: User
      Create First Conversation: 4: User
      Send First Message: 5: User
    section File Management
      Upload Document: 4: User
      Process File: 3: User
      Ask Questions: 5: User
    section Agent Management
      Browse Templates: 4: User
      Create Custom Agent: 3: User
      Activate Agent: 4: User
    section Advanced Usage
      Search Conversations: 3: User
      Export Data: 2: User
      Manage Files: 3: User
```

## 🔧 Technical Implementation Flow

```mermaid
graph LR
    subgraph "Frontend"
        WIDGET[Flutter Widgets]
        BLOC[BLoC Pattern]
        STATE[State Management]
    end

    subgraph "Backend"
        MODEL[Local LLM]
        STORAGE[Local Storage]
        PROCESSING[File Processing]
    end

    subgraph "Data Flow"
        EVENT[Events]
        STATE_CHANGE[State Changes]
        UI_UPDATE[UI Updates]
    end

    WIDGET --> BLOC
    BLOC --> STATE
    STATE --> WIDGET
    
    BLOC --> MODEL
    BLOC --> STORAGE
    BLOC --> PROCESSING
    
    EVENT --> STATE_CHANGE
    STATE_CHANGE --> UI_UPDATE
```

## 📱 Cross-Platform Flow

```mermaid
graph TB
    subgraph "Platforms"
        IOS[iOS]
        ANDROID[Android]
        WEB[Web]
    end

    subgraph "Shared Components"
        CORE[Core Logic]
        UI[UI Components]
        BLOC[BLoC Logic]
    end

    subgraph "Platform Specific"
        IOS_SPEC[iOS Specific]
        ANDROID_SPEC[Android Specific]
        WEB_SPEC[Web Specific]
    end

    IOS --> CORE
    ANDROID --> CORE
    WEB --> CORE
    
    CORE --> UI
    CORE --> BLOC
    
    UI --> IOS_SPEC
    UI --> ANDROID_SPEC
    UI --> WEB_SPEC
```

---

## 📋 Implementation Status Summary

| Feature | Priority | Status | Components |
|---------|----------|--------|------------|
| Chat Interface | P0 | ✅ Complete | ChatBloc, ChatScreen, MessageBubble |
| File Upload & Q&A | P1 | ✅ Complete | FileBloc, FileManagementScreen, FileModel |
| Custom Agents | P2 | ✅ Complete | AgentBloc, AgentManagementScreen, AgentModel |
| Conversation Management | P1 | ✅ Complete | ChatBloc events, conversation persistence |
| Local LLM Integration | P0 | 🔄 Pending | flutter_gemma integration |
| File Processing | P1 | 🔄 Pending | PDF/DOCX parsing libraries |
| Persistent Storage | P1 | 🔄 Pending | Hive/SQLite implementation |

## 🎯 Next Steps

1. **Integrate flutter_gemma** for actual LLM functionality
2. **Add file processing libraries** (pdf_text, docx) for document parsing
3. **Implement persistent storage** with Hive or SQLite
4. **Add navigation** between screens
5. **Connect BLoCs** in main app widget
6. **Add error handling** and loading states
7. **Implement export functionality** for conversations
8. **Add search functionality** for conversations and files 