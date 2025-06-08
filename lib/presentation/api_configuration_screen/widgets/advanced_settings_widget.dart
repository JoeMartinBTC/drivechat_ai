import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

// lib/presentation/api_configuration_screen/widgets/advanced_settings_widget.dart

class AdvancedSettingsWidget extends StatelessWidget {
  final String selectedVoiceModel;
  final List<String> voiceModels;
  final double responseSpeed;
  final String audioQuality;
  final List<String> audioQualities;
  final ValueChanged<String> onVoiceModelChanged;
  final ValueChanged<double> onResponseSpeedChanged;
  final ValueChanged<String> onAudioQualityChanged;

  const AdvancedSettingsWidget({
    super.key,
    required this.selectedVoiceModel,
    required this.voiceModels,
    required this.responseSpeed,
    required this.audioQuality,
    required this.audioQualities,
    required this.onVoiceModelChanged,
    required this.onResponseSpeedChanged,
    required this.onAudioQualityChanged,
  });

  String _getVoiceModelDisplayName(String model) {
    switch (model) {
      case 'eleven_multilingual_v2':
        return 'Multilingual V2 (Recommended)';
      case 'eleven_monolingual_v1':
        return 'Monolingual V1 (English Only)';
      case 'eleven_turbo_v2':
        return 'Turbo V2 (Fast Response)';
      default:
        return model;
    }
  }

  String _getAudioQualityDisplayName(String quality) {
    switch (quality) {
      case 'low':
        return 'Low (Fast, Lower Quality)';
      case 'medium':
        return 'Medium (Balanced)';
      case 'high':
        return 'High (Recommended)';
      case 'ultra':
        return 'Ultra (Best Quality, Slower)';
      default:
        return quality;
    }
  }

  String _getResponseSpeedDescription(double speed) {
    if (speed < 0.3) {
      return 'Very Fast (May affect quality)';
    } else if (speed < 0.5) {
      return 'Fast';
    } else if (speed < 0.7) {
      return 'Normal (Recommended)';
    } else if (speed < 0.9) {
      return 'Slow (Better quality)';
    } else {
      return 'Very Slow (Best quality)';
    }
  }

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
                iconName: 'tune',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Advanced Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            'Fine-tune your ElevenLabs integration for optimal performance',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),

          SizedBox(height: 3.h),

          // Voice Model Selection
          Text(
            'Voice Model',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedVoiceModel,
              isExpanded: true,
              underline: const SizedBox(),
              items: voiceModels.map((model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getVoiceModelDisplayName(model),
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      if (model == 'eleven_multilingual_v2')
                        Text(
                          'Best for German driving education',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successLight,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onVoiceModelChanged(value);
                }
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Response Speed
          Text(
            'Response Speed',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            _getResponseSpeedDescription(responseSpeed),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),

          SizedBox(height: 1.h),

          Row(
            children: [
              Text(
                'Fast',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: responseSpeed,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '${(responseSpeed * 100).round()}%',
                  onChanged: onResponseSpeedChanged,
                  activeColor: AppTheme.primaryLight,
                  inactiveColor: AppTheme.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              Text(
                'Slow',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Audio Quality
          Text(
            'Audio Quality',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: audioQuality,
              isExpanded: true,
              underline: const SizedBox(),
              items: audioQualities.map((quality) {
                return DropdownMenuItem<String>(
                  value: quality,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getAudioQualityDisplayName(quality),
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      if (quality == 'high')
                        Text(
                          'Optimal balance of quality and speed',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successLight,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onAudioQualityChanged(value);
                }
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Performance Tips
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
                      iconName: 'lightbulb',
                      color: AppTheme.primaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Performance Tips',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                _buildPerformanceTip(
                    'Use Multilingual V2 for best German pronunciation'),
                _buildPerformanceTip(
                    'Normal speed (50%) provides optimal quality/speed balance'),
                _buildPerformanceTip(
                    'High quality recommended for driving education'),
                _buildPerformanceTip(
                    'Consider your network speed when choosing quality'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTip(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryLight,
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
