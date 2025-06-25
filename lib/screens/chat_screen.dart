import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    try {
      // Set up message change callback
      _chatService.onMessagesChanged = () {
        if (mounted) {
          setState(() {});
          // Use a slight delay to ensure the UI updates before scrolling
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _scrollToBottom();
            }
          });
        }
      };

      await _chatService.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize chat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage([String? predefinedMessage]) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    if (predefinedMessage == null) {
      _messageController.clear();
    }
    setState(() => _isLoading = true);

    try {
      await _chatService.sendMessage(message);
      if (mounted) {
        setState(() {});
        // Give more time for the message to be rendered before scrolling
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Use a longer delay to ensure the ListView has been fully rebuilt
        // with the new message and its proper height calculated
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const ChatAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          children: [
            if (!_isInitialized && _isLoading)
              const ChatLoadingIndicator()
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ChatMessagesList(
                        scrollController: _scrollController,
                        messages: _chatService.messages,
                        isLoading: _isLoading,
                      ),
                    ),
                    // Show suggested messages only when there's just the welcome message
                    if (_isInitialized &&
                        _chatService.messages.length == 1 &&
                        !_isLoading)
                      SuggestedMessages(
                        onSuggestionTap: (suggestion) =>
                            _sendMessage(suggestion),
                      ),
                  ],
                ),
              ),
            if (_isInitialized)
              ChatInputArea(
                messageController: _messageController,
                onSendMessage: _sendMessage,
                isLoading: _isLoading,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
