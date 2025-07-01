import 'package:sizer/sizer.dart';

import '../../controllers/api_config_controller.dart';
import '../../core/app_export.dart';
import '../../core/utils/api_validation_utils.dart';
import '../../models/elevenlabs_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
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
  bool _hasUnsavedChanges = false;
  String? _selectedAgent;
  String _selectedVoiceModel = 'eleven_multilingual_v2';
  double _responseSpeed = 0.5;
  String _audioQuality = 'high';
  bool _isBiometricEnabled = false;
  bool _useLiveApi = true; // New variable to control live/mock API usage
  Map<String, dynamic>? _connectionDetails;

  // Mock data for demonstration
  final List<Map<String, String>> _availableAgents = [
    {
      'id': 'agent_1',
      'name': 'DriveGuide Pro',
      'description': 'Optimized for German driving education',
      'voice': 'Professional, clear German accent',
    },
    {
      'id': 'agent_2',
      'name': 'Traffic Mentor',
      'description': 'Specialized in traffic law explanations',
      'voice': 'Patient, educational tone',
    },
    {
      'id': 'agent_3',
      'name': 'Road Safety Coach',
      'description': 'Focus on safety scenarios and best practices',
      'voice': 'Calm, reassuring guidance',
    },
  ];

  final List<String> _voiceModels = [
    'eleven_multilingual_v2',
    'eleven_monolingual_v1',
    'eleven_turbo_v2',
  ];

  final List<String> _audioQualities = ['low', 'medium', 'high', 'ultra'];

  late ApiConfigController _apiConfigController;

  @override
  void initState() {
    super.initState();
    _apiConfigController = Provider.of<ApiConfigController>(
      context,
      listen: false,
    );
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
      final config = _apiConfigController.config;
      setState(() {
        _apiKeyController.text = config.apiKey;
        _agentNumberController.text = config.agentNumber;
        _selectedAgent = config.selectedVoiceId;
        _selectedVoiceModel = config.voiceModel;
        _responseSpeed = config.responseSpeed;
        _audioQuality = config.audioQuality;
        _isBiometricEnabled = config.isBiometricEnabled;
        _useLiveApi = !_apiConfigController.useMockServices;
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
    final apiKeyValidationError = ApiValidationUtils.validateElevenLabsApiKey(
      _apiKeyController.text,
    );
    if (apiKeyValidationError != null) {
      _showErrorSnackBar('Invalid API key format: $apiKeyValidationError');
      return;
    }

    // Validate agent number format
    final agentNumberValidationError = ApiValidationUtils.validateAgentNumber(
      _agentNumberController.text,
    );
    if (agentNumberValidationError != null) {
      _showErrorSnackBar('Invalid agent number: $agentNumberValidationError');
      return;
    }

    // Set the mock service flag based on the toggle
    _apiConfigController.setUseMockServices(!_useLiveApi);

    // Update the configuration in the controller
    final newConfig = ElevenLabsConfig(
      apiKey: _apiKeyController.text,
      agentNumber: _agentNumberController.text,
      selectedVoiceId: _selectedAgent,
      voiceModel: _selectedVoiceModel,
      responseSpeed: _responseSpeed,
      audioQuality: _audioQuality,
      isBiometricEnabled: _isBiometricEnabled,
    );

    await _apiConfigController.saveConfiguration(newConfig);

    // Get connection details if successful
    if (_apiConfigController.isConnected) {
      final userInfo = await _apiConfigController.getUserInfo();
      if (userInfo['success']) {
        setState(() {
          _connectionDetails = userInfo['data'];
        });
      }
      _showSuccessSnackBar('Successfully connected to ElevenLabs!');
    }
  }

  Future<void> _saveConfiguration() async {
    // Validate API key before saving
    final apiKeyValidationError = ApiValidationUtils.validateElevenLabsApiKey(
      _apiKeyController.text,
    );
    if (apiKeyValidationError != null) {
      _showErrorSnackBar('Cannot save: $apiKeyValidationError');
      return;
    }

    // Validate agent number before saving
    final agentNumberValidationError = ApiValidationUtils.validateAgentNumber(
      _agentNumberController.text,
    );
    if (agentNumberValidationError != null) {
      _showErrorSnackBar('Cannot save: $agentNumberValidationError');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_apiConfigController.isConnected) {
      _showErrorSnackBar(
        'Please test the connection successfully before saving',
      );
      return;
    }

    try {
      // Set the mock service flag based on the toggle
      _apiConfigController.setUseMockServices(!_useLiveApi);

      // Create a new configuration
      final newConfig = ElevenLabsConfig(
        apiKey: _apiKeyController.text,
        agentNumber: _agentNumberController.text,
        selectedVoiceId: _selectedAgent,
        voiceModel: _selectedVoiceModel,
        responseSpeed: _responseSpeed,
        audioQuality: _audioQuality,
        isBiometricEnabled: _isBiometricEnabled,
      );

      // Save via the controller
      final result = await _apiConfigController.saveConfiguration(newConfig);

      if (result) {
        setState(() {
          _hasUnsavedChanges = false;
        });
        _showSuccessSnackBar('Configuration saved successfully!');
      } else {
        _showErrorSnackBar('Failed to save configuration');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save configuration: $e');
    }
  }

  Future<void> _resetConfiguration() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Configuration',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to reset all API configuration settings? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      try {
        final result = await _apiConfigController.resetConfiguration();

        if (result) {
          setState(() {
            _apiKeyController.clear();
            _agentNumberController.clear();
            _selectedAgent = null;
            _selectedVoiceModel = 'eleven_multilingual_v2';
            _responseSpeed = 0.5;
            _audioQuality = 'high';
            _isBiometricEnabled = false;
            _hasUnsavedChanges = false;
            _connectionDetails = null;
          });

          _showSuccessSnackBar('Configuration reset successfully');
        } else {
          _showErrorSnackBar('Failed to reset configuration');
        }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final bool? shouldLeave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Unsaved Changes',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'You have unsaved changes. Do you want to leave without saving?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiConfigController>(
      builder: (context, apiConfigController, child) {
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
              title: Text(
                'API Configuration',
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
                onPressed: () async {
                  final bool shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              actions: [
                if (_hasUnsavedChanges)
                  Container(
                    margin: EdgeInsets.only(right: 2.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unsaved',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.errorLight,
                    size: 24,
                  ),
                  onPressed: _resetConfiguration,
                  tooltip: 'Reset Configuration',
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // API Mode Selection
                    Container(
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
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'settings_remote',
                                color: AppTheme.primaryLight,
                                size: 24,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'API Mode',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          SwitchListTile(
                            title: Text(
                              'Use Live ElevenLabs API',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              _useLiveApi
                                  ? 'Using real ElevenLabs API with your credentials'
                                  : 'Using mock API (for testing only)',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        _useLiveApi
                                            ? AppTheme.successLight
                                            : AppTheme.warningLight,
                                  ),
                            ),
                            value: _useLiveApi,
                            onChanged: (value) {
                              setState(() {
                                _useLiveApi = value;
                                _hasUnsavedChanges = true;
                              });
                            },
                            activeColor: AppTheme.primaryLight,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (!_useLiveApi)
                            Container(
                              margin: EdgeInsets.only(top: 1.h),
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: AppTheme.warningLight.withAlpha(26),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.warningLight.withAlpha(77),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'info',
                                    color: AppTheme.warningLight,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'Mock mode uses simulated responses and doesn\'t consume API credits',
                                      style: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.warningLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // API Key Input Section
                    ApiKeyInputWidget(
                      controller: _apiKeyController,
                      isVisible: _isApiKeyVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isApiKeyVisible = !_isApiKeyVisible;
                        });
                      },
                      onChanged: (_) => _onSettingChanged(),
                    ),

                    SizedBox(height: 3.h),

                    // Agent Number Input Section
                    AgentNumberInputWidget(
                      controller: _agentNumberController,
                      onChanged: (_) => _onSettingChanged(),
                    ),

                    SizedBox(height: 3.h),

                    // Connection Test Section
                    ConnectionTestWidget(
                      isLoading: apiConfigController.isLoading,
                      connectionStatus: apiConfigController.connectionStatus,
                      isConnected: apiConfigController.isConnected,
                      connectionDetails: _connectionDetails,
                      onTestConnection: _testConnection,
                    ),

                    SizedBox(height: 3.h),

                    // Agent Selection (only show if connected)
                    if (apiConfigController.isConnected) ...[
                      AgentSelectionWidget(
                        agents: _availableAgents,
                        selectedAgent: _selectedAgent,
                        onAgentSelected: (agentId) {
                          setState(() {
                            _selectedAgent = agentId;
                          });
                          _onSettingChanged();
                        },
                      ),

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
                        },
                      ),

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
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Help Section
                    const HelpSectionWidget(),

                    SizedBox(height: 4.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _hasUnsavedChanges ? _saveConfiguration : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasUnsavedChanges
                                  ? AppTheme.primaryLight
                                  : AppTheme.textSecondaryLight,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child:
                            apiConfigController.isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.backgroundLight,
                                    ),
                                  ),
                                )
                                : Text(
                                  _hasUnsavedChanges
                                      ? 'Save Configuration'
                                      : 'Configuration Saved',
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.backgroundLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
