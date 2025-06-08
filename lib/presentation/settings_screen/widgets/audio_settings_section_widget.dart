import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_item_widget.dart';
import './settings_section_widget.dart';

class AudioSettingsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const AudioSettingsSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  void _showAudioDeviceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audio-Gerät auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'speaker',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Lautsprecher'),
                trailing: settingsData['preferredAudioDevice'] == 'speaker'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('preferredAudioDevice', 'speaker');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'headphones',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Kopfhörer'),
                trailing: settingsData['preferredAudioDevice'] == 'headphones'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('preferredAudioDevice', 'headphones');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'bluetooth',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Bluetooth-Gerät'),
                trailing: settingsData['preferredAudioDevice'] == 'bluetooth'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('preferredAudioDevice', 'bluetooth');
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  String _getAudioDeviceDisplayName(String device) {
    switch (device) {
      case 'speaker':
        return 'Lautsprecher';
      case 'headphones':
        return 'Kopfhörer';
      case 'bluetooth':
        return 'Bluetooth-Gerät';
      default:
        return 'Unbekannt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Audio-Einstellungen',
      children: [
        // Microphone Sensitivity
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'mic',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Mikrofon-Empfindlichkeit',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Text(
                    'Niedrig',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  Expanded(
                    child: Slider(
                      value: (settingsData['microphoneSensitivity'] as double)
                          .clamp(0.0, 1.0),
                      onChanged: (value) {
                        onSettingChanged('microphoneSensitivity', value);
                      },
                      activeColor: AppTheme.primaryLight,
                      inactiveColor:
                          AppTheme.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  Text(
                    'Hoch',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
              Text(
                '${((settingsData['microphoneSensitivity'] as double) * 100).round()}%',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Noise Suppression
        SettingsItemWidget(
          title: 'Rauschunterdrückung',
          subtitle: 'Hintergrundgeräusche reduzieren',
          leadingIcon: CustomIconWidget(
            iconName: 'noise_control_off',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['noiseSuppressionEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('noiseSuppressionEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Audio Device Selection
        SettingsItemWidget(
          title: 'Bevorzugtes Audio-Gerät',
          subtitle: _getAudioDeviceDisplayName(
              settingsData['preferredAudioDevice'] as String),
          leadingIcon: CustomIconWidget(
            iconName: settingsData['preferredAudioDevice'] == 'speaker'
                ? 'speaker'
                : settingsData['preferredAudioDevice'] == 'headphones'
                    ? 'headphones'
                    : 'bluetooth',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showAudioDeviceSelection(context),
        ),

        // Volume Control
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'volume_up',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Lautstärke',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'volume_down',
                    color: AppTheme.textSecondaryLight,
                    size: 16,
                  ),
                  Expanded(
                    child: Slider(
                      value: (settingsData['volumeLevel'] as double)
                          .clamp(0.0, 1.0),
                      onChanged: (value) {
                        onSettingChanged('volumeLevel', value);
                      },
                      activeColor: AppTheme.primaryLight,
                      inactiveColor:
                          AppTheme.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'volume_up',
                    color: AppTheme.textSecondaryLight,
                    size: 16,
                  ),
                ],
              ),
              Text(
                '${((settingsData['volumeLevel'] as double) * 100).round()}%',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Audio Test
        SettingsItemWidget(
          title: 'Audio-Test durchführen',
          subtitle: 'Mikrofon und Lautsprecher testen',
          leadingIcon: CustomIconWidget(
            iconName: 'play_circle_outline',
            color: AppTheme.successLight,
            size: 24,
          ),
          onTap: () {
            Navigator.pushNamed(context, '/audio-settings-screen');
          },
        ),
      ],
    );
  }
}
