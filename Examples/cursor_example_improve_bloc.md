# Improve Bloc state management

**User**

push

what do thing about this pattern
if (state is! ChatLoaded) return;
in bloc handlers

---

**Cursor**

That's a great pattern! The `if (state is! ChatLoaded) return;` early return pattern in BLoC handlers is excellent for several reasons:

## ✅ **Benefits of this pattern:**

### 1. **Guard Clauses**
- Prevents unnecessary processing when the state isn't ready
- Makes the code more readable by handling edge cases upfront
- Reduces nesting levels in the handler

### 2. **Type Safety**
- Ensures you're working with the correct state type
- Dart's type system will enforce that you can only access `ChatLoaded` properties
- Prevents runtime errors from accessing properties on wrong state types

### 3. **Performance**
- Early exit avoids expensive operations when state isn't ready
- Particularly important for async operations

### 4. **Clean Code**
- Makes the main logic more focused
- Easier to test and debug
- Follows the "fail fast" principle

## 📝 **Example Usage:**

```dart
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // Guard clause - early return if not loaded
  if (state is! ChatLoaded) return;
  
  final currentState = state as ChatLoaded;
  
  try {
    // Now we can safely access ChatLoaded properties
    final newMessage = Message(
      content: event.content,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    final updatedMessages = [...currentState.messages, newMessage];
    emit(ChatLoaded(messages: updatedMessages));
    
    // Continue with AI response...
  } catch (e) {
    emit(ChatError(e.toString()));
  }
}
```

## 🔄 **Alternative Patterns:**

### Option 1: State-specific handlers
```dart
// Different handlers for different states
Future<void> _onSendMessageWhenLoaded(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // This handler only runs when state is ChatLoaded
}
```

### Option 2: State checking with else
```dart
if (state is ChatLoaded) {
  // Handle loaded state
} else if (state is ChatLoading) {
  // Handle loading state
} else {
  // Handle other states
}
```

## �� **When to use this pattern:**

✅ **Use when:**
- You need to access specific state properties
- The operation only makes sense in a particular state
- You want to prevent invalid state transitions

❌ **Avoid when:**
- The operation should work regardless of state
- You need to handle multiple state types differently
- The guard condition is too complex

## 💡 **Best Practices:**

1. **Keep guard clauses simple** - avoid complex logic in the condition
2. **Use descriptive state names** - `ChatLoaded` is clearer than `ChatState`
3. **Consider logging** - add debug logs for unexpected state transitions
4. **Test edge cases** - ensure your handlers work with all state combinations

This pattern is widely used in the Flutter BLoC community and is considered a best practice for state management!

```dart
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // Guard clause - early return if not loaded
  if (state is! ChatLoaded) return;
  
  final currentState = state as ChatLoaded;
  
  try {
    // Now we can safely access ChatLoaded properties
    final newMessage = Message(
      content: event.content,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    final updatedMessages = [...currentState.messages, newMessage];
    emit(ChatLoaded(messages: updatedMessages));
    
    // Continue with AI response...
  } catch (e) {
    emit(ChatError(e.toString()));
  }
}
```

```dart
// Different handlers for different states
Future<void> _onSendMessageWhenLoaded(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // This handler only runs when state is ChatLoaded
}
```

```dart
if (state is ChatLoaded) {
  // Handle loaded state
} else if (state is ChatLoading) {
  // Handle loading state
} else {
  // Handle other states
}
```

---

**User**

there is some risks with this, how can we avoid this as it assums that the prevous state is ChatLoaded

---

**Cursor**

Excellent point! You're absolutely right - there are significant risks with this pattern. The main issue is that it **assumes the previous state was `ChatLoaded`**, which can lead to bugs and unexpected behavior.

## �� **Risks of the `if (state is! ChatLoaded) return;` pattern:**

### 1. **State Race Conditions**
```dart
// RISKY: What if state changed between event emission and handler execution?
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  if (state is! ChatLoaded) return; // ❌ Assumes previous state
  
  // State could have changed to ChatLoading by now!
  final currentState = state as ChatLoaded; // ❌ Could crash
}
```

### 2. **Lost Events**
```dart
// User sends message while loading -> event is ignored
if (state is! ChatLoaded) return; // ❌ Event lost forever
```

### 3. **Inconsistent Behavior**
```dart
// Same event, different results based on timing
// Sometimes works, sometimes doesn't
```

## ✅ **Better Patterns to Avoid These Risks:**

### **Pattern 1: State-Aware Event Handling**
```dart
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // Handle all states explicitly
  if (state is ChatLoading) {
    // Queue the message or show "please wait"
    emit(ChatError("Please wait for current operation to complete"));
    return;
  }
  
  if (state is ChatError) {
    // Retry or show error message
    emit(ChatError("Please try again"));
    return;
  }
  
  if (state is ChatLoaded) {
    final currentState = state as ChatLoaded;
    // Process the message
    _processMessage(event, currentState, emit);
  }
}
```

### **Pattern 2: Event Queuing**
```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Queue<ChatEvent> _pendingEvents = Queue();
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoading) {
      // Queue the event for later
      _pendingEvents.add(event);
      return;
    }
    
    if (state is ChatLoaded) {
      await _processMessage(event, emit);
      _processPendingEvents(emit);
    }
  }
  
  void _processPendingEvents(Emitter<ChatState> emit) {
    while (_pendingEvents.isNotEmpty) {
      final event = _pendingEvents.removeFirst();
      add(event); // Re-add to the bloc
    }
  }
}
```

### **Pattern 3: State Machine Pattern**
```dart
enum ChatStateType { initial, loading, loaded, error }

class ChatState {
  final ChatStateType type;
  final List<Message>? messages;
  final String? error;
  
  const ChatState({
    required this.type,
    this.messages,
    this.error,
  });
  
  bool get canSendMessage => type == ChatStateType.loaded;
}

Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  if (!state.canSendMessage) {
    emit(ChatState(
      type: ChatStateType.error,
      error: "Cannot send message in current state",
    ));
    return;
  }
  
  // Safe to proceed
  final messages = state.messages!;
  // Process message...
}
```

### **Pattern 4: Event Validation**
```dart
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // Validate event can be processed
  final validationResult = _validateEvent(event);
  if (!validationResult.isValid) {
    emit(ChatError(validationResult.errorMessage));
    return;
  }
  
  // Safe to proceed with any state
  await _processMessageSafely(event, emit);
}

ValidationResult _validateEvent(SendMessage event) {
  if (event.content.trim().isEmpty) {
    return ValidationResult.invalid("Message cannot be empty");
  }
  
  if (state is ChatLoading) {
    return ValidationResult.invalid("Please wait for current operation");
  }
  
  return ValidationResult.valid();
}
```

## 🎯 **Recommended Approach:**

### **Use State-Specific Handlers with Proper Validation**
```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  @override
  void onEvent(ChatEvent event) {
    super.onEvent(event);
    
    // Log state transitions for debugging
    print('Event: ${event.runtimeType}, Current State: ${state.runtimeType}');
  }
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Always validate the event first
    if (event.content.trim().isEmpty) {
      emit(ChatError("Message cannot be empty"));
      return;
    }
    
    // Handle each state explicitly
    switch (state.runtimeType) {
      case ChatLoading:
        emit(ChatError("Please wait for current operation to complete"));
        break;
        
      case ChatError:
        // Optionally retry or show different message
        emit(ChatError("Please try again"));
        break;
        
      case ChatLoaded:
        await _processMessageInLoadedState(event, emit);
        break;
        
      default:
        emit(ChatError("Unexpected state: ${state.runtimeType}"));
    }
  }
  
  Future<void> _processMessageInLoadedState(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentState = state as ChatLoaded;
      // Safe to access ChatLoaded properties
      // Process message...
    } catch (e) {
      emit(ChatError("Failed to process message: $e"));
    }
  }
}
```

## 🔍 **Key Takeaways:**

1. **Never assume previous state** - always check current state
2. **Handle all state transitions explicitly** - don't ignore events
3. **Validate events before processing** - ensure they can be handled
4. **Use state machines or enums** - make state transitions explicit
5. **Log state changes** - helps with debugging race conditions
6. **Consider event queuing** - for operations that need to wait

This approach is much safer and prevents the subtle bugs that can occur with the simple guard clause pattern!

```dart
// RISKY: What if state changed between event emission and handler execution?
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  if (state is! ChatLoaded) return; // ❌ Assumes previous state
  
  // State could have changed to ChatLoading by now!
  final currentState = state as ChatLoaded; // ❌ Could crash
}
```

```dart
// User sends message while loading -> event is ignored
if (state is! ChatLoaded) return; // ❌ Event lost forever
```

```dart
// Same event, different results based on timing
// Sometimes works, sometimes doesn't
```

```dart
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // Handle all states explicitly
  if (state is ChatLoading) {
    // Queue the message or show "please wait"
    emit(ChatError("Please wait for current operation to complete"));
    return;
  }
  
  if (state is ChatError) {
    // Retry or show error message
    emit(ChatError("Please try again"));
    return;
  }
  
  if (state is ChatLoaded) {
    final currentState = state as ChatLoaded;
    // Process the message
    _processMessage(event, currentState, emit);
  }
}
```

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Queue<ChatEvent> _pendingEvents = Queue();
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoading) {
      // Queue the event for later
      _pendingEvents.add(event);
      return;
    }
    
    if (state is ChatLoaded) {
      await _processMessage(event, emit);
      _processPendingEvents(emit);
    }
  }
  
  void _processPendingEvents(Emitter<ChatState> emit) {
    while (_pendingEvents.isNotEmpty) {
      final event = _pendingEvents.removeFirst();
      add(event); // Re-add to the bloc
    }
  }
}
```

```dart
enum ChatStateType { initial, loading, loaded, error }

class ChatState {
  final ChatStateType type;
  final List<Message>? messages;
  final String? error;
  
  const ChatState({
    required this.type,
    this.messages,
    this.error,
  });
  
  bool get canSendMessage => type == ChatStateType.loaded;
}

Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  if (!state.canSendMessage) {
    emit(ChatState(
      type: ChatStateType.error,
      error: "Cannot send message in current state",
    ));
    return;
  }
  
  // Safe to proceed
  final messages = state.messages!;
  // Process message...
}
```

```dart
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // Validate event can be processed
  final validationResult = _validateEvent(event);
  if (!validationResult.isValid) {
    emit(ChatError(validationResult.errorMessage));
    return;
  }
  
  // Safe to proceed with any state
  await _processMessageSafely(event, emit);
}

ValidationResult _validateEvent(SendMessage event) {
  if (event.content.trim().isEmpty) {
    return ValidationResult.invalid("Message cannot be empty");
  }
  
  if (state is ChatLoading) {
    return ValidationResult.invalid("Please wait for current operation");
  }
  
  return ValidationResult.valid();
}
```

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  @override
  void onEvent(ChatEvent event) {
    super.onEvent(event);
    
    // Log state transitions for debugging
    print('Event: ${event.runtimeType}, Current State: ${state.runtimeType}');
  }
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Always validate the event first
    if (event.content.trim().isEmpty) {
      emit(ChatError("Message cannot be empty"));
      return;
    }
    
    // Handle each state explicitly
    switch (state.runtimeType) {
      case ChatLoading:
        emit(ChatError("Please wait for current operation to complete"));
        break;
        
      case ChatError:
        // Optionally retry or show different message
        emit(ChatError("Please try again"));
        break;
        
      case ChatLoaded:
        await _processMessageInLoadedState(event, emit);
        break;
        
      default:
        emit(ChatError("Unexpected state: ${state.runtimeType}"));
    }
  }
  
  Future<void> _processMessageInLoadedState(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentState = state as ChatLoaded;
      // Safe to access ChatLoaded properties
      // Process message...
    } catch (e) {
      emit(ChatError("Failed to process message: $e"));
    }
  }
}
```

---

**User**

is there a way to avoid getting infos from state 

---

**Cursor**

Absolutely! There are several ways to avoid getting information from state, which can help eliminate the risks we discussed. Here are the main approaches:

## 🎯 **Pattern 1: Pass Data in Events**

Instead of reading from state, pass the necessary data directly in the event:

```dart
// Instead of reading from state
class SendMessage extends ChatEvent {
  final String content;
  final List<Message> currentMessages; // Pass data in event
  final String currentAgentId;
  
  const SendMessage({
    required this.content,
    required this.currentMessages,
    required this.currentAgentId,
  });
}

// In your widget
onSendMessage() {
  final currentState = context.read<ChatBloc>().state;
  if (currentState is ChatLoaded) {
    context.read<ChatBloc>().add(SendMessage(
      content: messageText,
      currentMessages: currentState.messages,
      currentAgentId: currentState.agentId,
    ));
  }
}

// In your bloc - no state reading needed!
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // No need to check state or cast it
  final newMessage = Message(
    content: event.content,
    timestamp: DateTime.now(),
    isUser: true,
  );
  
  final updatedMessages = [...event.currentMessages, newMessage];
  emit(ChatLoaded(messages: updatedMessages));
}
```

## 🎯 **Pattern 2: Use Services/Repositories**

Move data access to services that don't depend on state:

```dart
class ChatService {
  final MessageRepository _messageRepo;
  final AgentRepository _agentRepo;
  
  Future<List<Message>> getCurrentMessages() async {
    return await _messageRepo.getAll();
  }
  
  Future<String> getCurrentAgentId() async {
    return await _agentRepo.getActiveAgentId();
  }
  
  Future<void> addMessage(Message message) async {
    await _messageRepo.add(message);
  }
}

// In your bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get data from service, not state
      final currentMessages = await _chatService.getCurrentMessages();
      final currentAgentId = await _chatService.getCurrentAgentId();
      
      final newMessage = Message(
        content: event.content,
        timestamp: DateTime.now(),
        isUser: true,
      );
      
      await _chatService.addMessage(newMessage);
      
      final updatedMessages = [...currentMessages, newMessage];
      emit(ChatLoaded(
        messages: updatedMessages,
        agentId: currentAgentId,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
```

## 🎯 **Pattern 3: Use Cubit with Direct Data Access**

Cubits can access data directly without going through state:

```dart
class ChatCubit extends Cubit<ChatState> {
  final List<Message> _messages = [];
  String _currentAgentId = 'default';
  
  ChatCubit() : super(ChatInitial());
  
  void sendMessage(String content) {
    // Access data directly from cubit, not state
    final newMessage = Message(
      content: content,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    _messages.add(newMessage);
    emit(ChatLoaded(
      messages: List.from(_messages), // Create new list
      agentId: _currentAgentId,
    ));
  }
  
  void switchAgent(String agentId) {
    _currentAgentId = agentId;
    emit(ChatLoaded(
      messages: List.from(_messages),
      agentId: _currentAgentId,
    ));
  }
}
```

## 🎯 **Pattern 4: Use State Management with Data Classes**

Create state classes that hold all necessary data:

```dart
class ChatState {
  final List<Message> messages;
  final String agentId;
  final bool isLoading;
  final String? error;
  
  const ChatState({
    this.messages = const [],
    this.agentId = 'default',
    this.isLoading = false,
    this.error,
  });
  
  ChatState copyWith({
    List<Message>? messages,
    String? agentId,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      agentId: agentId ?? this.agentId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// In your bloc - always work with the same state type
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  if (state.isLoading) {
    emit(state.copyWith(error: "Please wait"));
    return;
  }
  
  final newMessage = Message(
    content: event.content,
    timestamp: DateTime.now(),
    isUser: true,
  );
  
  final updatedMessages = [...state.messages, newMessage];
  emit(state.copyWith(
    messages: updatedMessages,
    isLoading: false,
    error: null,
  ));
}
```

## 🎯 **Pattern 5: Use Event Sourcing**

Store all events and rebuild state from them:

```dart
class ChatEventStore {
  final List<ChatEvent> _events = [];
  
  void addEvent(ChatEvent event) {
    _events.add(event);
  }
  
  ChatState getCurrentState() {
    // Rebuild state from all events
    List<Message> messages = [];
    String agentId = 'default';
    bool isLoading = false;
    String? error;
    
    for (final event in _events) {
      if (event is SendMessage) {
        messages.add(Message(
          content: event.content,
          timestamp: DateTime.now(),
          isUser: true,
        ));
      } else if (event is SwitchAgent) {
        agentId = event.agentId;
      } else if (event is StartLoading) {
        isLoading = true;
      } else if (event is StopLoading) {
        isLoading = false;
      }
    }
    
    return ChatState(
      messages: messages,
      agentId: agentId,
      isLoading: isLoading,
      error: error,
    );
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatEventStore _eventStore;
  
  ChatBloc(this._eventStore) : super(ChatInitial()) {
    on<ChatEvent>((event, emit) {
      _eventStore.addEvent(event);
      emit(_eventStore.getCurrentState());
    });
  }
}
```

## 🎯 **Pattern 6: Use Dependency Injection with Stateful Services**

```dart
class ChatDataService {
  List<Message> _messages = [];
  String _agentId = 'default';
  
  List<Message> get messages => List.unmodifiable(_messages);
  String get agentId => _agentId;
  
  void addMessage(Message message) {
    _messages.add(message);
  }
  
  void setAgentId(String agentId) {
    _agentId = agentId;
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatDataService _dataService;
  
  ChatBloc(this._dataService) : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
  }
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Get data from service, not state
    final newMessage = Message(
      content: event.content,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    _dataService.addMessage(newMessage);
    
    emit(ChatLoaded(
      messages: _dataService.messages,
      agentId: _dataService.agentId,
    ));
  }
}
```

## 🏆 **Recommended Approach:**

I'd recommend **Pattern 2 (Services/Repositories)** combined with **Pattern 4 (Data Classes)**:

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get fresh data from service
      final currentData = await _chatService.getCurrentData();
      
      final newMessage = Message(
        content: event.content,
        timestamp: DateTime.now(),
        isUser: true,
      );
      
      await _chatService.addMessage(newMessage);
      
      // Emit new state with updated data
      emit(ChatState(
        messages: [...currentData.messages, newMessage],
        agentId: currentData.agentId,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
```

## ✅ **Benefits of Avoiding State Reading:**

1. **No race conditions** - always get fresh data
2. **No state assumptions** - data comes from reliable sources
3. **Easier testing** - mock services instead of complex state
4. **Better separation of concerns** - data access separate from state management
5. **More predictable** - data flow is explicit and traceable

This approach eliminates the risks we discussed earlier while making your code more maintainable and testable!

```dart
// Instead of reading from state
class SendMessage extends ChatEvent {
  final String content;
  final List<Message> currentMessages; // Pass data in event
  final String currentAgentId;
  
  const SendMessage({
    required this.content,
    required this.currentMessages,
    required this.currentAgentId,
  });
}

// In your widget
onSendMessage() {
  final currentState = context.read<ChatBloc>().state;
  if (currentState is ChatLoaded) {
    context.read<ChatBloc>().add(SendMessage(
      content: messageText,
      currentMessages: currentState.messages,
      currentAgentId: currentState.agentId,
    ));
  }
}

// In your bloc - no state reading needed!
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  // No need to check state or cast it
  final newMessage = Message(
    content: event.content,
    timestamp: DateTime.now(),
    isUser: true,
  );
  
  final updatedMessages = [...event.currentMessages, newMessage];
  emit(ChatLoaded(messages: updatedMessages));
}
```

```dart
class ChatService {
  final MessageRepository _messageRepo;
  final AgentRepository _agentRepo;
  
  Future<List<Message>> getCurrentMessages() async {
    return await _messageRepo.getAll();
  }
  
  Future<String> getCurrentAgentId() async {
    return await _agentRepo.getActiveAgentId();
  }
  
  Future<void> addMessage(Message message) async {
    await _messageRepo.add(message);
  }
}

// In your bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get data from service, not state
      final currentMessages = await _chatService.getCurrentMessages();
      final currentAgentId = await _chatService.getCurrentAgentId();
      
      final newMessage = Message(
        content: event.content,
        timestamp: DateTime.now(),
        isUser: true,
      );
      
      await _chatService.addMessage(newMessage);
      
      final updatedMessages = [...currentMessages, newMessage];
      emit(ChatLoaded(
        messages: updatedMessages,
        agentId: currentAgentId,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
```

```dart
class ChatCubit extends Cubit<ChatState> {
  final List<Message> _messages = [];
  String _currentAgentId = 'default';
  
  ChatCubit() : super(ChatInitial());
  
  void sendMessage(String content) {
    // Access data directly from cubit, not state
    final newMessage = Message(
      content: content,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    _messages.add(newMessage);
    emit(ChatLoaded(
      messages: List.from(_messages), // Create new list
      agentId: _currentAgentId,
    ));
  }
  
  void switchAgent(String agentId) {
    _currentAgentId = agentId;
    emit(ChatLoaded(
      messages: List.from(_messages),
      agentId: _currentAgentId,
    ));
  }
}
```

```dart
class ChatState {
  final List<Message> messages;
  final String agentId;
  final bool isLoading;
  final String? error;
  
  const ChatState({
    this.messages = const [],
    this.agentId = 'default',
    this.isLoading = false,
    this.error,
  });
  
  ChatState copyWith({
    List<Message>? messages,
    String? agentId,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      agentId: agentId ?? this.agentId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// In your bloc - always work with the same state type
Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatState> emit,
) async {
  if (state.isLoading) {
    emit(state.copyWith(error: "Please wait"));
    return;
  }
  
  final newMessage = Message(
    content: event.content,
    timestamp: DateTime.now(),
    isUser: true,
  );
  
  final updatedMessages = [...state.messages, newMessage];
  emit(state.copyWith(
    messages: updatedMessages,
    isLoading: false,
    error: null,
  ));
}
```

```dart
class ChatEventStore {
  final List<ChatEvent> _events = [];
  
  void addEvent(ChatEvent event) {
    _events.add(event);
  }
  
  ChatState getCurrentState() {
    // Rebuild state from all events
    List<Message> messages = [];
    String agentId = 'default';
    bool isLoading = false;
    String? error;
    
    for (final event in _events) {
      if (event is SendMessage) {
        messages.add(Message(
          content: event.content,
          timestamp: DateTime.now(),
          isUser: true,
        ));
      } else if (event is SwitchAgent) {
        agentId = event.agentId;
      } else if (event is StartLoading) {
        isLoading = true;
      } else if (event is StopLoading) {
        isLoading = false;
      }
    }
    
    return ChatState(
      messages: messages,
      agentId: agentId,
      isLoading: isLoading,
      error: error,
    );
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatEventStore _eventStore;
  
  ChatBloc(this._eventStore) : super(ChatInitial()) {
    on<ChatEvent>((event, emit) {
      _eventStore.addEvent(event);
      emit(_eventStore.getCurrentState());
    });
  }
}
```

```dart
class ChatDataService {
  List<Message> _messages = [];
  String _agentId = 'default';
  
  List<Message> get messages => List.unmodifiable(_messages);
  String get agentId => _agentId;
  
  void addMessage(Message message) {
    _messages.add(message);
  }
  
  void setAgentId(String agentId) {
    _agentId = agentId;
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatDataService _dataService;
  
  ChatBloc(this._dataService) : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
  }
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Get data from service, not state
    final newMessage = Message(
      content: event.content,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    _dataService.addMessage(newMessage);
    
    emit(ChatLoaded(
      messages: _dataService.messages,
      agentId: _dataService.agentId,
    ));
  }
}
```

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get fresh data from service
      final currentData = await _chatService.getCurrentData();
      
      final newMessage = Message(
        content: event.content,
        timestamp: DateTime.now(),
        isUser: true,
      );
      
      await _chatService.addMessage(newMessage);
      
      // Emit new state with updated data
      emit(ChatState(
        messages: [...currentData.messages, newMessage],
        agentId: currentData.agentId,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
```

