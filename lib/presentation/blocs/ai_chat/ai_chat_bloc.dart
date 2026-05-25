import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/ai_message.dart';
import '../../../data/repositories/ai_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiRepository _aiRepo;
  final TransactionRepository _txRepo;

  AiChatBloc({required AiRepository aiRepo, required TransactionRepository txRepo})
      : _aiRepo = aiRepo,
        _txRepo  = txRepo,
        super(const AiChatInitial()) {
    on<SendAiMessage>(_onSend);
    on<ClearAiChat>(_onClear);
  }

  Future<void> _onSend(SendAiMessage event, Emitter emit) async {
    final previous = state is AiChatLoaded
        ? (state as AiChatLoaded).messages
        : <AiMessage>[];

    final userMsg = AiMessage(
      id:        const Uuid().v4(),
      content:   event.message,
      role:      MessageRole.user,
      timestamp: DateTime.now(),
    );

    final loadingMsg = AiMessage(
      id:        const Uuid().v4(),
      content:   '',
      role:      MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    emit(AiChatLoaded(
      messages:  [...previous, userMsg, loadingMsg],
      isLoading: true,
    ));

    try {
      final transactions = await _txRepo.getLastNDays(7);
      final response     = await _aiRepo.ask(event.message, transactions);

      // Replace loading bubble with the actual response
      final updated = (state as AiChatLoaded).messages.map((m) {
        if (m.id == loadingMsg.id) {
          return m.copyWith(content: response, isLoading: false);
        }
        return m;
      }).toList();

      emit(AiChatLoaded(messages: updated, isLoading: false));
    } catch (e) {
      // Extract a human-readable message
      final errorMessage = _friendlyError(e);

      // Replace loading bubble with an error bubble — never nuke the chat history
      final withError = (state is AiChatLoaded
              ? (state as AiChatLoaded).messages
              : <AiMessage>[])
          .map((m) {
            if (m.id == loadingMsg.id) {
              return m.copyWith(content: errorMessage, isLoading: false);
            }
            return m;
          })
          .toList();

      emit(AiChatLoaded(messages: withError, isLoading: false));
    }
  }

  void _onClear(ClearAiChat event, Emitter emit) =>
      emit(const AiChatLoaded(messages: []));

  String _friendlyError(Object e) {
    if (e is AiFailure) {
      final msg = e.message;
      if (msg.contains('401') || msg.contains('403')) {
        return 'API key is missing or invalid. Add OPENROUTER_API_KEY to your .env file.';
      }
      if (msg.contains('429')) {
        return 'Rate limit reached. Please wait a moment and try again.';
      }
      if (msg.contains('Network') || msg.contains('timeout') || msg.contains('connection')) {
        return 'No internet connection. Check your network and try again.';
      }
      if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
        return 'The AI service is temporarily unavailable. Try again in a moment.';
      }
      return 'Something went wrong: $msg';
    }
    if (e is Failure) return e.message;
    return 'An unexpected error occurred. Please try again.';
  }
}
