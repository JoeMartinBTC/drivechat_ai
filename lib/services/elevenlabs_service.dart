import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for interacting with the ElevenLabs API
class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  final Dio _dio = Dio();
  late String _apiKey;
  late String _agentNumber;
  String? _selectedVoiceId;
  String _selectedVoiceModel = 'eleven_multilingual_v2';
  double _responseSpeed = 0.5;
  String _audioQuality = 'high';

  // Singleton pattern
  static final ElevenLabsService _instance = ElevenLabsService._internal();

  factory ElevenLabsService() {
    return _instance;
  }

  ElevenLabsService._internal();

  /// Initialize the service with stored credentials
  Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString('elevenlabs_api_key') ?? '';
      _agentNumber = prefs.getString('elevenlabs_agent_number') ?? '';
      _selectedVoiceId = prefs.getString('selected_agent');
      _selectedVoiceModel =
          prefs.getString('voice_model') ?? 'eleven_multilingual_v2';
      _responseSpeed = prefs.getDouble('response_speed') ?? 0.5;
      _audioQuality = prefs.getString('audio_quality') ?? 'high';

      _setupDioInterceptors();

      return _apiKey.isNotEmpty && _agentNumber.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize ElevenLabs service: $e');
      }
      return false;
    }
  }

  /// Set up Dio interceptors for authentication and error handling
  void _setupDioInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['xi-api-key'] = _apiKey;
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('API Error: ${e.message}');
          if (e.response != null) {
            print('Status code: ${e.response?.statusCode}');
            print('Response data: ${e.response?.data}');
          }
        }
        return handler.next(e);
      },
    ));
  }

  /// Test the connection to the ElevenLabs API
  Future<Map<String, dynamic>> testConnection() async {
    try {
      if (_apiKey.isEmpty) {
        return {
          'success': false,
          'message': 'API key is empty',
        };
      }

      // Get user information to verify API key
      final response = await _dio.get('$_baseUrl/user');

      return {
        'success': true,
        'message': 'Connection successful',
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: ${e.message}',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  /// Get available voices from the API
  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final response = await _dio.get('$_baseUrl/voices');
      final List<dynamic> voicesData = response.data['voices'] ?? [];
      return voicesData.map((voice) => voice as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get voices: $e');
      }
      return [];
    }
  }

  /// Convert text to speech
  Future<Map<String, dynamic>> textToSpeech(String text,
      {String? voiceId}) async {
    try {
      final usedVoiceId = voiceId ?? _selectedVoiceId ?? 'default';

      // Voice settings based on the selected parameters
      final Map<String, dynamic> voiceSettings = {
        'stability': 0.5,
        'similarity_boost': 0.8,
        'style': 0.0,
        'use_speaker_boost': true,
      };

      // Model settings
      final Map<String, dynamic> modelSettings = {
        'model_id': _selectedVoiceModel,
      };

      // Adjust speed settings
      if (_responseSpeed != 0.5) {
        modelSettings['speed'] = _responseSpeed;
      }

      // Create the request payload
      final Map<String, dynamic> payload = {
        'text': text,
        'model_id': _selectedVoiceModel,
        'voice_settings': voiceSettings,
      };

      // Add model settings if needed
      if (modelSettings.length > 1) {
        payload['model_settings'] = modelSettings;
      }

      // Set response type to arraybuffer to get binary data
      final options = Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'audio/mpeg',
        },
      );

      final response = await _dio.post(
        '$_baseUrl/text-to-speech/$usedVoiceId',
        data: jsonEncode(payload),
        options: options,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'audioData': response.data,
          'message': 'Text-to-speech conversion successful',
        };
      } else {
        return {
          'success': false,
          'message':
              'Text-to-speech conversion failed with status ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Text-to-speech conversion failed: ${e.message}',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Text-to-speech conversion failed: $e',
      };
    }
  }

  /// Update service configuration
  void updateConfiguration({
    String? apiKey,
    String? agentNumber,
    String? selectedVoiceId,
    String? selectedVoiceModel,
    double? responseSpeed,
    String? audioQuality,
  }) {
    if (apiKey != null) _apiKey = apiKey;
    if (agentNumber != null) _agentNumber = agentNumber;
    if (selectedVoiceId != null) _selectedVoiceId = selectedVoiceId;
    if (selectedVoiceModel != null) _selectedVoiceModel = selectedVoiceModel;
    if (responseSpeed != null) _responseSpeed = responseSpeed;
    if (audioQuality != null) _audioQuality = audioQuality;

    // Update interceptors with new API key
    _setupDioInterceptors();
  }

  /// Get user account information
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get('$_baseUrl/user');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user info: $e');
      }
      return {
        'success': false,
        'message': 'Failed to get user info: $e',
      };
    }
  }

  /// Get remaining character quota
  Future<int> getRemainingCharacters() async {
    try {
      final userInfo = await getUserInfo();
      if (userInfo['success']) {
        return userInfo['data']['subscription']['character_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
