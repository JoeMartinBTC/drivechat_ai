import 'package:flutter/foundation.dart';

import '../services/elevenlabs_service.dart';
import '../services/mock_elevenlabs_service.dart';
import './api_config_controller.dart';

/// Controller for handling audio processing with ElevenLabs API
class AudioController extends ChangeNotifier {
  final ElevenLabsService _elevenlabsService = ElevenLabsService();
  final MockElevenLabsService _mockElevenlabsService = MockElevenLabsService();
  final ApiConfigController _apiConfigController;

  bool _isProcessing = false;
  bool _isPlayingAudio = false;
  String _lastProcessedText = '';
  Uint8List? _lastAudioData;
  String _errorMessage = '';

  // Getters
  bool get isProcessing => _isProcessing;
  bool get isPlayingAudio => _isPlayingAudio;
  String get lastProcessedText => _lastProcessedText;
  Uint8List? get lastAudioData => _lastAudioData;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get useMockServices => _apiConfigController.useMockServices;

  AudioController(this._apiConfigController);

  /// Process text to speech with the ElevenLabs API
  Future<Map<String, dynamic>> processTextToSpeech(String text,
      {String? voiceId}) async {
    if (text.isEmpty) {
      return {
        'success': false,
        'message': 'Text cannot be empty',
      };
    }

    try {
      _isProcessing = true;
      _errorMessage = '';
      _lastProcessedText = text;
      notifyListeners();

      Map<String, dynamic> result;
      if (_apiConfigController.useMockServices) {
        if (kDebugMode) {
          print(
              'Warning: Using mock TTS service - Switch to Live API for production use');
        }
        result =
            await _mockElevenlabsService.textToSpeech(text, voiceId: voiceId);
        // Add a warning to the result when using mock services
        if (result['success']) {
          result['message'] =
              '${result['message']} (Mock Mode - Switch to Live API for production)';
        }
      } else {
        if (kDebugMode) {
          print('Using live ElevenLabs API for TTS');
        }
        result = await _elevenlabsService.textToSpeech(text, voiceId: voiceId);
      }

      if (result['success']) {
        _lastAudioData = result['audioData'];
        // In a real app, you would now play the audio data
        // This would involve using a plugin like just_audio or audioplayers

        if (kDebugMode && !_apiConfigController.useMockServices) {
          print('Successfully generated audio using live ElevenLabs API');
        }
      } else {
        _errorMessage = result['message'] ?? 'Text-to-speech conversion failed';

        // If using mock services and it fails, suggest switching to live API
        if (_apiConfigController.useMockServices) {
          _errorMessage +=
              ' (Consider switching to Live API for production use)';
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing text to speech: $e');
      }
      _errorMessage = 'Error processing text to speech: $e';

      // Provide helpful error message based on service type
      if (_apiConfigController.useMockServices) {
        _errorMessage +=
            ' (Currently using mock service - switch to Live API for production)';
      }

      return {
        'success': false,
        'message': _errorMessage,
      };
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Play the audio data (placeholder implementation)
  Future<void> playAudio() async {
    if (_lastAudioData == null || _lastAudioData!.isEmpty) {
      _errorMessage = 'No audio data available to play';
      notifyListeners();
      return;
    }

    try {
      _isPlayingAudio = true;
      notifyListeners();

      // Simulate audio playback with a delay based on text length
      // In a real app, you would use an audio plugin to play the actual data
      await Future.delayed(
          Duration(milliseconds: 500 + (_lastProcessedText.length * 30)));

      if (kDebugMode) {
        print('Playing audio for: $_lastProcessedText');
      }
    } catch (e) {
      _errorMessage = 'Error playing audio: $e';
    } finally {
      _isPlayingAudio = false;
      notifyListeners();
    }
  }

  /// Stop audio playback (placeholder implementation)
  void stopAudio() {
    _isPlayingAudio = false;
    notifyListeners();
  }

  /// Clear any stored audio data and error messages
  void clearAudioData() {
    _lastAudioData = null;
    _lastProcessedText = '';
    _errorMessage = '';
    notifyListeners();
  }
}
