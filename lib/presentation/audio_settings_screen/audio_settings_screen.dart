import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/playback_section_widget.dart';
import './widgets/quality_section_widget.dart';
import './widgets/recording_section_widget.dart';
import './widgets/test_section_widget.dart';

// lib/presentation/audio_settings_screen/audio_settings_screen.dart

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  // Audio settings data
  final Map<String, dynamic> _audioSettings = {
    // Recording settings
    'microphoneSensitivity': 0.7,
    'noiseSuppressionEnabled': true,
    'recordingMode': 'continuous', // 'push-to-talk' or 'continuous'
    'noiseCancellationLevel': 0.8,
    'microphoneGain': 0.6,
    'voiceActivationThreshold': 0.3,

    // Playback settings
    'volumeLevel': 0.8,
    'audioDevice': 'speaker', // 'speaker', 'headphones', 'bluetooth'
    'playbackSpeed': 1.0,
    'autoDeviceSwitching': true,
    'spatialAudioEnabled': false,
    'bassBoostEnabled': false,

    // Quality settings
    'sampleRate': '44.1kHz', // '16kHz' or '44.1kHz'
    'audioFormat': 'compressed', // 'uncompressed' or 'compressed'
    'compressionLevel': 0.5,
    'elevenLabsOptimized': true,
    'bitrateQuality': 'medium', // 'low', 'medium', 'high'
    // Test settings
    'microphoneTestEnabled': false,
    'echoTestMode': false,
    'connectionQualityTest': false,
    'latencyMeasurement': 45, // ms
    'signalStrength': 0.9,

    // Advanced settings
    'debugMode': false,
    'audioBufferSize': 1024,
    'audioLatency': 'auto', // 'low', 'auto', 'high'
    'audioFocusMode': 'exclusive',
  };

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _audioSettings[key] = value;
    });

    // Provide audio feedback for important changes
    if (['volumeLevel', 'playbackSpeed', 'audioDevice'].contains(key)) {
      _playTestSound();
    }
  }

  void _playTestSound() {
    // Mock audio feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Audio-Einstellung angewandt'),
        duration: Duration(milliseconds: 800),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _resetToOptimalDefaults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Optimale Einstellungen wiederherstellen',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Die folgenden optimalen Einstellungen werden angewandt:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                '• Mikrofon-Empfindlichkeit: 70%',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '• Rauschunterdrückung: Aktiviert',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '• Aufnahmemodus: Kontinuierlich',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '• Lautstärke: 80%',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '• Abtastrate: 44.1kHz',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '• Komprimierung: Mittel',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyOptimalSettings();
              },
              child: Text('Anwenden'),
            ),
          ],
        );
      },
    );
  }

  void _applyOptimalSettings() {
    setState(() {
      _audioSettings['microphoneSensitivity'] = 0.7;
      _audioSettings['noiseSuppressionEnabled'] = true;
      _audioSettings['recordingMode'] = 'continuous';
      _audioSettings['noiseCancellationLevel'] = 0.8;
      _audioSettings['volumeLevel'] = 0.8;
      _audioSettings['audioDevice'] = 'speaker';
      _audioSettings['playbackSpeed'] = 1.0;
      _audioSettings['sampleRate'] = '44.1kHz';
      _audioSettings['audioFormat'] = 'compressed';
      _audioSettings['compressionLevel'] = 0.5;
      _audioSettings['elevenLabsOptimized'] = true;
      _audioSettings['bitrateQuality'] = 'medium';
      _audioSettings['autoDeviceSwitching'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Optimale Audio-Einstellungen wurden angewandt'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _showBatteryDataUsageInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Akku- und Datenverbrauch',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktuelle Einstellungen Auswirkungen:',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 2.h),
                _buildUsageIndicator(
                  'Akku-Verbrauch',
                  0.6,
                  AppTheme.warningLight,
                ),
                SizedBox(height: 1.h),
                _buildUsageIndicator(
                  'Datenverbrauch',
                  0.4,
                  AppTheme.successLight,
                ),
                SizedBox(height: 1.h),
                _buildUsageIndicator(
                  'Speicherplatz',
                  0.3,
                  AppTheme.successLight,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Empfehlungen:',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Reduzieren Sie die Abtastrate für längere Akkulaufzeit',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                Text(
                  '• Aktivieren Sie Komprimierung für geringeren Datenverbrauch',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                Text(
                  '• Push-to-Talk spart Akku bei seltener Nutzung',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Verstanden'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsageIndicator(String label, double value, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: AppTheme.lightTheme.textTheme.bodySmall),
        ),
        Expanded(
          flex: 4,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '${(value * 100).round()}%',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Audio',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                AppTheme.textPrimaryLight,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'battery_info',
              color:
                  AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                  AppTheme.textPrimaryLight,
              size: 24,
            ),
            onPressed: _showBatteryDataUsageInfo,
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'restore',
              color:
                  AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                  AppTheme.textPrimaryLight,
              size: 24,
            ),
            onPressed: _resetToOptimalDefaults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recording Section
            RecordingSectionWidget(
              settingsData: _audioSettings,
              onSettingChanged: _updateSetting,
            ),
            SizedBox(height: 3.h),

            // Playback Section
            PlaybackSectionWidget(
              settingsData: _audioSettings,
              onSettingChanged: _updateSetting,
            ),
            SizedBox(height: 3.h),

            // Quality Section
            QualitySectionWidget(
              settingsData: _audioSettings,
              onSettingChanged: _updateSetting,
            ),
            SizedBox(height: 3.h),

            // Test Section
            TestSectionWidget(
              settingsData: _audioSettings,
              onSettingChanged: _updateSetting,
            ),
            SizedBox(height: 3.h),

            // Advanced Settings
            AdvancedSettingsWidget(
              settingsData: _audioSettings,
              onSettingChanged: _updateSetting,
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
