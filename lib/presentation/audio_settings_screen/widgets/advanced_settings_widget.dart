import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../settings_screen/widgets/settings_item_widget.dart';
import '../../settings_screen/widgets/settings_section_widget.dart';

// lib/presentation/audio_settings_screen/widgets/advanced_settings_widget.dart

class AdvancedSettingsWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const AdvancedSettingsWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  void _showDebugInformation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Audio-Pipeline Debug Information',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDebugSection('Audio Pipeline Status', [
                  'Input Device: Mikrofon (Aktiv)',
                  'Output Device: ${_getAudioDeviceDisplayName(settingsData['audioDevice'] as String)}',
                  'Sample Rate: ${settingsData['sampleRate']}',
                  'Buffer Size: ${settingsData['audioBufferSize']} samples',
                  'Latency Mode: ${settingsData['audioLatency']}',
                ]),
                SizedBox(height: 2.h),
                _buildDebugSection('Latenz-Messungen', [
                  'Input Latenz: 12 ms',
                  'Processing Latenz: 8 ms',
                  'Output Latenz: 15 ms',
                  'Gesamt-Latenz: ${settingsData['latencyMeasurement']} ms',
                  'Jitter: ±2 ms',
                ]),
                SizedBox(height: 2.h),
                _buildDebugSection('Verbindungsqualität', [
                  'Signalstärke: ${(settingsData['signalStrength'] * 100).round()}%',
                  'Paketverlust: 0.1%',
                  'Durchsatz: 128 kbps',
                  'Protokoll: WebRTC',
                  'Codec: Opus',
                ]),
                SizedBox(height: 2.h),
                _buildDebugSection('Audio-Verarbeitung', [
                  'Noise Suppression: ${settingsData['noiseSuppressionEnabled'] ? "Aktiv" : "Inaktiv"}',
                  'Echo Cancellation: Aktiv',
                  'Auto Gain Control: Aktiv',
                  'Voice Activity Detection: Aktiv',
                  'Audio Enhancement: ${settingsData['elevenLabsOptimized'] ? "ElevenLabs" : "Standard"}',
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Mock export functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Debug-Informationen in Zwischenablage kopiert',
                    ),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              },
              child: Text('Kopieren'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDebugSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryLight,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.3.h),
                    child: Text(
                      item,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLatencyModeSelection(BuildContext context) {
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
                'Audio-Latenz Modus auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...[
                {
                  'mode': 'low',
                  'label': 'Niedrige Latenz',
                  'description': 'Beste Reaktionszeit (höherer CPU-Verbrauch)',
                  'icon': 'speed',
                  'color': AppTheme.successLight,
                },
                {
                  'mode': 'auto',
                  'label': 'Automatisch',
                  'description':
                      'Optimale Balance zwischen Latenz und Stabilität',
                  'icon': 'auto_mode',
                  'color': AppTheme.primaryLight,
                },
                {
                  'mode': 'high',
                  'label': 'Hohe Latenz',
                  'description': 'Beste Stabilität bei langsameren Geräten',
                  'icon': 'battery_saver',
                  'color': AppTheme.warningLight,
                },
              ].map((item) {
                String mode = item['mode'] as String;
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: item['icon'] as String,
                    color: item['color'] as Color,
                    size: 24,
                  ),
                  title: Text(item['label'] as String),
                  subtitle: Text(item['description'] as String),
                  trailing:
                      settingsData['audioLatency'] == mode
                          ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.successLight,
                            size: 20,
                          )
                          : null,
                  onTap: () {
                    onSettingChanged('audioLatency', mode);
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

  void _showAudioFocusModeSelection(BuildContext context) {
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
                'Audio-Focus Modus auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Exklusiv'),
                subtitle: Text('App hat vollständige Audio-Kontrolle'),
                trailing:
                    settingsData['audioFocusMode'] == 'exclusive'
                        ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.successLight,
                          size: 20,
                        )
                        : null,
                onTap: () {
                  onSettingChanged('audioFocusMode', 'exclusive');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'people',
                  color: AppTheme.successLight,
                  size: 24,
                ),
                title: Text('Geteilt'),
                subtitle: Text('Audio kann mit anderen Apps geteilt werden'),
                trailing:
                    settingsData['audioFocusMode'] == 'shared'
                        ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.successLight,
                          size: 20,
                        )
                        : null,
                onTap: () {
                  onSettingChanged('audioFocusMode', 'shared');
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

  String _getLatencyModeDisplayName(String mode) {
    switch (mode) {
      case 'low':
        return 'Niedrige Latenz';
      case 'auto':
        return 'Automatisch';
      case 'high':
        return 'Hohe Latenz';
      default:
        return 'Unbekannt';
    }
  }

  String _getAudioFocusModeDisplayName(String mode) {
    switch (mode) {
      case 'exclusive':
        return 'Exklusiv';
      case 'shared':
        return 'Geteilt';
      default:
        return 'Unbekannt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Erweiterte Einstellungen',
      children: [
        // Debug Mode Toggle
        SettingsItemWidget(
          title: 'Debug-Modus',
          subtitle: 'Detaillierte Audio-Pipeline Informationen anzeigen',
          leadingIcon: CustomIconWidget(
            iconName: 'bug_report',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['debugMode'] as bool,
            onChanged: (value) {
              onSettingChanged('debugMode', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Show Debug Information (when debug mode is enabled)
        if (settingsData['debugMode'] as bool)
          SettingsItemWidget(
            title: 'Debug-Informationen anzeigen',
            subtitle: 'Audio-Pipeline Status und Leistungsmetriken',
            leadingIcon: CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            onTap: () => _showDebugInformation(context),
          ),

        // Audio Buffer Size
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'memory',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Audio-Puffergröße',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${settingsData['audioBufferSize']} Samples',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Text('Klein', style: AppTheme.lightTheme.textTheme.bodySmall),
                  Expanded(
                    child: Slider(
                      value:
                          (settingsData['audioBufferSize'] as int).toDouble(),
                      min: 256,
                      max: 4096,
                      divisions: 7,
                      onChanged: (value) {
                        onSettingChanged('audioBufferSize', value.round());
                      },
                      activeColor: AppTheme.primaryLight,
                      inactiveColor: AppTheme.primaryLight.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  Text('Groß', style: AppTheme.lightTheme.textTheme.bodySmall),
                ],
              ),
              Text(
                'Kleinere Werte = Niedrigere Latenz, Höhere CPU-Last',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Audio Latency Mode
        SettingsItemWidget(
          title: 'Latenz-Modus',
          subtitle: _getLatencyModeDisplayName(
            settingsData['audioLatency'] as String,
          ),
          leadingIcon: CustomIconWidget(
            iconName: 'timer',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showLatencyModeSelection(context),
        ),

        // Audio Focus Mode (Android specific)
        if (Theme.of(context).platform == TargetPlatform.android)
          SettingsItemWidget(
            title: 'Audio-Focus Modus',
            subtitle: _getAudioFocusModeDisplayName(
              settingsData['audioFocusMode'] as String,
            ),
            leadingIcon: CustomIconWidget(
              iconName: 'volume_up',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            onTap: () => _showAudioFocusModeSelection(context),
          ),

        // Performance Information
        Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'speed',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Leistungsmetriken',
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
                          'CPU-Verbrauch:',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          '12% (Audio)',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.successLight,
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
                          'RAM-Verbrauch:',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          '45 MB',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.successLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              if (settingsData['debugMode'] as bool)
                Text(
                  'Aktuelle Latenz: ${settingsData['latencyMeasurement']} ms • Buffer Underruns: 0 • Dropped Frames: 0',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
