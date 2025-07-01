import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../settings_screen/widgets/settings_item_widget.dart';
import '../../settings_screen/widgets/settings_section_widget.dart';

// lib/presentation/audio_settings_screen/widgets/playback_section_widget.dart

class PlaybackSectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const PlaybackSectionWidget({
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
                subtitle: Text('Eingebauter Gerätlautsprecher'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (settingsData['audioDevice'] == 'speaker')
                      CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      ),
                    if (settingsData['audioDevice'] == 'speaker')
                      SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'volume_up',
                      color: AppTheme.successLight,
                      size: 16,
                    ),
                  ],
                ),
                onTap: () {
                  onSettingChanged('audioDevice', 'speaker');
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
                subtitle: Text('Kabelgebundene Kopfhörer'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (settingsData['audioDevice'] == 'headphones')
                      CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      ),
                    if (settingsData['audioDevice'] == 'headphones')
                      SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'cable',
                      color: AppTheme.textSecondaryLight,
                      size: 16,
                    ),
                  ],
                ),
                onTap: () {
                  onSettingChanged('audioDevice', 'headphones');
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
                subtitle: Text('Drahtlose Audio-Geräte'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (settingsData['audioDevice'] == 'bluetooth')
                      CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      ),
                    if (settingsData['audioDevice'] == 'bluetooth')
                      SizedBox(width: 2.w),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  onSettingChanged('audioDevice', 'bluetooth');
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 1.h),
              Divider(),
              SwitchListTile(
                title: Text('Automatisches Umschalten'),
                subtitle: Text('Automatisch auf verfügbare Geräte wechseln'),
                value: settingsData['autoDeviceSwitching'] as bool,
                onChanged: (value) {
                  onSettingChanged('autoDeviceSwitching', value);
                },
                activeColor: AppTheme.primaryLight,
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

  String _getPlaybackSpeedDisplayName(double speed) {
    if (speed == 0.5) return '0.5x (Sehr langsam)';
    if (speed == 0.75) return '0.75x (Langsam)';
    if (speed == 1.0) return '1.0x (Normal)';
    if (speed == 1.25) return '1.25x (Schnell)';
    if (speed == 1.5) return '1.5x (Sehr schnell)';
    if (speed == 2.0) return '2.0x (Doppelt)';
    return '${speed}x';
  }

  void _showPlaybackSpeedSelection(BuildContext context) {
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
                'Wiedergabegeschwindigkeit für KI-Antworten',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...[
                {
                  'speed': 0.5,
                  'label': '0.5x (Sehr langsam)',
                  'description': 'Für komplexe Inhalte',
                },
                {
                  'speed': 0.75,
                  'label': '0.75x (Langsam)',
                  'description': 'Zum besseren Verstehen',
                },
                {
                  'speed': 1.0,
                  'label': '1.0x (Normal)',
                  'description': 'Standard-Geschwindigkeit',
                },
                {
                  'speed': 1.25,
                  'label': '1.25x (Schnell)',
                  'description': 'Leicht beschleunigt',
                },
                {
                  'speed': 1.5,
                  'label': '1.5x (Sehr schnell)',
                  'description': 'Für Wiederholungen',
                },
                {
                  'speed': 2.0,
                  'label': '2.0x (Doppelt)',
                  'description': 'Maximale Geschwindigkeit',
                },
              ].map((item) {
                double speed = item['speed'] as double;
                return ListTile(
                  title: Text(item['label'] as String),
                  subtitle: Text(item['description'] as String),
                  trailing:
                      settingsData['playbackSpeed'] == speed
                          ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.successLight,
                            size: 20,
                          )
                          : null,
                  onTap: () {
                    onSettingChanged('playbackSpeed', speed);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Wiedergabe-Einstellungen',
      children: [
        // Volume Control (separate from system volume)
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
                    'App-Lautstärke',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Unabhängig von System-Lautstärke',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
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
                      value: (settingsData['volumeLevel'] as double).clamp(
                        0.0,
                        1.0,
                      ),
                      onChanged: (value) {
                        onSettingChanged('volumeLevel', value);
                      },
                      activeColor: AppTheme.primaryLight,
                      inactiveColor: AppTheme.primaryLight.withValues(
                        alpha: 0.3,
                      ),
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

        // Audio Device Selection
        SettingsItemWidget(
          title: 'Audio-Gerät',
          subtitle: _getAudioDeviceDisplayName(
            settingsData['audioDevice'] as String,
          ),
          leadingIcon: CustomIconWidget(
            iconName:
                settingsData['audioDevice'] == 'speaker'
                    ? 'speaker'
                    : settingsData['audioDevice'] == 'headphones'
                    ? 'headphones'
                    : 'bluetooth',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showAudioDeviceSelection(context),
        ),

        // Playback Speed for AI Responses
        SettingsItemWidget(
          title: 'Wiedergabegeschwindigkeit',
          subtitle: _getPlaybackSpeedDisplayName(
            settingsData['playbackSpeed'] as double,
          ),
          leadingIcon: CustomIconWidget(
            iconName: 'speed',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showPlaybackSpeedSelection(context),
        ),

        // Spatial Audio Toggle
        SettingsItemWidget(
          title: 'Räumliches Audio',
          subtitle: 'Immersive Klangwiedergabe (unterstützte Geräte)',
          leadingIcon: CustomIconWidget(
            iconName: 'surround_sound',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['spatialAudioEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('spatialAudioEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Bass Boost Toggle
        SettingsItemWidget(
          title: 'Bass-Verstärkung',
          subtitle: 'Verbesserte Tieftonwiedergabe',
          leadingIcon: CustomIconWidget(
            iconName: 'equalizer',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['bassBoostEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('bassBoostEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Auto Device Switching (shows when enabled)
        if (settingsData['autoDeviceSwitching'] as bool)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'swap_horiz',
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automatisches Umschalten aktiv',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryLight,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Die App wechselt automatisch zu neu verbundenen Audio-Geräten',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.primaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
