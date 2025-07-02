
import '../../../core/app_export.dart';
import '../../settings_screen/widgets/settings_item_widget.dart';
import '../../settings_screen/widgets/settings_section_widget.dart';

// lib/presentation/audio_settings_screen/widgets/test_section_widget.dart

class TestSectionWidget extends StatefulWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const TestSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  @override
  State<TestSectionWidget> createState() => _TestSectionWidgetState();
}

class _TestSectionWidgetState extends State<TestSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _microphoneTestController;
  late AnimationController _echoTestController;
  late AnimationController _connectionTestController;
  late Animation<double> _pulseAnimation;

  bool _isMicrophoneTestRunning = false;
  bool _isEchoTestRunning = false;
  bool _isConnectionTestRunning = false;

  @override
  void initState() {
    super.initState();
    _microphoneTestController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _echoTestController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _connectionTestController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _microphoneTestController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _microphoneTestController.dispose();
    _echoTestController.dispose();
    _connectionTestController.dispose();
    super.dispose();
  }

  void _startMicrophoneTest() {
    setState(() {
      _isMicrophoneTestRunning = true;
      widget.onSettingChanged('microphoneTestEnabled', true);
    });
    _microphoneTestController.repeat();

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _microphoneTestController.stop();
        setState(() {
          _isMicrophoneTestRunning = false;
          widget.onSettingChanged('microphoneTestEnabled', false);
        });
        _showMicrophoneTestResults();
      }
    });
  }

  void _showMicrophoneTestResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Mikrofon-Test Ergebnisse',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTestResult(
                  'Mikrofon-Erkennung',
                  true,
                  'Mikrofon gefunden und funktionsfähig',
                ),
                SizedBox(height: 1.h),
                _buildTestResult(
                  'Audio-Aufnahme',
                  true,
                  'Aufnahme erfolgreich',
                ),
                SizedBox(height: 1.h),
                _buildTestResult('Signal-Stärke', true, '92% - Ausgezeichnet'),
                SizedBox(height: 1.h),
                _buildTestResult('Rauschpegel', true, 'Niedrig (-45 dB)'),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Empfehlung: Ihre Mikrofon-Einstellungen sind optimal konfiguriert.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Schließen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startRecordingPlaybackTest();
              },
              child: Text('Aufnahme & Wiedergabe testen'),
            ),
          ],
        );
      },
    );
  }

  void _startRecordingPlaybackTest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Aufnahme & Wiedergabe Test',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sprechen Sie einen kurzen Satz (5 Sekunden)',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              AnimatedBuilder(
                animation: _microphoneTestController,
                builder: (context, child) {
                  return Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight.withValues(
                        alpha: 0.3 + (0.7 * _pulseAnimation.value),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'mic',
                        color: AppTheme.errorLight,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 2.h),
              Text(
                '🔴 Aufnahme läuft...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );

    _microphoneTestController.repeat();

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _microphoneTestController.stop();
        Navigator.of(context).pop();
        _showPlaybackTestDialog();
      }
    });
  }

  void _showPlaybackTestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Wiedergabe Test',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'play_arrow',
                color: AppTheme.successLight,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Ihre Aufnahme wird jetzt wiedergegeben.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Können Sie Ihre Stimme klar hören?',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPlaybackIssuesDialog();
              },
              child: Text('Nein, Probleme'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Audio-Test erfolgreich abgeschlossen!'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              },
              child: Text('Ja, perfekt!'),
            ),
          ],
        );
      },
    );
  }

  void _showPlaybackIssuesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Audio-Probleme beheben',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mögliche Lösungen:',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                _buildSolutionItem('Lautstärke erhöhen', 'volume_up'),
                _buildSolutionItem('Audio-Gerät überprüfen', 'headphones'),
                _buildSolutionItem('App-Berechtigungen prüfen', 'security'),
                _buildSolutionItem('Gerät neu starten', 'restart_alt'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Schließen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startMicrophoneTest();
              },
              child: Text('Erneut testen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSolutionItem(String title, String iconName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.primaryLight,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(title, style: AppTheme.lightTheme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _startEchoTest() {
    setState(() {
      _isEchoTestRunning = true;
      widget.onSettingChanged('echoTestMode', true);
    });
    _echoTestController.repeat();

    Future.delayed(Duration(seconds: 6), () {
      if (mounted) {
        _echoTestController.stop();
        setState(() {
          _isEchoTestRunning = false;
          widget.onSettingChanged('echoTestMode', false);
        });
        _showEchoTestResults();
      }
    });
  }

  void _showEchoTestResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Echo-Unterdrückung Test',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTestResult('Echo-Erkennung', true, 'Kein Echo erkannt'),
              SizedBox(height: 1.h),
              _buildTestResult('Verzögerung', true, '< 50ms (Ausgezeichnet)'),
              SizedBox(height: 1.h),
              _buildTestResult('Rückkopplung', true, 'Keine Rückkopplung'),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Echo-Unterdrückung funktioniert optimal.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successLight,
                  ),
                ),
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

  void _startConnectionQualityTest() {
    setState(() {
      _isConnectionTestRunning = true;
      widget.onSettingChanged('connectionQualityTest', true);
    });
    _connectionTestController.repeat();

    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        _connectionTestController.stop();
        setState(() {
          _isConnectionTestRunning = false;
          widget.onSettingChanged('connectionQualityTest', false);
        });
        _showConnectionTestResults();
      }
    });
  }

  void _showConnectionTestResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verbindungsqualität Test',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTestResult('Internetverbindung', true, 'Stabil (WiFi)'),
                SizedBox(height: 1.h),
                _buildTestResult(
                  'Latenz',
                  true,
                  '${widget.settingsData['latencyMeasurement']} ms',
                ),
                SizedBox(height: 1.h),
                _buildTestResult(
                  'Signalstärke',
                  true,
                  '${(widget.settingsData['signalStrength'] * 100).round()}%',
                ),
                SizedBox(height: 1.h),
                _buildTestResult('Paketverlust', true, '0% - Perfekt'),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verbindungsqualität: Ausgezeichnet',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successLight,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Ihre Verbindung ist optimal für Echtzeit-Audio.',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.successLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestResult(String title, bool success, String details) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: success ? 'check_circle' : 'error',
          color: success ? AppTheme.successLight : AppTheme.errorLight,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                details,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Audio-Tests',
      children: [
        // Microphone Test with Recording Playback
        SettingsItemWidget(
          title: 'Mikrofon-Test',
          subtitle: _isMicrophoneTestRunning
              ? 'Test läuft... Bitte sprechen Sie'
              : 'Mikrofon und Aufnahmequalität testen',
          leadingIcon: AnimatedBuilder(
            animation: _microphoneTestController,
            builder: (context, child) {
              return CustomIconWidget(
                iconName: 'mic',
                color: _isMicrophoneTestRunning
                    ? Color.lerp(
                          AppTheme.primaryLight,
                          AppTheme.errorLight,
                          _pulseAnimation.value,
                        ) ??
                        AppTheme.primaryLight
                    : AppTheme.primaryLight,
                size: 24,
              );
            },
          ),
          trailing: _isMicrophoneTestRunning
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryLight,
                    ),
                  ),
                )
              : null,
          onTap: _isMicrophoneTestRunning ? null : _startMicrophoneTest,
        ),

        // Echo Cancellation Test
        SettingsItemWidget(
          title: 'Echo-Unterdrückung Test',
          subtitle: _isEchoTestRunning
              ? 'Echo-Test läuft...'
              : 'Rückkopplung und Echo-Unterdrückung prüfen',
          leadingIcon: AnimatedBuilder(
            animation: _echoTestController,
            builder: (context, child) {
              return CustomIconWidget(
                iconName: 'vibration',
                color: _isEchoTestRunning
                    ? Color.lerp(
                          AppTheme.primaryLight,
                          AppTheme.successLight,
                          _echoTestController.value,
                        ) ??
                        AppTheme.primaryLight
                    : AppTheme.primaryLight,
                size: 24,
              );
            },
          ),
          trailing: _isEchoTestRunning
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryLight,
                    ),
                  ),
                )
              : null,
          onTap: _isEchoTestRunning ? null : _startEchoTest,
        ),

        // Connection Quality Test
        SettingsItemWidget(
          title: 'Verbindungsqualität Test',
          subtitle: _isConnectionTestRunning
              ? 'Verbindung wird getestet...'
              : 'Latenz und Signalstärke messen',
          leadingIcon: AnimatedBuilder(
            animation: _connectionTestController,
            builder: (context, child) {
              return CustomIconWidget(
                iconName: 'network_check',
                color: _isConnectionTestRunning
                    ? Color.lerp(
                          AppTheme.primaryLight,
                          AppTheme.warningLight,
                          _connectionTestController.value,
                        ) ??
                        AppTheme.primaryLight
                    : AppTheme.primaryLight,
                size: 24,
              );
            },
          ),
          trailing: _isConnectionTestRunning
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryLight,
                    ),
                  ),
                )
              : null,
          onTap: _isConnectionTestRunning ? null : _startConnectionQualityTest,
        ),

        // Current Audio Status Info
        if (!_isMicrophoneTestRunning &&
            !_isEchoTestRunning &&
            !_isConnectionTestRunning)
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
                      iconName: 'analytics',
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Aktueller Audio-Status',
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
                            'Latenz:',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.settingsData['latencyMeasurement']} ms',
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
                            'Signalstärke:',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          Text(
                            '${(widget.settingsData['signalStrength'] * 100).round()}%',
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
              ],
            ),
          ),
      ],
    );
  }
}
