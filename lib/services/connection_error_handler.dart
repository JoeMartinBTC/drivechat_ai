// lib/services/connection_error_handler.dart
import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Enum for different types of connection errors
enum ConnectionErrorType {
  networkUnavailable,
  timeout,
  serverError,
  unauthorized,
  quotaExceeded,
  rateLimited,
  apiKeyInvalid,
  dnsFailure,
  sslError,
  unknown,
}

/// Class to represent connection error details
class ConnectionErrorDetails {
  final ConnectionErrorType type;
  final String message;
  final String userFriendlyMessage;
  final String? technicalDetails;
  final bool canRetry;
  final Duration? retryAfter;
  final List<String> recoveryActions;

  const ConnectionErrorDetails({
    required this.type,
    required this.message,
    required this.userFriendlyMessage,
    this.technicalDetails,
    required this.canRetry,
    this.retryAfter,
    required this.recoveryActions,
  });
}

/// Service for handling connection errors and retry logic
class ConnectionErrorHandler {
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 2);
  final Connectivity _connectivity = Connectivity();

  // Singleton pattern
  static final ConnectionErrorHandler _instance =
      ConnectionErrorHandler._internal();
  factory ConnectionErrorHandler() => _instance;
  ConnectionErrorHandler._internal();

  /// Check if device has network connectivity
  Future<bool> hasNetworkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Parse DioException and return structured error details
  ConnectionErrorDetails parseConnectionError(dynamic error) {
    if (error is DioException) {
      return _parseDioException(error);
    } else if (error is TimeoutException) {
      return ConnectionErrorDetails(
        type: ConnectionErrorType.timeout,
        message: 'Connection timeout',
        userFriendlyMessage:
            'Die Verbindung ist zu langsam. Versuchen Sie es erneut.',
        canRetry: true,
        recoveryActions: [
          'Überprüfen Sie Ihre Internetverbindung',
          'Versuchen Sie es in einem anderen Netzwerk',
          'Warten Sie einen Moment und versuchen Sie es erneut',
        ],
      );
    } else {
      return ConnectionErrorDetails(
        type: ConnectionErrorType.unknown,
        message: error.toString(),
        userFriendlyMessage: 'Ein unbekannter Fehler ist aufgetreten.',
        technicalDetails: error.toString(),
        canRetry: true,
        recoveryActions: [
          'Versuchen Sie es erneut',
          'Starten Sie die App neu',
          'Überprüfen Sie Ihre Internetverbindung',
        ],
      );
    }
  }

  /// Parse DioException into structured error details
  ConnectionErrorDetails _parseDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.timeout,
          message: 'Connection timeout: ${dioError.message}',
          userFriendlyMessage: 'Die Verbindung zur API ist zu langsam.',
          technicalDetails: dioError.message,
          canRetry: true,
          recoveryActions: [
            'Überprüfen Sie Ihre Internetgeschwindigkeit',
            'Versuchen Sie es mit einer stabileren Verbindung',
            'Warten Sie einen Moment und versuchen Sie es erneut',
          ],
        );

      case DioExceptionType.connectionError:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.networkUnavailable,
          message: 'Network connection error: ${dioError.message}',
          userFriendlyMessage: 'Keine Internetverbindung verfügbar.',
          technicalDetails: dioError.message,
          canRetry: true,
          recoveryActions: [
            'Überprüfen Sie Ihre WLAN- oder Mobilfunkverbindung',
            'Versuchen Sie es mit einem anderen Netzwerk',
            'Starten Sie Ihre Internetverbindung neu',
          ],
        );

      case DioExceptionType.badResponse:
        return _parseHttpStatusError(dioError);

      case DioExceptionType.unknown:
        if (dioError.message?.contains('SocketException') == true) {
          return ConnectionErrorDetails(
            type: ConnectionErrorType.dnsFailure,
            message: 'DNS resolution failed: ${dioError.message}',
            userFriendlyMessage: 'Serveradresse konnte nicht aufgelöst werden.',
            technicalDetails: dioError.message,
            canRetry: true,
            recoveryActions: [
              'Überprüfen Sie Ihre DNS-Einstellungen',
              'Versuchen Sie es mit einem anderen Netzwerk',
              'Kontaktieren Sie Ihren Internetanbieter',
            ],
          );
        }
        return ConnectionErrorDetails(
          type: ConnectionErrorType.unknown,
          message: 'Unknown error: ${dioError.message}',
          userFriendlyMessage:
              'Ein unbekannter Verbindungsfehler ist aufgetreten.',
          technicalDetails: dioError.message,
          canRetry: true,
          recoveryActions: [
            'Versuchen Sie es erneut',
            'Überprüfen Sie Ihre Internetverbindung',
            'Starten Sie die App neu',
          ],
        );

      default:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.unknown,
          message: 'Unexpected error: ${dioError.message}',
          userFriendlyMessage: 'Ein unerwarteter Fehler ist aufgetreten.',
          technicalDetails: dioError.message,
          canRetry: true,
          recoveryActions: [
            'Versuchen Sie es erneut',
            'Starten Sie die App neu',
          ],
        );
    }
  }

  /// Parse HTTP status code errors
  ConnectionErrorDetails _parseHttpStatusError(DioException dioError) {
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;

    switch (statusCode) {
      case 401:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.unauthorized,
          message: 'Unauthorized: Invalid API key',
          userFriendlyMessage:
              'Ihr API-Schlüssel ist ungültig oder abgelaufen.',
          technicalDetails: responseData?.toString(),
          canRetry: false,
          recoveryActions: [
            'Überprüfen Sie Ihren ElevenLabs API-Schlüssel',
            'Generieren Sie einen neuen API-Schlüssel',
            'Stellen Sie sicher, dass Ihr Account aktiv ist',
          ],
        );

      case 402:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.quotaExceeded,
          message: 'Payment required: Quota exceeded',
          userFriendlyMessage: 'Ihr API-Kontingent ist aufgebraucht.',
          technicalDetails: responseData?.toString(),
          canRetry: false,
          recoveryActions: [
            'Überprüfen Sie Ihr ElevenLabs Kontingent',
            'Upgraden Sie Ihren Plan',
            'Warten Sie bis zur nächsten Kontingent-Erneuerung',
          ],
        );

      case 429:
        final retryAfter = _extractRetryAfterFromHeaders(
          dioError.response?.headers,
        );
        return ConnectionErrorDetails(
          type: ConnectionErrorType.rateLimited,
          message: 'Rate limit exceeded',
          userFriendlyMessage:
              'Zu viele Anfragen. Bitte warten Sie einen Moment.',
          technicalDetails: responseData?.toString(),
          canRetry: true,
          retryAfter: retryAfter,
          recoveryActions: [
            'Warten Sie ${retryAfter?.inSeconds ?? 60} Sekunden',
            'Reduzieren Sie die Häufigkeit Ihrer Anfragen',
            'Versuchen Sie es später erneut',
          ],
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.serverError,
          message: 'Server error: $statusCode',
          userFriendlyMessage:
              'Der ElevenLabs Server ist derzeit nicht verfügbar.',
          technicalDetails: responseData?.toString(),
          canRetry: true,
          recoveryActions: [
            'Versuchen Sie es in ein paar Minuten erneut',
            'Überprüfen Sie den ElevenLabs Status',
            'Kontaktieren Sie den ElevenLabs Support falls das Problem bestehen bleibt',
          ],
        );

      default:
        return ConnectionErrorDetails(
          type: ConnectionErrorType.unknown,
          message: 'HTTP error: $statusCode',
          userFriendlyMessage:
              'Ein Serverfehler ist aufgetreten ($statusCode).',
          technicalDetails: responseData?.toString(),
          canRetry: true,
          recoveryActions: [
            'Versuchen Sie es erneut',
            'Überprüfen Sie Ihre API-Konfiguration',
            'Kontaktieren Sie den Support falls das Problem bestehen bleibt',
          ],
        );
    }
  }

  /// Extract retry-after duration from response headers
  Duration? _extractRetryAfterFromHeaders(Headers? headers) {
    if (headers == null) return null;

    final retryAfterHeader = headers.value('retry-after');
    if (retryAfterHeader != null) {
      final seconds = int.tryParse(retryAfterHeader);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }

    return const Duration(seconds: 60); // Default retry after 60 seconds
  }

  /// Execute a function with retry logic and exponential backoff
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration baseDelay = _baseDelay,
    bool Function(ConnectionErrorDetails error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = baseDelay;

    while (attempt <= maxRetries) {
      try {
        // Check network connectivity before attempting
        if (!await hasNetworkConnection()) {
          throw ConnectionErrorDetails(
            type: ConnectionErrorType.networkUnavailable,
            message: 'No network connection',
            userFriendlyMessage: 'Keine Internetverbindung verfügbar.',
            canRetry: true,
            recoveryActions: [
              'Überprüfen Sie Ihre Internetverbindung',
              'Versuchen Sie es mit einem anderen Netzwerk',
            ],
          );
        }

        return await operation();
      } catch (error) {
        final errorDetails = parseConnectionError(error);

        if (kDebugMode) {
          print('Attempt ${attempt + 1} failed: ${errorDetails.message}');
        }

        // Check if we should retry
        final customShouldRetry = shouldRetry?.call(errorDetails);
        final shouldRetryDefault =
            errorDetails.canRetry && attempt < maxRetries;

        if ((customShouldRetry ?? shouldRetryDefault)) {
          attempt++;

          // Use custom retry delay if specified, otherwise use exponential backoff
          final waitTime = errorDetails.retryAfter ?? delay;

          if (kDebugMode) {
            print(
              'Retrying in ${waitTime.inSeconds} seconds (attempt $attempt/$maxRetries)',
            );
          }

          await Future.delayed(waitTime);

          // Exponential backoff for next attempt
          delay = Duration(seconds: min(delay.inSeconds * 2, 30));
        } else {
          // No more retries or shouldn't retry
          throw errorDetails;
        }
      }
    }

    // This should never be reached, but just in case
    throw ConnectionErrorDetails(
      type: ConnectionErrorType.unknown,
      message: 'Max retries exceeded',
      userFriendlyMessage:
          'Maximale Anzahl von Wiederholungsversuchen erreicht.',
      canRetry: false,
      recoveryActions: [
        'Überprüfen Sie Ihre Internetverbindung',
        'Versuchen Sie es später erneut',
        'Kontaktieren Sie den Support',
      ],
    );
  }

  /// Get user-friendly error message for display
  String getUserFriendlyMessage(dynamic error) {
    final errorDetails = parseConnectionError(error);
    return errorDetails.userFriendlyMessage;
  }

  /// Check if an error is recoverable
  bool isRecoverableError(dynamic error) {
    final errorDetails = parseConnectionError(error);
    return errorDetails.canRetry;
  }

  /// Get recovery actions for an error
  List<String> getRecoveryActions(dynamic error) {
    final errorDetails = parseConnectionError(error);
    return errorDetails.recoveryActions;
  }
}
