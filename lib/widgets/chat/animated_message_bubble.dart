import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/chat_message.dart';
import '../ui/weather_widget.dart';
import '../ui/shimmer_widget.dart';

class AnimatedMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;

  const AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.index,
  });

  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: widget.message.type == MessageType.user
              ? const Offset(0.3, 0)
              : const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.type == MessageType.user;
    final isError = widget.message.isError;
    final isStreaming = widget.message.state != MessageState.complete;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isError
                          ? [Colors.red.shade400, Colors.red.shade600]
                          : isStreaming
                              ? [Colors.blue.shade400, Colors.blue.shade600]
                              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isError 
                            ? Colors.red 
                            : isStreaming 
                                ? Colors.blue 
                                : const Color(0xFF6366F1))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : isStreaming
                            ? Icons.hourglass_empty_rounded
                            : Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Regular text message first
                    if (!isUser && widget.message.content.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: EdgeInsets.only(
                          bottom: widget.message.weatherData != null ? 12 : 0,
                        ),
                        decoration: BoxDecoration(
                          gradient: isUser
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                )
                              : null,
                          color: isUser
                              ? null
                              : isError
                              ? Colors.red.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: isError
                                      ? Colors.red.shade200
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isStreaming
                            ? _buildStreamingContent()
                            : InkWell(
                                onLongPress: () {
                                  // Copy text to clipboard on long press
                                  Clipboard.setData(
                                    ClipboardData(text: widget.message.content),
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.copy_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Message copied to clipboard'),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  widget.message.content,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : isError
                                        ? Colors.red.shade800
                                        : const Color(0xFF1F2937),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                      ),

                    // Weather widget after text message
                    if (!isUser && (widget.message.weatherData != null || widget.message.isWeatherQuery))
                      widget.message.weatherData != null
                          ? WeatherWidget(weatherData: widget.message.weatherData!)
                          : widget.message.isWeatherQuery && isStreaming
                              ? _buildWeatherShimmer()
                              : const SizedBox.shrink(),

                    // User message (for user messages only)
                    if (isUser && widget.message.content.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onLongPress: () {
                            // Copy text to clipboard on long press
                            Clipboard.setData(
                              ClipboardData(text: widget.message.content),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Message copied to clipboard'),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            widget.message.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingContent() {
    switch (widget.message.state) {
      case MessageState.analyzing:
        return _buildShimmerText(
          widget.message.content,
          icon: Icons.search_rounded,
        );
      case MessageState.fetchingWeather:
        return _buildShimmerText(
          widget.message.content,
          icon: Icons.cloud_download_rounded,
        );
      case MessageState.streaming:
        return _buildShimmerText(
          widget.message.content,
          icon: Icons.edit_rounded,
        );
      case MessageState.error:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: Colors.red.shade800,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0.2,
          ),
        );
      case MessageState.complete:
        return Text(
          widget.message.content,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0.2,
          ),
        );
    }
  }

  Widget _buildShimmerText(String text, {required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ShimmerWidget(
            isLoading: true,
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          ShimmerWidget(
            isLoading: true,
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Temperature shimmer
          ShimmerWidget(
            isLoading: true,
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Details shimmer
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                ShimmerWidget(
                  isLoading: true,
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
