/// Configuration model for ElevenLabs API settings
class ElevenLabsConfig {
  final String apiKey;
  final String agentNumber;
  final String? selectedVoiceId;
  final String voiceModel;
  final double responseSpeed;
  final String audioQuality;
  final bool isBiometricEnabled;

  const ElevenLabsConfig({
    required this.apiKey,
    required this.agentNumber,
    this.selectedVoiceId,
    this.voiceModel = 'eleven_multilingual_v2',
    this.responseSpeed = 0.5,
    this.audioQuality = 'high',
    this.isBiometricEnabled = false,
  });

  /// Create a config from shared preferences data
  factory ElevenLabsConfig.fromPrefs(Map<String, dynamic> prefs) {
    return ElevenLabsConfig(
      apiKey: prefs['elevenlabs_api_key'] ?? '',
      agentNumber: prefs['elevenlabs_agent_number'] ?? '',
      selectedVoiceId: prefs['selected_agent'],
      voiceModel: prefs['voice_model'] ?? 'eleven_multilingual_v2',
      responseSpeed: prefs['response_speed'] ?? 0.5,
      audioQuality: prefs['audio_quality'] ?? 'high',
      isBiometricEnabled: prefs['biometric_enabled'] ?? false,
    );
  }

  /// Convert config to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'elevenlabs_api_key': apiKey,
      'elevenlabs_agent_number': agentNumber,
      'selected_agent': selectedVoiceId,
      'voice_model': voiceModel,
      'response_speed': responseSpeed,
      'audio_quality': audioQuality,
      'biometric_enabled': isBiometricEnabled,
    };
  }

  /// Create a copy of this config with some fields replaced
  ElevenLabsConfig copyWith({
    String? apiKey,
    String? agentNumber,
    String? selectedVoiceId,
    String? voiceModel,
    double? responseSpeed,
    String? audioQuality,
    bool? isBiometricEnabled,
  }) {
    return ElevenLabsConfig(
      apiKey: apiKey ?? this.apiKey,
      agentNumber: agentNumber ?? this.agentNumber,
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      voiceModel: voiceModel ?? this.voiceModel,
      responseSpeed: responseSpeed ?? this.responseSpeed,
      audioQuality: audioQuality ?? this.audioQuality,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  /// Check if the config has valid API credentials
  bool get hasValidCredentials => apiKey.isNotEmpty && agentNumber.isNotEmpty;

  /// Check if a voice is selected
  bool get hasSelectedVoice =>
      selectedVoiceId != null && selectedVoiceId!.isNotEmpty;
}
