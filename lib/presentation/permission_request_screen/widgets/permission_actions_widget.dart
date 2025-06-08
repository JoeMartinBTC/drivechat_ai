import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionActionsWidget extends StatelessWidget {
  final VoidCallback onAllowMicrophone;
  final VoidCallback onTextOnlyMode;
  final bool isLoading;

  const PermissionActionsWidget({
    super.key,
    required this.onAllowMicrophone,
    required this.onTextOnlyMode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary action - Allow microphone
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : onAllowMicrophone,
            style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.6);
                }
                return AppTheme.lightTheme.colorScheme.primary;
              }),
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Berechtigung wird angefragt...',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'mic',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Mikrofon erlauben',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 3.h),

        // Secondary action - Text only mode
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: isLoading ? null : onTextOnlyMode,
            style: AppTheme.lightTheme.outlinedButtonTheme.style?.copyWith(
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.5),
                    width: 1.5,
                  );
                }
                return BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1.5,
                );
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5);
                }
                return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
              }),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'keyboard',
                  color: isLoading
                      ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5)
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Nur Text verwenden',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: isLoading
                        ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Helper text
        Text(
          'Sie können später jederzeit zwischen Sprach- und Textmodus wechseln',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
