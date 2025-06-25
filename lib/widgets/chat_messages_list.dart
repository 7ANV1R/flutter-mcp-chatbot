import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'animated_message_bubble.dart';
import 'typing_indicator.dart';

class ChatMessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: messages.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == messages.length && isLoading) {
            return const TypingIndicator();
          }
          final message = messages[index];
          return AnimatedMessageBubble(message: message, index: index);
        },
      ),
    );
  }
}
