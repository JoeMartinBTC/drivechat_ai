
import '../../../core/app_export.dart';

class SettingsItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showTrailing;
  final bool enabled;

  const SettingsItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.showTrailing = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: enabled
              ? Colors.transparent
              : AppTheme.textSecondaryLight.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: 3.w)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: enabled
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle!,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showTrailing && onTap != null)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textSecondaryLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
