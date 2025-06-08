import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

// lib/presentation/api_configuration_screen/widgets/security_settings_widget.dart

class SecuritySettingsWidget extends StatelessWidget {
  final bool isBiometricEnabled;
  final ValueChanged<bool> onBiometricToggle;

  const SecuritySettingsWidget({
    super.key,
    required this.isBiometricEnabled,
    required this.onBiometricToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Security Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            'Additional security measures for your API key protection',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),

          SizedBox(height: 3.h),

          // Biometric Protection
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'fingerprint',
                  color: isBiometricEnabled
                      ? AppTheme.successLight
                      : AppTheme.textSecondaryLight,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biometric Protection',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isBiometricEnabled
                            ? 'API key access requires biometric authentication'
                            : 'Enable Face ID/Touch ID/Fingerprint for API access',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isBiometricEnabled,
                  onChanged: onBiometricToggle,
                  activeColor: AppTheme.successLight,
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Encryption Status
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.successLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.successLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'shield',
                      color: AppTheme.successLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Data Protection Status',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                _buildSecurityFeature('AES-256 encryption for API key storage'),
                _buildSecurityFeature(
                    'Secure enclave storage (iOS) / Encrypted shared preferences (Android)'),
                _buildSecurityFeature(
                    'No API key transmission to third parties'),
                _buildSecurityFeature('Local device storage only'),
                _buildSecurityFeature(
                    'Automatic key expiration options available'),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Security Best Practices
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.warningLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Security Best Practices',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                _buildSecurityTip('Never share your API key with others'),
                _buildSecurityTip(
                    'Regenerate API key if you suspect it\'s compromised'),
                _buildSecurityTip(
                    'Monitor your ElevenLabs usage dashboard regularly'),
                _buildSecurityTip(
                    'Enable biometric protection for enhanced security'),
                _buildSecurityTip('Keep your device secure with screen lock'),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Data Handling Information
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Data Handling',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your API key is stored locally on your device using industry-standard encryption. DriveChat AI does not transmit, store, or have access to your ElevenLabs API key on our servers. All voice processing is handled directly between your device and ElevenLabs.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
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

  Widget _buildSecurityFeature(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check',
            color: AppTheme.successLight,
            size: 14,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              feature,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.warningLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
