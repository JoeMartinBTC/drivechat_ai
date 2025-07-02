
import '../../../core/app_export.dart';
import '../../settings_screen/widgets/settings_item_widget.dart';
import '../../settings_screen/widgets/settings_section_widget.dart';

// lib/presentation/audio_settings_screen/widgets/recording_section_widget.dart

class RecordingSectionWidget extends StatefulWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const RecordingSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  @override
  State<RecordingSectionWidget> createState() => _RecordingSectionWidgetState();
}

class _RecordingSectionWidgetState extends State<RecordingSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _levelAnimationController;
  late Animation<double> _levelAnimation;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _levelAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _levelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _levelAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _levelAnimationController.dispose();
    super.dispose();
  }

  void _showRecordingModeSelection() {
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
                'Aufnahmemodus wählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'radio_button_checked',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Kontinuierlich'),
                subtitle: Text('Ständige Aufnahme (höherer Akkuverbrauch)'),
                trailing: widget.settingsData['recordingMode'] == 'continuous'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  widget.onSettingChanged('recordingMode', 'continuous');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'push_pin',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Push-to-Talk'),
                subtitle: Text('Aufnahme nur bei gehaltener Taste (sparsamer)'),
                trailing: widget.settingsData['recordingMode'] == 'push-to-talk'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.successLight,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  widget.onSettingChanged('recordingMode', 'push-to-talk');
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

  void _testMicrophone() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _levelAnimationController.repeat(reverse: true);
      // Simulate recording for 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
          _levelAnimationController.reset();
          _showMicrophoneTestResult();
        }
      });
    } else {
      _levelAnimationController.reset();
    }
  }

  void _showMicrophoneTestResult() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Mikrofon-Test Ergebnis',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Mikrofon funktioniert einwandfrei!',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Durchschnittlicher Pegel: 78%\nSignal-Rausch-Verhältnis: Ausgezeichnet',
                style: AppTheme.lightTheme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _getRecordingModeDisplayName(String mode) {
    return mode == 'continuous' ? 'Kontinuierlich' : 'Push-to-Talk';
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Aufnahme-Einstellungen',
      children: [
        // Microphone Sensitivity with Real-time Level Meter
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
                  Spacer(),
                  // Real-time level meter
                  AnimatedBuilder(
                    animation: _levelAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 15.w,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.surfaceLight,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _isRecording
                              ? _levelAnimation.value *
                                  widget.settingsData['microphoneSensitivity']
                              : widget.settingsData['microphoneSensitivity'],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: _isRecording
                                  ? AppTheme.successLight
                                  : AppTheme.primaryLight,
                            ),
                          ),
                        ),
                      );
                    },
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
                      value: (widget.settingsData['microphoneSensitivity']
                              as double)
                          .clamp(0.0, 1.0),
                      onChanged: (value) {
                        widget.onSettingChanged('microphoneSensitivity', value);
                      },
                      activeColor: AppTheme.primaryLight,
                      inactiveColor: AppTheme.primaryLight.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  Text('Hoch', style: AppTheme.lightTheme.textTheme.bodySmall),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${((widget.settingsData['microphoneSensitivity'] as double) * 100).round()}%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _testMicrophone,
                    icon: CustomIconWidget(
                      iconName: _isRecording ? 'stop' : 'mic',
                      color: _isRecording
                          ? AppTheme.errorLight
                          : AppTheme.successLight,
                      size: 16,
                    ),
                    label: Text(
                      _isRecording ? 'Stoppen' : 'Testen',
                      style: TextStyle(
                        color: _isRecording
                            ? AppTheme.errorLight
                            : AppTheme.successLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Noise Suppression with Preview
        SettingsItemWidget(
          title: 'Rauschunterdrückung',
          subtitle: 'Hintergrundgeräusche intelligentreduzieren',
          leadingIcon: CustomIconWidget(
            iconName: 'noise_control_off',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rauschunterdrückung Vorschau aktiviert'),
                      backgroundColor: AppTheme.primaryLight,
                    ),
                  );
                },
                child: Text(
                  'Vorschau',
                  style: TextStyle(color: AppTheme.primaryLight),
                ),
              ),
              Switch(
                value: widget.settingsData['noiseSuppressionEnabled'] as bool,
                onChanged: (value) {
                  widget.onSettingChanged('noiseSuppressionEnabled', value);
                },
                activeColor: AppTheme.primaryLight,
              ),
            ],
          ),
          showTrailing: false,
        ),

        // Noise Cancellation Level (when noise suppression is enabled)
        if (widget.settingsData['noiseSuppressionEnabled'] as bool)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                      'Intensität der Rauschunterdrückung',
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
                        'Schwach',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      Expanded(
                        child: Slider(
                          value: (widget.settingsData['noiseCancellationLevel']
                                  as double)
                              .clamp(0.0, 1.0),
                          onChanged: (value) {
                            widget.onSettingChanged(
                              'noiseCancellationLevel',
                              value,
                            );
                          },
                          activeColor: AppTheme.primaryLight,
                          inactiveColor: AppTheme.primaryLight.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      Text(
                        'Stark',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    '${((widget.settingsData['noiseCancellationLevel'] as double) * 100).round()}%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Recording Mode Selection
        SettingsItemWidget(
          title: 'Aufnahmemodus',
          subtitle: _getRecordingModeDisplayName(
            widget.settingsData['recordingMode'] as String,
          ),
          leadingIcon: CustomIconWidget(
            iconName: widget.settingsData['recordingMode'] == 'continuous'
                ? 'radio_button_checked'
                : 'push_pin',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: _showRecordingModeSelection,
        ),

        // Voice Activation Threshold (for continuous mode)
        if (widget.settingsData['recordingMode'] == 'continuous')
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 8.w), // Indent for sub-setting
                    CustomIconWidget(
                      iconName: 'graphic_eq',
                      color: AppTheme.textSecondaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Sprach-Aktivierungsschwelle',
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
                        'Leise',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      Expanded(
                        child: Slider(
                          value:
                              (widget.settingsData['voiceActivationThreshold']
                                      as double)
                                  .clamp(0.0, 1.0),
                          onChanged: (value) {
                            widget.onSettingChanged(
                              'voiceActivationThreshold',
                              value,
                            );
                          },
                          activeColor: AppTheme.primaryLight,
                          inactiveColor: AppTheme.primaryLight.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      Text(
                        'Laut',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    '${((widget.settingsData['voiceActivationThreshold'] as double) * 100).round()}%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
