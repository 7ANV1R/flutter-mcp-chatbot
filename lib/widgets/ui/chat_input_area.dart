import 'package:flutter/material.dart';
import '../chat/animated_send_button.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final bool isLoading;

  const ChatInputArea({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 10,
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Ask about weather in any city...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade50
                      : Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onSubmitted: (_) => onSendMessage(),
                enabled: !isLoading,
                maxLines: null,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSendButton(
              onPressed: isLoading ? null : onSendMessage,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
