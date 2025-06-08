import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../settings_screen/widgets/settings_item_widget.dart';
import '../../settings_screen/widgets/settings_section_widget.dart';

// lib/presentation/audio_settings_screen/widgets/quality_section_widget.dart

class QualitySectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const QualitySectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  void _showSampleRateSelection(BuildContext context) {
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
                'Abtastrate auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'battery_saver',
                  color: AppTheme.successLight,
                  size: 24,
                ),
                title: Text('16 kHz (Sparsam)'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Geringerer Speicherbedarf • Längere Akkulaufzeit'),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(Icons.storage,
                            size: 12, color: AppTheme.successLight),
                        SizedBox(width: 1.w),
                        Text('~0.5 MB/min',
                            style: TextStyle(
                                fontSize: 10, color: AppTheme.successLight)),
                      ],
                    ),
                  ],
                ),
                trailing: settingsData['sampleRate'] == '16kHz'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('sampleRate', '16kHz');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'high_quality',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('44.1 kHz (Hohe Qualität)'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Beste Audioqualität • Mehr Speicherbedarf'),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(Icons.storage,
                            size: 12, color: AppTheme.warningLight),
                        SizedBox(width: 1.w),
                        Text('~1.4 MB/min',
                            style: TextStyle(
                                fontSize: 10, color: AppTheme.warningLight)),
                      ],
                    ),
                  ],
                ),
                trailing: settingsData['sampleRate'] == '44.1kHz'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('sampleRate', '44.1kHz');
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

  void _showAudioFormatSelection(BuildContext context) {
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
                'Audio-Format auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'compress',
                  color: AppTheme.successLight,
                  size: 24,
                ),
                title: Text('Komprimiert (MP3)'),
                subtitle:
                    Text('Optimiert für ElevenLabs • Geringere Dateigröße'),
                trailing: settingsData['audioFormat'] == 'compressed'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('audioFormat', 'compressed');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'music_note',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Unkomprimiert (WAV)'),
                subtitle: Text('Beste Qualität • Größere Dateien'),
                trailing: settingsData['audioFormat'] == 'uncompressed'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSettingChanged('audioFormat', 'uncompressed');
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

  void _showBitrateQualitySelection(BuildContext context) {
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
                'Bitrate-Qualität auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...[
                {
                  'quality': 'low',
                  'label': 'Niedrig (64 kbps)',
                  'description': 'Minimaler Datenverbrauch',
                  'icon': 'signal_cellular_1_bar',
                  'color': AppTheme.successLight,
                },
                {
                  'quality': 'medium',
                  'label': 'Mittel (128 kbps)',
                  'description': 'Ausgewogene Qualität',
                  'icon': 'signal_cellular_2_bar',
                  'color': AppTheme.primaryLight,
                },
                {
                  'quality': 'high',
                  'label': 'Hoch (320 kbps)',
                  'description': 'Beste Qualität, höherer Verbrauch',
                  'icon': 'signal_cellular_4_bar',
                  'color': AppTheme.warningLight,
                },
              ].map((item) {
                String quality = item['quality'] as String;
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: item['icon'] as String,
                    color: item['color'] as Color,
                    size: 24,
                  ),
                  title: Text(item['label'] as String),
                  subtitle: Text(item['description'] as String),
                  trailing: settingsData['bitrateQuality'] == quality
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.successLight,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    onSettingChanged('bitrateQuality', quality);
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

  String _getSampleRateDisplayName(String sampleRate) {
    return sampleRate == '16kHz'
        ? '16 kHz (Sparsam)'
        : '44.1 kHz (Hohe Qualität)';
  }

  String _getAudioFormatDisplayName(String format) {
    return format == 'compressed' ? 'Komprimiert (MP3)' : 'Unkomprimiert (WAV)';
  }

  String _getBitrateDisplayName(String quality) {
    switch (quality) {
      case 'low':
        return 'Niedrig (64 kbps)';
      case 'medium':
        return 'Mittel (128 kbps)';
      case 'high':
        return 'Hoch (320 kbps)';
      default:
        return 'Unbekannt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Qualitäts-Einstellungen',
      children: [
        // Sample Rate Selection with Storage Impact
        SettingsItemWidget(
          title: 'Abtastrate',
          subtitle:
              _getSampleRateDisplayName(settingsData['sampleRate'] as String),
          leadingIcon: CustomIconWidget(
            iconName: 'graphic_eq',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showSampleRateSelection(context),
        ),

        // Audio Format for ElevenLabs Optimization
        SettingsItemWidget(
          title: 'Audio-Format',
          subtitle:
              _getAudioFormatDisplayName(settingsData['audioFormat'] as String),
          leadingIcon: CustomIconWidget(
            iconName: 'audio_file',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showAudioFormatSelection(context),
        ),

        // Compression Settings (when compressed format is selected)
        if (settingsData['audioFormat'] == 'compressed')
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 8.w), // Indent for sub-setting
                    CustomIconWidget(
                      iconName: 'tune',
                      color: AppTheme.textSecondaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Komprimierungsgrad',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Row(
                    children: [
                      Text(
                        'Qualität',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      Expanded(
                        child: Slider(
                          value: (settingsData['compressionLevel'] as double)
                              .clamp(0.0, 1.0),
                          onChanged: (value) {
                            onSettingChanged('compressionLevel', value);
                          },
                          activeColor: AppTheme.primaryLight,
                          inactiveColor:
                              AppTheme.primaryLight.withValues(alpha: 0.3),
                        ),
                      ),
                      Text(
                        'Kompakt',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Qualität vs. Dateigröße: ${((settingsData['compressionLevel'] as double) * 100).round()}%',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'data_usage',
                            color: AppTheme.textSecondaryLight,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Bandbreite: ${(settingsData['compressionLevel'] as double) < 0.5 ? "Niedrig" : "Mittel"}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Bitrate Quality
        SettingsItemWidget(
          title: 'Bitrate-Qualität',
          subtitle:
              _getBitrateDisplayName(settingsData['bitrateQuality'] as String),
          leadingIcon: CustomIconWidget(
            iconName: 'speed',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showBitrateQualitySelection(context),
        ),

        // ElevenLabs Optimization
        SettingsItemWidget(
          title: 'ElevenLabs-Optimierung',
          subtitle: 'Automatische Optimierung für beste KI-Sprachqualität',
          leadingIcon: CustomIconWidget(
            iconName: 'auto_awesome',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['elevenLabsOptimized'] as bool,
            onChanged: (value) {
              onSettingChanged('elevenLabsOptimized', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Quality Impact Information
        Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          padding: EdgeInsets.all(3.w),
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
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Aktuelle Einstellungen Auswirkungen',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speicherverbrauch pro Minute:',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          settingsData['sampleRate'] == '16kHz'
                              ? '~0.5 MB'
                              : '~1.4 MB',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: settingsData['sampleRate'] == '16kHz'
                                ? AppTheme.successLight
                                : AppTheme.warningLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datenverbrauch:',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          settingsData['bitrateQuality'] == 'low'
                              ? 'Niedrig'
                              : settingsData['bitrateQuality'] == 'medium'
                                  ? 'Mittel'
                                  : 'Hoch',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: settingsData['bitrateQuality'] == 'low'
                                ? AppTheme.successLight
                                : settingsData['bitrateQuality'] == 'medium'
                                    ? AppTheme.primaryLight
                                    : AppTheme.warningLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
