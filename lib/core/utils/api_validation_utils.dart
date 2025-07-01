// lib/core/utils/api_validation_utils.dart
import 'package:flutter/foundation.dart';

class ApiValidationUtils {
  // ElevenLabs API Key Validation
  static String? validateElevenLabsApiKey(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ElevenLabs API key';
    }

    String cleanValue = value.replaceAll(RegExp(r'\s+'), '');

    // Check for correct sk_ prefix (underscore, not hyphen)
    if (!cleanValue.startsWith('sk_')) {
      if (cleanValue.startsWith('sk-')) {
        return 'ElevenLabs API key should start with "sk_" (underscore), not "sk-" (hyphen)';
      }
      return 'API key must start with "sk_" (underscore)';
    }

    if (cleanValue.length < 20) {
      return 'API key appears to be too short';
    }

    if (cleanValue.length > 100) {
      return 'API key appears to be too long';
    }

    // Additional format validation for ElevenLabs keys
    if (cleanValue.length < 32) {
      return 'ElevenLabs API key should be at least 32 characters long';
    }

    return null;
  }

  // ElevenLabs Agent Number Validation
  static String? validateAgentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ElevenLabs agent number';
    }

    // Ensure it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Agent number should contain only digits';
    }

    // Check reasonable length (adjust as needed based on actual ElevenLabs agent numbers)
    if (value.length < 3) {
      return 'Agent number appears to be too short';
    }

    if (value.length > 20) {
      return 'Agent number appears to be too long';
    }

    return null;
  }

  // Check if API key format is valid (boolean check)
  static bool isValidElevenLabsApiKey(String? value) {
    return validateElevenLabsApiKey(value) == null;
  }

  // Check if Agent number format is valid (boolean check)
  static bool isValidAgentNumber(String? value) {
    return validateAgentNumber(value) == null;
  }

  // Format API key for display (add spaces every 4 characters)
  static String formatApiKeyForDisplay(String value) {
    String cleaned = value.replaceAll(RegExp(r'\s+'), '');
    String formatted = '';

    for (int i = 0; i < cleaned.length; i += 4) {
      if (i > 0) formatted += ' ';
      formatted += cleaned.substring(
        i,
        (i + 4 < cleaned.length) ? i + 4 : cleaned.length,
      );
    }

    return formatted;
  }

  // Clean API key (remove spaces for API calls)
  static String cleanApiKey(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  // Check if key starts with the old incorrect format
  static bool hasIncorrectPrefix(String value) {
    String cleanValue = value.replaceAll(RegExp(r'\s+'), '');
    return cleanValue.startsWith('sk-');
  }

  // Get help text for API key format
  static String getApiKeyHelpText() {
    return 'ElevenLabs API keys start with "sk_" followed by alphanumeric characters. ';
  }

  // Debug logging for API key validation
  static void logValidationAttempt(String key, String? result) {
    if (kDebugMode) {
      String maskedKey = key.length > 8 ? '${key.substring(0, 8)}***' : '***';
      print(
        'API Key Validation - Key: $maskedKey, Result: ${result ?? "Valid"}',
      );
    }
  }
}
