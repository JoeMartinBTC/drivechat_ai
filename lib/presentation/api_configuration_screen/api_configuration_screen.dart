import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/api_config_controller.dart';
import '../../core/app_export.dart';
import '../../core/utils/api_validation_utils.dart';
import '../../models/elevenlabs_config.dart';
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

  late ApiConfigController _apiConfigController;

  @override
  void initState() {
    super.initState();
    _apiConfigController =
        Provider.of<ApiConfigController>(context, listen: false);
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
    // Force live API mode if user is testing with credentials
    if (_useLiveApi &&
        _apiKeyController.text.isNotEmpty &&
        _agentNumberController.text.isNotEmpty) {
      await _apiConfigController.forceLiveApi();
    }

    if (!_useLiveApi && !_apiConfigController.forceLiveApiMode) {
      // If using mock API, just test the mock connection
      _apiConfigController.setUseMockServices(true);
      final result = await _apiConfigController.testConnection();
      if (result) {
        setState(() {
          _connectionDetails = {
            'subscription': {
              'tier': 'mock',
              'character_count': 50000,
              'character_limit': 100000,
              'status': 'demo'
            }
          };
        });
        _showErrorSnackBar(
            'Connected to Demo Mode - Enable "Force Live API" to use real ElevenLabs service');
      }
      return;
    }

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
      return;
    }

    // Validate agent number format
    final agentNumberValidationError =
        ApiValidationUtils.validateAgentNumber(_agentNumberController.text);
    if (agentNumberValidationError != null) {
      _showErrorSnackBar('Invalid agent number: $agentNumberValidationError');
      return;
    }

    // Set the mock service flag based on the toggle (but respect force mode)
    if (!_apiConfigController.forceLiveApiMode) {
      await _apiConfigController.setUseMockServices(!_useLiveApi);
    }

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

    final saveResult = await _apiConfigController.saveConfiguration(newConfig);

    if (saveResult) {
      // Get connection details if successful
      if (_apiConfigController.isConnected) {
        final userInfo = await _apiConfigController.getUserInfo();
        if (userInfo['success']) {
          setState(() {
            _connectionDetails = userInfo['data'];
          });
        }

        String successMessage;
        if (_apiConfigController.forceLiveApiMode) {
          successMessage =
              'Successfully connected to live ElevenLabs API (Force Live Mode)!';
        } else if (_useLiveApi) {
          successMessage = 'Successfully connected to live ElevenLabs API!';
        } else {
          successMessage =
              'Connected to Demo Mode - Enable "Force Live API" for production use';
        }

        if (_useLiveApi || _apiConfigController.forceLiveApiMode) {
          _showSuccessSnackBar(successMessage);
        } else {
          _showErrorSnackBar(successMessage);
        }
      }
    }
  }

  Future<void> _saveConfiguration() async {
    // Force live API if user is saving with real credentials
    if (_useLiveApi &&
        _apiKeyController.text.isNotEmpty &&
        _agentNumberController.text.isNotEmpty) {
      await _apiConfigController.forceLiveApi();
    }

    if (!_useLiveApi && !_apiConfigController.forceLiveApiMode) {
      // For mock mode, we can save without full validation
      await _apiConfigController.setUseMockServices(true);

      final newConfig = ElevenLabsConfig(
        apiKey: _apiKeyController.text.isEmpty
            ? 'mock_api_key'
            : _apiKeyController.text,
        agentNumber: _agentNumberController.text.isEmpty
            ? 'mock_agent'
            : _agentNumberController.text,
        selectedVoiceId: _selectedAgent,
        voiceModel: _selectedVoiceModel,
        responseSpeed: _responseSpeed,
        audioQuality: _audioQuality,
        isBiometricEnabled: _isBiometricEnabled,
      );

      final result = await _apiConfigController.saveConfiguration(newConfig);
      if (result) {
        setState(() {
          _hasUnsavedChanges = false;
        });
        _showErrorSnackBar(
            'Demo configuration saved - Enable "Force Live API" to use real ElevenLabs service');
      }
      return;
    }

    // For live API, perform full validation
    final apiKeyValidationError =
        ApiValidationUtils.validateElevenLabsApiKey(_apiKeyController.text);
    if (apiKeyValidationError != null) {
      _showErrorSnackBar('Cannot save: $apiKeyValidationError');
      return;
    }

    final agentNumberValidationError =
        ApiValidationUtils.validateAgentNumber(_agentNumberController.text);
    if (agentNumberValidationError != null) {
      _showErrorSnackBar('Cannot save: $agentNumberValidationError');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_apiConfigController.isConnected) {
      _showErrorSnackBar(
          'Please test the connection successfully before saving');
      return;
    }

    try {
      // Ensure we're using live API (or force mode is active)
      if (!_apiConfigController.forceLiveApiMode) {
        await _apiConfigController.setUseMockServices(false);
      }

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

        String successMessage = _apiConfigController.forceLiveApiMode
            ? 'Live API configuration saved successfully (Force Live Mode)!'
            : 'Live API configuration saved successfully!';
        _showSuccessSnackBar(successMessage);
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
                            color: AppTheme.warningLight.withAlpha(51),
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
                          // Replace the existing API Mode Selection section with this improved version
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
                                      'API Mode Configuration',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (apiConfigController.forceLiveApiMode)
                                      Container(
                                        margin: EdgeInsets.only(left: 2.w),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.w, vertical: 0.5.h),
                                        decoration: BoxDecoration(
                                          color: AppTheme.successLight
                                              .withAlpha(51),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'LIVE MODE',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.successLight,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 2.h),

                                // Force Live API Mode Toggle
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: apiConfigController.forceLiveApiMode
                                        ? AppTheme.successLight.withAlpha(26)
                                        : AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: apiConfigController
                                              .forceLiveApiMode
                                          ? AppTheme.successLight.withAlpha(77)
                                          : AppTheme.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      SwitchListTile(
                                        title: Text(
                                          'Force Live ElevenLabs API',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: apiConfigController
                                                    .forceLiveApiMode
                                                ? AppTheme.successLight
                                                : AppTheme.textPrimaryLight,
                                          ),
                                        ),
                                        subtitle: Text(
                                          apiConfigController.forceLiveApiMode
                                              ? 'App will ONLY use live ElevenLabs API - Demo mode disabled'
                                              : 'Enable to ensure production API usage and disable demo mode',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: apiConfigController
                                                    .forceLiveApiMode
                                                ? AppTheme.successLight
                                                : AppTheme.textSecondaryLight,
                                          ),
                                        ),
                                        value: apiConfigController
                                            .forceLiveApiMode,
                                        onChanged: (value) async {
                                          if (value) {
                                            await apiConfigController
                                                .enableForceLiveApiMode();
                                            _showSuccessSnackBar(
                                                'Force Live API Mode enabled - App will only use live ElevenLabs API');
                                          } else {
                                            await apiConfigController
                                                .disableForceLiveApiMode();
                                            _showErrorSnackBar(
                                                'Force Live API Mode disabled - Normal mode selection available');
                                          }
                                          setState(() {
                                            _useLiveApi = !apiConfigController
                                                .useMockServices;
                                            _hasUnsavedChanges = true;
                                          });
                                        },
                                        activeColor: AppTheme.successLight,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      if (apiConfigController.forceLiveApiMode)
                                        Container(
                                          margin: EdgeInsets.only(top: 1.h),
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successLight
                                                .withAlpha(26),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: AppTheme.successLight
                                                  .withAlpha(77),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CustomIconWidget(
                                                iconName: 'verified',
                                                color: AppTheme.successLight,
                                                size: 16,
                                              ),
                                              SizedBox(width: 2.w),
                                              Expanded(
                                                child: Text(
                                                  'Force Live API Mode is active. The app will only use the live ElevenLabs API with your credentials. Demo mode is completely disabled.',
                                                  style: AppTheme.lightTheme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color:
                                                        AppTheme.successLight,
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

                                // Regular API Mode Toggle (only show if force mode is disabled)
                                if (!apiConfigController.forceLiveApiMode) ...[
                                  SizedBox(height: 2.h),
                                  SwitchListTile(
                                    title: Text(
                                      'Use Live ElevenLabs API',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _useLiveApi
                                          ? 'Using live ElevenLabs API with your credentials'
                                          : 'Using mock API (Demo Mode) - Switch to Live API for production',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: _useLiveApi
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

                                      // Show information about the change
                                      if (value) {
                                        _showSuccessSnackBar(
                                            'Switched to Live API mode - Please configure your API credentials');
                                      } else {
                                        _showErrorSnackBar(
                                            'Switched to Demo Mode - This is for testing only');
                                      }
                                    },
                                    activeColor: AppTheme.primaryLight,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  if (!_useLiveApi)
                                    Container(
                                      margin: EdgeInsets.only(top: 1.h),
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.warningLight.withAlpha(26),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.warningLight
                                              .withAlpha(77),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'warning',
                                            color: AppTheme.warningLight,
                                            size: 16,
                                          ),
                                          SizedBox(width: 2.w),
                                          Expanded(
                                            child: Text(
                                              'Demo mode uses simulated responses and doesn\'t consume API credits. Switch to Live API or enable "Force Live API" for production use.',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
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

                                // Quick Action Buttons
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await apiConfigController
                                              .forceLiveApi();
                                          setState(() {
                                            _useLiveApi = true;
                                            _hasUnsavedChanges = true;
                                          });
                                          _showSuccessSnackBar(
                                              'Switched to Force Live API Mode - Demo mode disabled');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.successLight,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 1.h),
                                        ),
                                        icon: CustomIconWidget(
                                          iconName: 'verified',
                                          color: AppTheme.backgroundLight,
                                          size: 16,
                                        ),
                                        label: Text(
                                          'Force Live',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppTheme.backgroundLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            apiConfigController.forceLiveApiMode
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _useLiveApi = false;
                                                      _hasUnsavedChanges = true;
                                                    });
                                                    _showErrorSnackBar(
                                                        'Switched to Demo Mode - For testing only');
                                                  },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: apiConfigController
                                                    .forceLiveApiMode
                                                ? AppTheme.textSecondaryLight
                                                : AppTheme.warningLight,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 1.h),
                                        ),
                                        icon: CustomIconWidget(
                                          iconName: 'science',
                                          color: apiConfigController
                                                  .forceLiveApiMode
                                              ? AppTheme.textSecondaryLight
                                              : AppTheme.warningLight,
                                          size: 16,
                                        ),
                                        label: Text(
                                          'Demo Mode',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: apiConfigController
                                                    .forceLiveApiMode
                                                ? AppTheme.textSecondaryLight
                                                : AppTheme.warningLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                              onChanged: (_) => _onSettingChanged()),

                          SizedBox(height: 3.h),

                          // Agent Number Input Section
                          AgentNumberInputWidget(
                              controller: _agentNumberController,
                              onChanged: (_) => _onSettingChanged()),

                          SizedBox(height: 3.h),

                          // Connection Test Section - Update this call to include force live mode
                          ConnectionTestWidget(
                              isLoading: apiConfigController.isLoading,
                              connectionStatus:
                                  apiConfigController.connectionStatus,
                              isConnected: apiConfigController.isConnected,
                              connectionDetails: _connectionDetails,
                              forceLiveApiMode:
                                  apiConfigController.forceLiveApiMode,
                              onTestConnection: _testConnection),

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
                                  child: apiConfigController.isLoading
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
                        ]))),
          ),
        );
      },
    );
  }
}
