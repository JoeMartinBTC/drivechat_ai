
import '../../../core/app_export.dart';

class PrivacyAssuranceWidget extends StatelessWidget {
  const PrivacyAssuranceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Datenschutz & Sicherheit',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildPrivacyPoint(
            context,
            'shield_outlined',
            'DSGVO-konform',
            'Alle Daten werden nach europäischen Datenschutzstandards verarbeitet',
          ),
          SizedBox(height: 2.h),
          _buildPrivacyPoint(
            context,
            'phone_android',
            'Lokale Verarbeitung',
            'Sprachdaten werden hauptsächlich auf Ihrem Gerät verarbeitet',
          ),
          SizedBox(height: 2.h),
          _buildPrivacyPoint(
            context,
            'delete_outline',
            'Keine Speicherung',
            'Audiodaten werden nicht dauerhaft gespeichert oder weitergegeben',
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Sie können die Berechtigung jederzeit in den Geräteeinstellungen widerrufen.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(
    BuildContext context,
    String iconName,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.tertiary,
          size: 4.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
