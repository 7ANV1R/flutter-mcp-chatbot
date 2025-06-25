import 'package:flutter/material.dart';
import '../../screens/settings_screen.dart';
import '../../providers/theme_provider.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onResetChat;

  const ChatAppBar({super.key, this.onResetChat});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_queue_rounded,
            size: 28,
            color: context.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Weather Chat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        // Reset button
        IconButton(
          onPressed: () => _showResetDialog(context),
          icon: Icon(
            Icons.refresh_rounded,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          tooltip: 'Reset Chat',
        ),
        // Settings button
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: Icon(
            Icons.settings,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          tooltip: 'Settings',
        ),
      ],
      centerTitle: true,
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: context.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Reset Chat'),
            ],
          ),
          content: const Text(
            'This will clear all messages and reset the chat to its initial state. Are you sure?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onResetChat?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
