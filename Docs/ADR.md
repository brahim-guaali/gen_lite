# Architecture Decision Records (ADR)

## ADR-001: Unified UI Design System

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need for consistent, maintainable UI components across the application.

**Decision:** Implement a unified UI design system with reusable components in `lib/shared/widgets/ui_components.dart`.

**Consequences:**
- ✅ **Positive**: Consistent look and feel across all screens
- ✅ **Positive**: Easier maintenance and updates
- ✅ **Positive**: Better developer experience
- ✅ **Positive**: Improved accessibility and responsiveness
- ⚠️ **Trade-off**: Initial development overhead for component creation

**Implementation:**
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

---

## ADR-002: Enhanced Model Downloader with Resume Functionality

**Date:** December 2024  
**Status:** Accepted  
**Context:** Large model downloads (~4GB) can be interrupted, requiring robust download management.

**Decision:** Implement `EnhancedModelDownloader` with resume capability, state persistence, and error recovery.

**Consequences:**
- ✅ **Positive**: Users can resume interrupted downloads
- ✅ **Positive**: Download progress persists across app restarts
- ✅ **Positive**: Robust error handling with retry logic
- ✅ **Positive**: Better user experience for large downloads
- ⚠️ **Trade-off**: Increased complexity in download management
- ⚠️ **Trade-off**: Additional storage for download state

**Implementation:**
```dart
class EnhancedModelDownloader {
  static Future<String> ensureGemmaModel({
    bool allowResume = true,
    void Function(ProgressInfo info)? onProgress,
  })
}
```

---

## ADR-003: BLoC Pattern for State Management

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need for predictable, testable state management across features.

**Decision:** Use BLoC (Business Logic Component) pattern for all state management.

**Consequences:**
- ✅ **Positive**: Clean separation of business logic and UI
- ✅ **Positive**: Predictable state changes
- ✅ **Positive**: Excellent testability
- ✅ **Positive**: Reactive architecture
- ⚠️ **Trade-off**: Learning curve for developers
- ⚠️ **Trade-off**: Boilerplate code for simple states

**Implementation:**
```dart
// Events
class SendMessage extends ChatEvent
class PickFile extends FileEvent

// States
class ChatLoaded extends ChatState
class FileLoaded extends FileState
```

---

## ADR-004: Clean Architecture Pattern

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need for scalable, maintainable codebase with clear separation of concerns.

**Decision:** Implement Clean Architecture with clear layers: Presentation, Business Logic, and Data.

**Consequences:**
- ✅ **Positive**: Clear separation of concerns
- ✅ **Positive**: Easy to test and maintain
- ✅ **Positive**: Scalable architecture
- ✅ **Positive**: Dependency inversion
- ⚠️ **Trade-off**: More initial setup complexity
- ⚠️ **Trade-off**: More files and directories

**Structure:**
```
lib/
├── core/           # App-wide utilities
├── features/       # Feature modules
└── shared/         # Shared services and widgets
```

---

## ADR-005: Local-Only AI Processing

**Date:** December 2024  
**Status:** Accepted  
**Context:** Privacy concerns and need for offline functionality.

**Decision:** All AI processing happens locally using the Gemma 2B model, no cloud processing.

**Consequences:**
- ✅ **Positive**: Complete privacy protection
- ✅ **Positive**: Works offline
- ✅ **Positive**: No ongoing costs
- ✅ **Positive**: No data transmission
- ⚠️ **Trade-off**: Limited by device performance
- ⚠️ **Trade-off**: Large model download required
- ⚠️ **Trade-off**: Cannot leverage cloud computing power

**Implementation:**
```dart
class LLMService {
  Future<String> generateResponse(String prompt) // Local processing only
}
```

---

## ADR-006: Material 3 Design System

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need for modern, accessible UI that follows platform guidelines.

**Decision:** Implement Material 3 design system with custom theming.

**Consequences:**
- ✅ **Positive**: Modern, accessible design
- ✅ **Positive**: Platform consistency
- ✅ **Positive**: Built-in accessibility features
- ✅ **Positive**: Future-proof design system
- ⚠️ **Trade-off**: Limited to Material Design patterns
- ⚠️ **Trade-off**: May not match native platform look exactly

**Implementation:**
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(useMaterial3: true, ...)
  static ThemeData darkTheme = ThemeData(useMaterial3: true, ...)
}
```

---

## ADR-007: SharedPreferences for Download State

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need to persist download progress across app restarts.

**Decision:** Use SharedPreferences to store download state and progress.

**Consequences:**
- ✅ **Positive**: Simple key-value storage
- ✅ **Positive**: Cross-platform compatibility
- ✅ **Positive**: Automatic serialization
- ✅ **Positive**: Lightweight solution
- ⚠️ **Trade-off**: Limited to simple data types
- ⚠️ **Trade-off**: Not suitable for large data

**Implementation:**
```dart
static Future<void> _saveDownloadState(String modelId, String filename, DownloadState state)
```

---

## ADR-008: HTTP Range Requests for Resume

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need to resume large file downloads from where they left off.

**Decision:** Use HTTP Range requests to support partial downloads.

**Consequences:**
- ✅ **Positive**: Efficient resume functionality
- ✅ **Positive**: Bandwidth savings
- ✅ **Positive**: Better user experience
- ✅ **Positive**: Standard HTTP feature
- ⚠️ **Trade-off**: Requires server support
- ⚠️ **Trade-off**: More complex download logic

**Implementation:**
```dart
if (resumeFrom > 0) {
  request.headers['Range'] = 'bytes=$resumeFrom-';
}
```

---

## ADR-009: File Processing Service

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need to extract and process content from various file formats.

**Decision:** Implement dedicated file processing service with format-specific handlers.

**Consequences:**
- ✅ **Positive**: Centralized file processing logic
- ✅ **Positive**: Easy to add new file formats
- ✅ **Positive**: Consistent processing pipeline
- ✅ **Positive**: Better error handling
- ⚠️ **Trade-off**: Additional complexity
- ⚠️ **Trade-off**: More dependencies

**Implementation:**
```dart
class FileProcessingService {
  Future<String> extractText(String filePath, String fileType)
  Future<void> processFile(File file)
}
```

---

## ADR-010: Responsive Design with Fixed Constraints

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need to prevent layout shifts and ensure stable UI during dynamic content updates.

**Decision:** Use fixed constraints and proper layout management to prevent UI shaking.

**Consequences:**
- ✅ **Positive**: Stable UI during content updates
- ✅ **Positive**: Better user experience
- ✅ **Positive**: Predictable layouts
- ✅ **Positive**: Professional appearance
- ⚠️ **Trade-off**: Less flexible layouts
- ⚠️ **Trade-off**: Requires careful planning

**Implementation:**
```dart
Container(
  height: 120, // Fixed height to prevent layout shifts
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [...],
  ),
)
```

---

## ADR-011: Error Handling Strategy

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need robust error handling for network, file, and AI operations.

**Decision:** Implement comprehensive error handling with user-friendly messages and recovery options.

**Consequences:**
- ✅ **Positive**: Better user experience during errors
- ✅ **Positive**: Clear error communication
- ✅ **Positive**: Recovery mechanisms
- ✅ **Positive**: Debugging information
- ⚠️ **Trade-off**: More complex error handling code
- ⚠️ **Trade-off**: Need to maintain error messages

**Implementation:**
```dart
try {
  await downloadModel();
} catch (e) {
  showErrorDialog(context, e.toString());
  provideRetryOption();
}
```

---

## ADR-012: Animation and Transition Strategy

**Date:** December 2024  
**Status:** Accepted  
**Context:** Need smooth, professional animations without causing layout issues.

**Decision:** Use subtle animations with proper constraints and avoid layout-affecting transforms.

**Consequences:**
- ✅ **Positive**: Professional user experience
- ✅ **Positive**: Smooth transitions
- ✅ **Positive**: No layout shaking
- ✅ **Positive**: Performance optimized
- ⚠️ **Trade-off**: More complex animation code
- ⚠️ **Trade-off**: Need to test on different devices

**Implementation:**
```dart
// Use opacity and glow instead of scale transforms
BoxShadow(
  color: AppConstants.primaryColor.withValues(alpha: _pulseController.value * 0.3),
  blurRadius: 20,
  spreadRadius: 5,
)
```

---

## Summary

These ADRs document the key architectural decisions that shape GenLite's design and implementation. Each decision balances technical requirements with user experience needs, ensuring a robust, maintainable, and user-friendly application.

**Key Principles:**
1. **Privacy First**: All processing happens locally
2. **User Experience**: Smooth, stable, and intuitive interface
3. **Maintainability**: Clean architecture and consistent patterns
4. **Reliability**: Robust error handling and recovery mechanisms
5. **Performance**: Optimized for mobile devices

**Next Review:** January 2025 