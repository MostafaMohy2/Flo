import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();
  @override List<Object?> get props => [];
}

class SendAiMessage extends AiChatEvent {
  final String message;
  const SendAiMessage(this.message);
  @override List<Object?> get props => [message];
}

class ClearAiChat extends AiChatEvent { const ClearAiChat(); }
