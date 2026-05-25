import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }

class AiMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  const AiMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  AiMessage copyWith({String? content, bool? isLoading}) => AiMessage(
    id:        id,
    content:   content    ?? this.content,
    role:      role,
    timestamp: timestamp,
    isLoading: isLoading  ?? this.isLoading,
  );

  @override
  List<Object?> get props => [id, content, role, timestamp, isLoading];
}
