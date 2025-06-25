import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';

class AnimatedSendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AnimatedSendButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isLoading
            ? LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
              )
            : LinearGradient(colors: context.primaryGradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isLoading)
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
