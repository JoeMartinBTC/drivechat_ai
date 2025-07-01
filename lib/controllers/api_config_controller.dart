import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/elevenlabs_service.dart';
import '../services/mock_elevenlabs_service.dart';
import '../models/elevenlabs_config.dart';
import '../core/utils/api_validation_utils.dart';

/// Controller for managing API configuration and connectivity
class ApiConfigController extends ChangeNotifier {
  // Services
  final ElevenLabsService _elevenlabsService = ElevenLabsService();
  final MockElevenLabsService _mockElevenlabsService = MockElevenLabsService();

  // Configuration
  late ElevenLabsConfig _config;
  bool _isInitialized = false;
  bool _isConnected = false;
  bool _isLoading = false;
  String _connectionStatus = 'Not tested';
  bool _useMockServices = false; // Set to false to use real API

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get connectionStatus => _connectionStatus;
  ElevenLabsConfig get config => _config;
  bool get useMockServices => _useMockServices;

  // Constructor
  ApiConfigController() {
    _initialize();
  }

  /// Initialize the controller and load saved configuration
  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Load configuration from SharedPreferences
      final Map<String, dynamic> prefsMap = {
        'elevenlabs_api_key': prefs.getString('elevenlabs_api_key') ?? '',
        'elevenlabs_agent_number':
            prefs.getString('elevenlabs_agent_number') ?? '',
        'selected_agent': prefs.getString('selected_agent'),
        'voice_model':
            prefs.getString('voice_model') ?? 'eleven_multilingual_v2',
        'response_speed': prefs.getDouble('response_speed') ?? 0.5,
        'audio_quality': prefs.getString('audio_quality') ?? 'high',
        'biometric_enabled': prefs.getBool('biometric_enabled') ?? false,
      };

      _config = ElevenLabsConfig.fromPrefs(prefsMap);

      // Initialize services
      if (_useMockServices) {
        await _mockElevenlabsService.initialize();
        _isConnected = true;
      } else if (_config.hasValidCredentials) {
        // Initialize the real service if credentials exist
        _isConnected = await _elevenlabsService.initialize();

        // If initialized, test the connection
        if (_isConnected) {
          await testConnection();
        }
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing API config controller: $e');
      }
      _isConnected = false;
      _connectionStatus = 'Initialization error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set whether to use mock services (for development and testing)
  void setUseMockServices(bool useMock) {
    _useMockServices = useMock;
    notifyListeners();
    _initialize(); // Re-initialize with the new setting
  }

  /// Test the connection to the ElevenLabs API
  Future<bool> testConnection() async {
    if (_config.apiKey.isEmpty) {
      _connectionStatus = 'API key is empty';
      _isConnected = false;
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _connectionStatus = 'Testing...';
      notifyListeners();

      Map<String, dynamic> result;
      if (_useMockServices) {
        result = await _mockElevenlabsService.testConnection();
      } else {
        // Update service configuration with latest values
        _elevenlabsService.updateConfiguration(
          apiKey: _config.apiKey,
          agentNumber: _config.agentNumber,
          selectedVoiceId: _config.selectedVoiceId,
          selectedVoiceModel: _config.voiceModel,
          responseSpeed: _config.responseSpeed,
          audioQuality: _config.audioQuality,
        );

        result = await _elevenlabsService.testConnection();
      }

      _isConnected = result['success'] == true;
      _connectionStatus =
          result['message'] ??
          (_isConnected ? 'Connection successful' : 'Connection failed');

      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _connectionStatus = 'Connection error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save the current configuration
  Future<bool> saveConfiguration(ElevenLabsConfig newConfig) async {
    try {
      // Validate API key format
      final apiKeyValidationError = ApiValidationUtils.validateElevenLabsApiKey(
        newConfig.apiKey,
      );
      if (apiKeyValidationError != null) {
        _connectionStatus = 'Invalid API key: $apiKeyValidationError';
        notifyListeners();
        return false;
      }

      // Validate agent number format
      final agentNumberValidationError = ApiValidationUtils.validateAgentNumber(
        newConfig.agentNumber,
      );
      if (agentNumberValidationError != null) {
        _connectionStatus = 'Invalid agent number: $agentNumberValidationError';
        notifyListeners();
        return false;
      }

      // Update configuration
      _config = newConfig;

      // Test connection with new configuration
      final connectionSuccessful = await testConnection();
      if (!connectionSuccessful) {
        return false;
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> configMap = _config.toMap();

      for (final entry in configMap.entries) {
        if (entry.value is String) {
          await prefs.setString(entry.key, entry.value as String);
        } else if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value as bool);
        } else if (entry.value is double) {
          await prefs.setDouble(entry.key, entry.value as double);
        } else if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value as int);
        }
      }

      // Update service configuration
      if (_useMockServices) {
        _mockElevenlabsService.updateConfiguration(
          apiKey: _config.apiKey,
          agentNumber: _config.agentNumber,
          selectedVoiceId: _config.selectedVoiceId,
          selectedVoiceModel: _config.voiceModel,
          responseSpeed: _config.responseSpeed,
          audioQuality: _config.audioQuality,
        );
      } else {
        _elevenlabsService.updateConfiguration(
          apiKey: _config.apiKey,
          agentNumber: _config.agentNumber,
          selectedVoiceId: _config.selectedVoiceId,
          selectedVoiceModel: _config.voiceModel,
          responseSpeed: _config.responseSpeed,
          audioQuality: _config.audioQuality,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving configuration: $e');
      }
      return false;
    }
  }

  /// Reset the configuration to default values
  Future<bool> resetConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only clear API-related settings
      await prefs.remove('elevenlabs_api_key');
      await prefs.remove('elevenlabs_agent_number');
      await prefs.remove('selected_agent');
      await prefs.remove('voice_model');
      await prefs.remove('response_speed');
      await prefs.remove('audio_quality');
      await prefs.remove('biometric_enabled');

      // Reset local config
      _config = const ElevenLabsConfig(apiKey: '', agentNumber: '');

      _isConnected = false;
      _connectionStatus = 'Not tested';

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting configuration: $e');
      }
      return false;
    }
  }

  /// Get available voices from the ElevenLabs API
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      if (_useMockServices) {
        return await _mockElevenlabsService.getVoices();
      } else {
        return await _elevenlabsService.getVoices();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available voices: $e');
      }
      return [];
    }
  }

  /// Get user information from the ElevenLabs API
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      if (_useMockServices) {
        return await _mockElevenlabsService.getUserInfo();
      } else {
        return await _elevenlabsService.getUserInfo();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user info: $e');
      }
      return {'success': false, 'message': 'Failed to get user info: $e'};
    }
  }

  /// Get remaining character quota
  Future<int> getRemainingCharacters() async {
    try {
      if (_useMockServices) {
        return await _mockElevenlabsService.getRemainingCharacters();
      } else {
        return await _elevenlabsService.getRemainingCharacters();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting remaining characters: $e');
      }
      return 0;
    }
  }
}
