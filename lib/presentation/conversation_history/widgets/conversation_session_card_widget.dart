import '../../../core/app_export.dart';

class ConversationSessionCardWidget extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onResume;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const ConversationSessionCardWidget({
    super.key,
    required this.session,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onResume,
    required this.onShare,
    required this.onDelete,
    required this.onArchive,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'in_progress':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Abgeschlossen';
      case 'in_progress':
        return 'In Bearbeitung';
      default:
        return 'Unbekannt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = session["date"] as DateTime;
    final topics = session["topics"] as List;
    final progress = session["progress"] as int;
    final completionStatus = session["completionStatus"] as String;
    final audioAvailable = session["audioAvailable"] as bool;

    return Dismissible(
      key: Key(session["id"]),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'play_arrow',
              color: AppTheme.lightTheme.colorScheme.onTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Fortsetzen',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onTertiary,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'archive',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Archivieren',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onResume();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          onArchive();
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primaryContainer
                : AppTheme.lightTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  )
                : Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isSelectionMode)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: CustomIconWidget(
                          iconName: isSelected
                              ? 'check_circle'
                              : 'radio_button_unchecked',
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                          size: 24,
                        ),
                      ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            _formatDate(date),
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(date),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          completionStatus,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(completionStatus),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(completionStatus),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session["firstExchange"],
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: topics
                            .map<Widget>(
                              (topic) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  topic,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSecondaryContainer,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        if (audioAvailable)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: CustomIconWidget(
                              iconName: 'volume_up',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 16,
                            ),
                          ),
                        Text(
                          session["duration"],
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (completionStatus == 'in_progress') ...[
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fortschritt',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '$progress%',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!isSelectionMode) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: onResume,
                          icon: CustomIconWidget(
                            iconName: 'play_arrow',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                          label: const Text('Fortsetzen'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onShare,
                        icon: CustomIconWidget(
                          iconName: 'share',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        tooltip: 'Teilen',
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: CustomIconWidget(
                          iconName: 'delete_outline',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 20,
                        ),
                        tooltip: 'Löschen',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
