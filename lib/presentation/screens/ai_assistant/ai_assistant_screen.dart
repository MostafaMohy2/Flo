import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../data/models/ai_message.dart';
import '../../blocs/ai_chat/ai_chat_bloc.dart';
import '../../blocs/ai_chat/ai_chat_event.dart';
import '../../blocs/ai_chat/ai_chat_state.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _inputCtrl   = TextEditingController();
  final _scrollCtrl  = ScrollController();

  void _send([String? text]) {
    final msg = (text ?? _inputCtrl.text).trim();
    if (msg.isEmpty) return;
    context.read<AiChatBloc>().add(SendAiMessage(msg));
    _inputCtrl.clear();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final suggestions = [
      'ai.suggestion_1'.tr(),
      'ai.suggestion_2'.tr(),
      'ai.suggestion_3'.tr(),
      'ai.suggestion_4'.tr(),
    ];
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: palette.primaryLight),
            child: Icon(Icons.auto_awesome, size: 16, color: palette.primary),
          ),
          const SizedBox(width: 8),
          Text('ai.title'.tr()),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<AiChatBloc>().add(const ClearAiChat()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<AiChatBloc, AiChatState>(
              builder: (context, state) {
                if (state is AiChatInitial) {
                  return _EmptyState(
                    suggestions: suggestions,
                    onSuggestionTap: _send,
                  );
                }
                if (state is AiChatLoaded) {
                  if (state.messages.isEmpty) {
                    return _EmptyState(suggestions: suggestions, onSuggestionTap: _send);
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) => _ChatBubble(message: state.messages[i]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _InputBar(controller: _inputCtrl, onSend: _send),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onSuggestionTap;
  const _EmptyState({required this.suggestions, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: palette.primaryLight),
            child: Icon(Icons.auto_awesome, size: 28, color: palette.primary),
          ),
          const SizedBox(height: 16),
          Text('ai.empty_title'.tr(),
              style: AppTextStyles.heading2(palette.textPrimary)),
          const SizedBox(height: 8),
          Text('ai.empty_subtitle'.tr(),
              style: AppTextStyles.bodyMedium(palette.textSecondary)),
          const SizedBox(height: 28),
          Text('ai.try_asking'.tr(),
              style: AppTextStyles.bodySmall(palette.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...suggestions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onSuggestionTap(s),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.cardBorder),
                ),
                child: Row(children: [
                  Expanded(child: Text(s, style: AppTextStyles.bodyMedium(palette.primary))),
                  Icon(Icons.arrow_forward_ios, size: 12, color: palette.primary),
                ]),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUser  = message.role == MessageRole.user;
    final isError = !isUser && !message.isLoading &&
        message.content.startsWith('Something went wrong') ||
        message.content.startsWith('API key') ||
        message.content.startsWith('Rate limit') ||
        message.content.startsWith('No internet') ||
        message.content.startsWith('An unexpected');

    final bubbleColor = isUser
      ? palette.primary
        : isError
        ? palette.expenseLight
        : palette.surface;
    final textColor = isUser
        ? Colors.white
        : isError
        ? palette.expenseText
        : palette.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, color: palette.primaryLight),
              child: Icon(Icons.auto_awesome, size: 14, color: palette.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: isUser ? null : Border.all(
                  color: isError
                      ? palette.expense.withValues(alpha: 0.3)
                      : palette.cardBorder,
                ),
              ),
              child: message.isLoading
                  ? const _TypingIndicator()
                  : Text(message.content,
                      style: AppTextStyles.bodyMedium(textColor)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
        final opacity = ((_ctrl.value * 3 - i) % 1.0).clamp(0.2, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 7, height: 7,
              decoration: BoxDecoration(shape: BoxShape.circle, color: palette.textSecondary),
            ),
          ),
        );
      })),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'ai.input_hint'.tr(),
                filled: true,
                fillColor: palette.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: palette.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: palette.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: palette.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: palette.primary),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}
