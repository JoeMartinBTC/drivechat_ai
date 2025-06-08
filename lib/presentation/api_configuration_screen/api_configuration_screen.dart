import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/utils/api_validation_utils.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/agent_number_input_widget.dart';
import './widgets/agent_selection_widget.dart';
import './widgets/api_key_input_widget.dart';
import './widgets/connection_test_widget.dart';
import './widgets/help_section_widget.dart';
import './widgets/security_settings_widget.dart';

// lib/presentation/api_configuration_screen/api_configuration_screen.dart

class ApiConfigurationScreen extends StatefulWidget {
  const ApiConfigurationScreen({super.key});

  @override
  State<ApiConfigurationScreen> createState() => _ApiConfigurationScreenState();
}

class _ApiConfigurationScreenState extends State<ApiConfigurationScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _agentNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables
  bool _isApiKeyVisible = false;
  bool _isLoading = false;
  bool _isConnectionSuccessful = false;
  bool _isBiometricEnabled = false;
  bool _hasUnsavedChanges = false;
  String _connectionStatus = 'Not tested';
  String? _selectedAgent;
  String _selectedVoiceModel = 'eleven_multilingual_v2';
  double _responseSpeed = 0.5;
  String _audioQuality = 'high';

  // Mock data for demonstration
  final List<Map<String, String>> _availableAgents = [
    {
      'id': 'agent_1',
      'name': 'DriveGuide Pro',
      'description': 'Optimized for German driving education',
      'voice': 'Professional, clear German accent'
    },
    {
      'id': 'agent_2',
      'name': 'Traffic Mentor',
      'description': 'Specialized in traffic law explanations',
      'voice': 'Patient, educational tone'
    },
    {
      'id': 'agent_3',
      'name': 'Road Safety Coach',
      'description': 'Focus on safety scenarios and best practices',
      'voice': 'Calm, reassuring guidance'
    },
  ];

  final List<String> _voiceModels = [
    'eleven_multilingual_v2',
    'eleven_monolingual_v1',
    'eleven_turbo_v2'
  ];

  final List<String> _audioQualities = ['low', 'medium', 'high', 'ultra'];

  @override
  void initState() {
    super.initState();
    _loadSavedConfiguration();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _agentNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _apiKeyController.text = prefs.getString('elevenlabs_api_key') ?? '';
        _agentNumberController.text =
            prefs.getString('elevenlabs_agent_number') ?? '';
        _selectedAgent = prefs.getString('selected_agent');
        _selectedVoiceModel =
            prefs.getString('voice_model') ?? 'eleven_multilingual_v2';
        _responseSpeed = prefs.getDouble('response_speed') ?? 0.5;
        _audioQuality = prefs.getString('audio_quality') ?? 'high';
        _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      });

      if (_apiKeyController.text.isNotEmpty) {
        _testConnection();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load saved configuration: $e');
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      _showErrorSnackBar('Please enter your ElevenLabs API key first');
      return;
    }

    if (_agentNumberController.text.isEmpty) {
      _showErrorSnackBar('Please enter your ElevenLabs agent number');
      return;
    }

    // Validate API key format first
    final apiKeyValidationError =
        ApiValidationUtils.validateElevenLabsApiKey(_apiKeyController.text);
    if (apiKeyValidationError != null) {
      _showErrorSnackBar('Invalid API key format: $apiKeyValidationError');
      setState(() {
        _connectionStatus = 'Invalid API key format';
        _isConnectionSuccessful = false;
      });
      return;
    }

    // Validate agent number format
    final agentNumberValidationError =
        ApiValidationUtils.validateAgentNumber(_agentNumberController.text);
    if (agentNumberValidationError != null) {
      _showErrorSnackBar('Invalid agent number: $agentNumberValidationError');
      setState(() {
        _connectionStatus = 'Invalid agent number';
        _isConnectionSuccessful = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Get clean API key for validation
      String cleanApiKey =
          ApiValidationUtils.cleanApiKey(_apiKeyController.text);

      // Enhanced validation - check for correct sk_ prefix and minimum length
      bool isValidKey = ApiValidationUtils.isValidElevenLabsApiKey(cleanApiKey);
      bool isValidAgentNumber =
          ApiValidationUtils.isValidAgentNumber(_agentNumberController.text);

      setState(() {
        _isLoading = false;
        _isConnectionSuccessful = isValidKey && isValidAgentNumber;
        _connectionStatus = (isValidKey && isValidAgentNumber)
            ? 'Connected successfully'
            : 'Connection failed - Invalid credentials';
      });

      if (isValidKey && isValidAgentNumber) {
        _showSuccessSnackBar('Successfully connected to ElevenLabs!');
      } else {
        if (!isValidKey) {
          _showErrorSnackBar(
              'Invalid API key. Please ensure it starts with "sk_" and has the correct format.');
        } else {
          _showErrorSnackBar(
              'Invalid agent number. Please provide a valid ElevenLabs agent number.');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isConnectionSuccessful = false;
        _connectionStatus = 'Connection error';
      });
      _showErrorSnackBar('Connection test failed: $e');
    }
  }

  Future<void> _saveConfiguration() async {
    // Validate API key before saving
    final apiKeyValidationError =
        ApiValidationUtils.validateElevenLabsApiKey(_apiKeyController.text);
    if (apiKeyValidationError != null) {
      _showErrorSnackBar('Cannot save: $apiKeyValidationError');
      return;
    }

    // Validate agent number before saving
    final agentNumberValidationError =
        ApiValidationUtils.validateAgentNumber(_agentNumberController.text);
    if (agentNumberValidationError != null) {
      _showErrorSnackBar('Cannot save: $agentNumberValidationError');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isConnectionSuccessful) {
      _showErrorSnackBar(
          'Please test the connection successfully before saving');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save clean API key (without spaces)
      String cleanApiKey =
          ApiValidationUtils.cleanApiKey(_apiKeyController.text);
      await prefs.setString('elevenlabs_api_key', cleanApiKey);
      await prefs.setString(
          'elevenlabs_agent_number', _agentNumberController.text);
      await prefs.setString('selected_agent', _selectedAgent ?? '');
      await prefs.setString('voice_model', _selectedVoiceModel);
      await prefs.setDouble('response_speed', _responseSpeed);
      await prefs.setString('audio_quality', _audioQuality);
      await prefs.setBool('biometric_enabled', _isBiometricEnabled);

      setState(() {
        _hasUnsavedChanges = false;
      });

      _showSuccessSnackBar('Configuration saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to save configuration: $e');
    }
  }

  Future<void> _resetConfiguration() async {
    final bool? shouldReset = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Reset Configuration',
                  style: AppTheme.lightTheme.textTheme.titleLarge),
              content: Text(
                  'Are you sure you want to reset all API configuration settings? This action cannot be undone.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorLight),
                    child: const Text('Reset')),
              ]);
        });

    if (shouldReset == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        setState(() {
          _apiKeyController.clear();
          _agentNumberController.clear();
          _selectedAgent = null;
          _selectedVoiceModel = 'eleven_multilingual_v2';
          _responseSpeed = 0.5;
          _audioQuality = 'high';
          _isBiometricEnabled = false;
          _isConnectionSuccessful = false;
          _connectionStatus = 'Not tested';
          _hasUnsavedChanges = false;
        });

        _showSuccessSnackBar('Configuration reset successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to reset configuration: $e');
      }
    }
  }

  void _onSettingChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating));
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final bool? shouldLeave = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Unsaved Changes',
                  style: AppTheme.lightTheme.textTheme.titleLarge),
              content: Text(
                  'You have unsaved changes. Do you want to leave without saving?',
                  style: AppTheme.lightTheme.textTheme.bodyMedium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Stay')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Leave')),
              ]);
        });

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final bool shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            appBar: AppBar(
                title: Text('API Configuration',
                    style: AppTheme.lightTheme.appBarTheme.titleTextStyle),
                backgroundColor:
                    AppTheme.lightTheme.appBarTheme.backgroundColor,
                elevation: AppTheme.lightTheme.appBarTheme.elevation,
                leading: IconButton(
                    icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color:
                            AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                                AppTheme.textPrimaryLight,
                        size: 24),
                    onPressed: () async {
                      final bool shouldPop = await _onWillPop();
                      if (shouldPop && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }),
                actions: [
                  if (_hasUnsavedChanges)
                    Container(
                        margin: EdgeInsets.only(right: 2.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                            color: AppTheme.warningLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('Unsaved',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                    color: AppTheme.warningLight,
                                    fontWeight: FontWeight.w500))),
                  IconButton(
                      icon: CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.errorLight,
                          size: 24),
                      onPressed: _resetConfiguration,
                      tooltip: 'Reset Configuration'),
                ]),
            body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // API Key Input Section
                          ApiKeyInputWidget(
                              controller: _apiKeyController,
                              isVisible: _isApiKeyVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isApiKeyVisible = !_isApiKeyVisible;
                                });
                              },
                              onChanged: (_) => _onSettingChanged()),

                          SizedBox(height: 3.h),

                          // Agent Number Input Section
                          AgentNumberInputWidget(
                              controller: _agentNumberController,
                              onChanged: (_) => _onSettingChanged()),

                          SizedBox(height: 3.h),

                          // Connection Test Section
                          ConnectionTestWidget(
                              isLoading: _isLoading,
                              connectionStatus: _connectionStatus,
                              isConnected: _isConnectionSuccessful,
                              onTestConnection: _testConnection),

                          SizedBox(height: 3.h),

                          // Agent Selection (only show if connected)
                          if (_isConnectionSuccessful) ...[
                            AgentSelectionWidget(
                                agents: _availableAgents,
                                selectedAgent: _selectedAgent,
                                onAgentSelected: (agentId) {
                                  setState(() {
                                    _selectedAgent = agentId;
                                  });
                                  _onSettingChanged();
                                }),

                            SizedBox(height: 3.h),

                            // Advanced Settings
                            AdvancedSettingsWidget(
                                selectedVoiceModel: _selectedVoiceModel,
                                voiceModels: _voiceModels,
                                responseSpeed: _responseSpeed,
                                audioQuality: _audioQuality,
                                audioQualities: _audioQualities,
                                onVoiceModelChanged: (model) {
                                  setState(() {
                                    _selectedVoiceModel = model;
                                  });
                                  _onSettingChanged();
                                },
                                onResponseSpeedChanged: (speed) {
                                  setState(() {
                                    _responseSpeed = speed;
                                  });
                                  _onSettingChanged();
                                },
                                onAudioQualityChanged: (quality) {
                                  setState(() {
                                    _audioQuality = quality;
                                  });
                                  _onSettingChanged();
                                }),

                            SizedBox(height: 3.h),
                          ],

                          // Security Settings
                          SecuritySettingsWidget(
                              isBiometricEnabled: _isBiometricEnabled,
                              onBiometricToggle: (enabled) {
                                setState(() {
                                  _isBiometricEnabled = enabled;
                                });
                                _onSettingChanged();
                              }),

                          SizedBox(height: 3.h),

                          // Help Section
                          const HelpSectionWidget(),

                          SizedBox(height: 4.h),

                          // Save Button
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: _hasUnsavedChanges
                                      ? _saveConfiguration
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: _hasUnsavedChanges
                                          ? AppTheme.primaryLight
                                          : AppTheme.textSecondaryLight,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.h)),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                  AppTheme.backgroundLight)))
                                      : Text(
                                          _hasUnsavedChanges
                                              ? 'Save Configuration'
                                              : 'Configuration Saved',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleMedium
                                              ?.copyWith(
                                                  color:
                                                      AppTheme.backgroundLight,
                                                  fontWeight:
                                                      FontWeight.w600)))),

                          SizedBox(height: 2.h),
                        ])))));
  }
}
