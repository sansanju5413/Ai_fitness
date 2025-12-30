import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../session/repositories/session_repository.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final Ref _ref;

  ChatNotifier(this._chatService, this._ref) : super(ChatState()) {
    // Initial greeting
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          text: "Hi there! I'm Aura, your AI fitness coach. How can I help you today?",
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final profile = _ref.read(profileStreamProvider).valueOrNull;
      final sessions = _ref.read(workoutSessionsStreamProvider).valueOrNull;

      final response = await _chatService.generatePersonalizedResponse(
        userQuery: text,
        history: state.messages,
        profile: profile,
        recentSessions: sessions?.take(5).toList(),
      );

      if (response != null) {
        final aiMessage = ChatMessage(
          text: response,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, aiMessage],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "I couldn't generate a response. Please try again.",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Something went wrong: $e",
      );
    }
  }

  void clearChat() {
    state = ChatState();
    _addInitialGreeting();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return ChatNotifier(chatService, ref);
});
