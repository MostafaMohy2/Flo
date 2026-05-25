import 'package:equatable/equatable.dart';
import '../../../data/models/ai_message.dart';

abstract class AiChatState extends Equatable {
  const AiChatState();
  @override List<Object?> get props => [];
}

class AiChatInitial  extends AiChatState  { const AiChatInitial(); }
class AiChatLoaded   extends AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;
  const AiChatLoaded({required this.messages, this.isLoading = false});
  @override List<Object?> get props => [messages, isLoading];
}
class AiChatError    extends AiChatState {
  final String message;
  const AiChatError(this.message);
  @override List<Object?> get props => [message];
}
