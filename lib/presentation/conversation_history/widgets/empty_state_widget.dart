import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onStartConversation;

  const EmptyStateWidget({
    super.key,
    required this.isSearching,
    required this.onStartConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: isSearching ? 'search_off' : 'chat_bubble_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching
                  ? 'Keine Ergebnisse gefunden'
                  : 'Noch keine Unterhaltungen',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Versuchen Sie es mit anderen Suchbegriffen oder überprüfen Sie Ihre Eingabe.'
                  : 'Beginnen Sie Ihre erste Unterhaltung mit dem AI-Fahrlehrer und lernen Sie interaktiv.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onStartConversation,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: const Text('Erste Unterhaltung beginnen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
            if (isSearching) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  // Clear search functionality would be handled by parent
                },
                icon: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Suche löschen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
