import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/chat_message.dart';
import '../../providers/theme_provider.dart';
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
                          : context.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isError
                                    ? Colors.red
                                    : isStreaming
                                    ? Colors.blue
                                    : context.primaryColor)
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
                              ? LinearGradient(colors: context.primaryGradient)
                              : null,
                          color: isUser
                              ? null
                              : isError
                              ? (Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.red.shade50
                                    : Colors.red.shade900.withValues(
                                        alpha: 0.3,
                                      ))
                              : context.chatBubbleAssistantColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: isError
                                      ? Colors.red.shade200
                                      : Theme.of(context).dividerColor,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                        ? (Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.red.shade800
                                              : Colors.red.shade300)
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                      ),

                    // Weather widget after text message
                    if (!isUser &&
                        (widget.message.weatherData != null ||
                            widget.message.isWeatherQuery))
                      widget.message.weatherData != null
                          ? WeatherWidget(
                              weatherData: widget.message.weatherData!,
                            )
                          : widget.message.isWeatherQuery && isStreaming
                          ? _buildWeatherShimmer()
                          : const SizedBox.shrink(),

                    // User message (for user messages only)
                    if (isUser && widget.message.content.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: context.primaryGradient,
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
                    gradient: LinearGradient(
                      colors: [context.primaryLightColor, context.primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: context.primaryColor.withValues(alpha: 0.3),
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
        return _buildModernStreamingText(
          widget.message.content,
          icon: Icons.psychology_rounded,
          color: context.primaryColor,
        );
      case MessageState.fetchingWeather:
        return _buildModernStreamingText(
          widget.message.content,
          icon: Icons.cloud_sync_rounded,
          color: Colors.blue.shade500,
        );
      case MessageState.streaming:
        return _buildModernStreamingText(
          widget.message.content,
          icon: Icons.auto_awesome_rounded,
          color: context.primaryColor,
        );
      case MessageState.error:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.red.shade800
                : Colors.red.shade300,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0.2,
          ),
        );
      case MessageState.complete:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0.2,
          ),
        );
    }
  }

  Widget _buildModernStreamingText(
    String text, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                ShimmerWidget(
                  isLoading: true,
                  baseColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                  highlightColor:
                      Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.grey.shade600,
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Animated dots
          _buildAnimatedDots(color),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedDot(color, 0),
        const SizedBox(width: 3),
        _buildAnimatedDot(color, 200),
        const SizedBox(width: 3),
        _buildAnimatedDot(color, 400),
      ],
    );
  }

  Widget _buildAnimatedDot(Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: value),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation after a brief pause
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) {
            setState(() {});
          }
        });
      },
    );
  }

  Widget _buildWeatherShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.chatBubbleAssistantColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern header with weather icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      isLoading: true,
                      baseColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                      highlightColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade600,
                      child: Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ShimmerWidget(
                      isLoading: true,
                      baseColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                      highlightColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade600,
                      child: Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Temperature shimmer
          ShimmerWidget(
            isLoading: true,
            baseColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade300
                : Colors.grey.shade700,
            highlightColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade100
                : Colors.grey.shade600,
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Details shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  ShimmerWidget(
                    isLoading: true,
                    baseColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    highlightColor:
                        Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade100
                        : Colors.grey.shade600,
                    child: Container(
                      height: 12,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShimmerWidget(
                    isLoading: true,
                    baseColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    highlightColor:
                        Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade100
                        : Colors.grey.shade600,
                    child: Container(
                      height: 14,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
