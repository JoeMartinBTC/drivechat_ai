import '../../../core/app_export.dart';

class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(Map<String, dynamic>) onLongPress;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.onLongPress,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message['isUser'] as bool;
    final isTyping = message['isTyping'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'smart_toy',
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => onLongPress(message),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomLeft: isUser
                        ? const Radius.circular(18)
                        : const Radius.circular(4),
                    bottomRight: isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(18),
                  ),
                  border: !isUser
                      ? Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTyping)
                      _buildTypingIndicator(context)
                    else
                      Text(
                        message['message'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isUser
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                      ),
                    if (!isTyping) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTimestamp(message['timestamp']),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: isUser
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                          ),
                          if (message['hasAudio']) ...[
                            const SizedBox(width: 4),
                            CustomIconWidget(
                              iconName: 'volume_up',
                              color: isUser
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Theme.of(context).colorScheme.primary,
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: CustomIconWidget(
                iconName: 'person',
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'KI tippt',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 600 + (index * 200)),
                curve: Curves.easeInOut,
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
