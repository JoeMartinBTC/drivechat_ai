import 'package:flutter/foundation.dart';

/// Mock service for ElevenLabs API for development and testing
class MockElevenLabsService {
  static final MockElevenLabsService _instance =
      MockElevenLabsService._internal();

  factory MockElevenLabsService() {
    return _instance;
  }

  MockElevenLabsService._internal();

  Future<bool> initialize() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<Map<String, dynamic>> testConnection() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return {
      'success': true,
      'message': 'Mock connection successful',
      'data': {
        'subscription': {
          'tier': 'pro',
          'character_count': 50000,
          'character_limit': 100000,
          'can_extend_character_limit': true,
          'allowed_to_extend_character_limit': true,
          'next_character_count_reset_unix': 1672531200,
          'status': 'active',
        },
        'is_new_user': false,
        'xi_api_key': 'MOCK_API_KEY',
        'can_use_delayed_payment_methods': true,
      },
    };
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'voice_id': 'voice_1',
        'name': 'German Instructor (Male)',
        'preview_url': '',
        'category': 'professional',
      },
      {
        'voice_id': 'voice_2',
        'name': 'German Instructor (Female)',
        'preview_url': '',
        'category': 'professional',
      },
      {
        'voice_id': 'voice_3',
        'name': 'Traffic Expert',
        'preview_url': '',
        'category': 'professional',
      },
    ];
  }

  Future<Map<String, dynamic>> textToSpeech(
    String text, {
    String? voiceId,
  }) async {
    try {
      if (kDebugMode) {
        print('Mock TTS: $text');
      }

      // Simulate processing delay based on text length
      final processingTime = Duration(milliseconds: 500 + (text.length * 10));
      await Future.delayed(processingTime);

      // For mock purposes, we'll just return a placeholder
      // In a real implementation, you would return actual audio data
      return {
        'success': true,
        'audioData': Uint8List(0), // Empty audio data for mock
        'message': 'Mock text-to-speech conversion successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Mock text-to-speech conversion failed: $e',
      };
    }
  }

  void updateConfiguration({
    String? apiKey,
    String? agentNumber,
    String? selectedVoiceId,
    String? selectedVoiceModel,
    double? responseSpeed,
    String? audioQuality,
  }) {
    // Just log the configuration update in debug mode
    if (kDebugMode) {
      print('Mock ElevenLabs config updated');
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return {
      'success': true,
      'data': {
        'subscription': {
          'tier': 'pro',
          'character_count': 50000,
          'character_limit': 100000,
          'status': 'active',
        },
      },
    };
  }

  Future<int> getRemainingCharacters() async {
    // Return a mock value
    return 50000;
  }
}
