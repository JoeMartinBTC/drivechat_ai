
import '../../../core/app_export.dart';

class PermissionBenefitsWidget extends StatelessWidget {
  const PermissionBenefitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      {
        'icon': 'hearing',
        'title': 'Freihändiges Lernen',
        'description':
            'Konzentrieren Sie sich aufs Fahren, während Sie sprechen',
      },
      {
        'icon': 'chat_bubble_outline',
        'title': 'Natürliche Gespräche',
        'description':
            'Fließende Unterhaltungen wie mit einem echten Fahrlehrer',
      },
      {
        'icon': 'volume_up',
        'title': 'Aussprache-Training',
        'description': 'Verbessern Sie Ihre Kommunikation im Straßenverkehr',
      },
      {
        'icon': 'psychology',
        'title': 'Personalisiertes Feedback',
        'description': 'KI passt sich Ihrem Lernstil und Tempo an',
      },
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vorteile der Sprachinteraktion',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ...benefits.map(
            (benefit) => _buildBenefitItem(
              context,
              benefit['icon'] as String,
              benefit['title'] as String,
              benefit['description'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String iconName,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
