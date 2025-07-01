// lib/services/debug_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring and debugging API traffic and message flow
class DebugService {
  static final DebugService _instance = DebugService._internal();
  factory DebugService() => _instance;
  DebugService._internal();

  bool _isDebugEnabled = false;
  final List<Map<String, dynamic>> _apiLogs = [];
  final List<Map<String, dynamic>> _messageLogs = [];
  final List<Map<String, dynamic>> _networkLogs = [];
  bool _isMobile = false;

  bool get isDebugEnabled => _isDebugEnabled;
  List<Map<String, dynamic>> get apiLogs => List.unmodifiable(_apiLogs);
  List<Map<String, dynamic>> get messageLogs => List.unmodifiable(_messageLogs);
  List<Map<String, dynamic>> get networkLogs => List.unmodifiable(_networkLogs);
  bool get isMobile => _isMobile;

  /// Initialize debug service and load settings
  Future<void> initialize() async {
    try {
      _isMobile = Platform.isAndroid || Platform.isIOS;
      final prefs = await SharedPreferences.getInstance();
      _isDebugEnabled = prefs.getBool('debug_enabled') ?? kDebugMode;

      if (_isDebugEnabled && _isMobile) {
        _logNetworkInfo('Debug service initialized on mobile platform');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize debug service: $e');
      }
    }
  }

  /// Enable or disable debug mode
  Future<void> setDebugEnabled(bool enabled) async {
    _isDebugEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('debug_enabled', enabled);

      if (_isDebugEnabled && _isMobile) {
        _logNetworkInfo(
          'Debug mode ${enabled ? "enabled" : "disabled"} on mobile',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save debug setting: $e');
      }
    }
  }

  /// Log network connectivity information (mobile-specific)
  Future<void> _logNetworkInfo(String event) async {
    if (!_isDebugEnabled || !_isMobile) return;

    try {
      final connectivity = Connectivity();
      final connectivityResults = await connectivity.checkConnectivity();

      // Handle both single result and list of results for backward compatibility
      List<ConnectivityResult> resultsList;
      if (connectivityResults is List<ConnectivityResult>) {
        resultsList = [connectivityResults];
      } else {
        resultsList = [connectivityResults];
      }

      final networkLogEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'event': event,
        'timestamp': DateTime.now().toIso8601String(),
        'connectivityResult': resultsList.map((e) => e.toString()).toList(),
        'platform': 'mobile',
        'operatingSystem': Platform.operatingSystem,
      };

      _networkLogs.add(networkLogEntry);

      // Keep only last 50 network logs
      if (_networkLogs.length > 50) {
        _networkLogs.removeAt(0);
      }

      if (kDebugMode) {
        print('📱 Network Info: $event - Connectivity: $resultsList');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log network info: $e');
      }
    }
  }

  /// Log API request and response with enhanced mobile and 401 error tracking
  void logApiCall({
    required String endpoint,
    required String method,
    required Map<String, dynamic> requestData,
    required Map<String, dynamic> response,
    required DateTime timestamp,
    required Duration duration,
    String? error,
    int? statusCode,
    Map<String, dynamic>? errorDetails,
  }) {
    if (!_isDebugEnabled) return;

    final logEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'endpoint': endpoint,
      'method': method,
      'requestData': requestData,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inMilliseconds,
      'success': error == null && (statusCode == null || statusCode == 200),
      'error': error,
      'statusCode': statusCode,
      'errorDetails': errorDetails,
      'isAuthError': statusCode == 401,
      'platform': _isMobile ? 'mobile' : 'desktop',
      'isMobileError': _isMobile && error != null,
    };

    _apiLogs.add(logEntry);

    // Keep only last 100 API logs
    if (_apiLogs.length > 100) {
      _apiLogs.removeAt(0);
    }

    if (kDebugMode) {
      print(
        '${_isMobile ? "📱" : "💻"} API Call: ${logEntry['method']} ${logEntry['endpoint']}',
      );
      print('Platform: ${_isMobile ? "Mobile" : "Desktop"}');
      print('Duration: ${logEntry['duration']}ms');
      if (statusCode != null) {
        print('Status Code: $statusCode');
      }
      if (error != null) {
        print('❌ Error: $error');
        if (statusCode == 401) {
          print('🔐 AUTHENTICATION ERROR - This is likely an API key issue');
          if (_isMobile) {
            print(
              '📱 MOBILE AUTHENTICATION ERROR - Check mobile network and API key',
            );
          }
          if (errorDetails != null) {
            print('Error Details: $errorDetails');
          }
        } else if (_isMobile && (statusCode == null || statusCode >= 500)) {
          print('📱 MOBILE NETWORK ERROR - Possible connectivity issue');
        }
      } else {
        print('✅ Success: ${response['success'] ?? 'Unknown'}');
      }
    }

    // Log network info if this is a mobile error
    if (_isMobile && error != null) {
      _logNetworkInfo('API call failed: $method $endpoint - $error');
    }
  }

  /// Log message processing (text/audio)
  void logMessage({
    required String messageId,
    required String text,
    required bool isUser,
    required DateTime timestamp,
    bool hasAudio = false,
    Map<String, dynamic>? audioInfo,
    String? processingError,
  }) {
    if (!_isDebugEnabled) return;

    final logEntry = {
      'messageId': messageId,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'hasAudio': hasAudio,
      'audioInfo': audioInfo,
      'processingError': processingError,
      'textLength': text.length,
      'platform': _isMobile ? 'mobile' : 'desktop',
    };

    _messageLogs.add(logEntry);

    // Keep only last 50 message logs
    if (_messageLogs.length > 50) {
      _messageLogs.removeAt(0);
    }

    if (kDebugMode) {
      print(
        '${_isMobile ? "📱" : "💻"} Message Logged: ${isUser ? "User" : "AI"} - ${text.substring(0, text.length > 50 ? 50 : text.length)}${text.length > 50 ? "..." : ""}',
      );
      if (hasAudio && audioInfo != null) {
        print('🔊 Audio Info: $audioInfo');
      }
      if (processingError != null) {
        print('❌ Processing Error: $processingError');
        if (_isMobile) {
          print('📱 Mobile Processing Error Detected');
        }
      }
    }
  }

  /// Clear all logs
  void clearLogs() {
    _apiLogs.clear();
    _messageLogs.clear();
    _networkLogs.clear();
    if (kDebugMode) {
      print('${_isMobile ? "📱" : "💻"} Debug logs cleared');
    }
  }

  /// Get debug summary with enhanced mobile and 401 error tracking
  Map<String, dynamic> getDebugSummary() {
    final successfulApiCalls =
        _apiLogs.where((log) => log['success'] == true).length;
    final failedApiCalls = _apiLogs.length - successfulApiCalls;
    final authErrors =
        _apiLogs.where((log) => log['isAuthError'] == true).length;
    final mobileErrors =
        _apiLogs.where((log) => log['isMobileError'] == true).length;
    final userMessages =
        _messageLogs.where((log) => log['isUser'] == true).length;
    final aiMessages = _messageLogs.length - userMessages;
    final messagesWithAudio =
        _messageLogs.where((log) => log['hasAudio'] == true).length;

    return {
      'debugEnabled': _isDebugEnabled,
      'platform': _isMobile ? 'mobile' : 'desktop',
      'isMobile': _isMobile,
      'totalApiCalls': _apiLogs.length,
      'successfulApiCalls': successfulApiCalls,
      'failedApiCalls': failedApiCalls,
      'authenticationErrors': authErrors,
      'mobileErrors': mobileErrors,
      'totalMessages': _messageLogs.length,
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'messagesWithAudio': messagesWithAudio,
      'networkLogs': _networkLogs.length,
      'averageApiDuration':
          _apiLogs.isNotEmpty
              ? _apiLogs
                      .map((log) => log['duration'] as int)
                      .reduce((a, b) => a + b) /
                  _apiLogs.length
              : 0,
      'lastAuthError':
          authErrors > 0
              ? _apiLogs.lastWhere((log) => log['isAuthError'] == true)
              : null,
      'lastMobileError':
          mobileErrors > 0
              ? _apiLogs.lastWhere((log) => log['isMobileError'] == true)
              : null,
    };
  }

  /// Get recent authentication errors for troubleshooting
  List<Map<String, dynamic>> getRecentAuthErrors({int limit = 5}) {
    return _apiLogs
        .where((log) => log['isAuthError'] == true)
        .take(limit)
        .toList();
  }

  /// Get recent mobile-specific errors
  List<Map<String, dynamic>> getRecentMobileErrors({int limit = 5}) {
    return _apiLogs
        .where((log) => log['isMobileError'] == true)
        .take(limit)
        .toList();
  }

  /// Check if there are recent authentication failures
  bool hasRecentAuthFailures({Duration within = const Duration(minutes: 5)}) {
    final cutoff = DateTime.now().subtract(within);
    return _apiLogs.any(
      (log) =>
          log['isAuthError'] == true &&
          DateTime.parse(log['timestamp']).isAfter(cutoff),
    );
  }

  /// Check if there are recent mobile-specific failures
  bool hasRecentMobileFailures({Duration within = const Duration(minutes: 5)}) {
    final cutoff = DateTime.now().subtract(within);
    return _apiLogs.any(
      (log) =>
          log['isMobileError'] == true &&
          DateTime.parse(log['timestamp']).isAfter(cutoff),
    );
  }

  /// Export logs as formatted string with mobile-specific information
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== GetMyLappen Debug Logs ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Platform: ${_isMobile ? "Mobile" : "Desktop"}');
    buffer.writeln('Operating System: ${Platform.operatingSystem}');
    buffer.writeln('Debug Enabled: $_isDebugEnabled');
    buffer.writeln('');

    if (_isMobile && _networkLogs.isNotEmpty) {
      buffer.writeln('=== Network Logs (${_networkLogs.length}) ===');
      for (final log in _networkLogs) {
        buffer.writeln(
          '${log['timestamp']}: ${log['event']} - ${log['connectivityResult']}',
        );
      }
      buffer.writeln('');
    }

    buffer.writeln('=== API Logs (${_apiLogs.length}) ===');
    for (final log in _apiLogs) {
      buffer.writeln(
        '${log['timestamp']}: ${log['method']} ${log['endpoint']} - ${log['duration']}ms [${log['platform']}]',
      );
      if (log['error'] != null) {
        buffer.writeln('  Error: ${log['error']}');
        if (log['isAuthError'] == true) {
          buffer.writeln('  🔐 Authentication Error');
        }
        if (log['isMobileError'] == true) {
          buffer.writeln('  📱 Mobile-specific Error');
        }
      }
    }

    buffer.writeln('');
    buffer.writeln('=== Message Logs (${_messageLogs.length}) ===');
    for (final log in _messageLogs) {
      buffer.writeln(
        '${log['timestamp']}: ${log['isUser'] ? "User" : "AI"} - ${log['text']} [${log['platform']}]',
      );
      if (log['hasAudio']) {
        buffer.writeln('  Audio: ${log['audioInfo']}');
      }
      if (log['processingError'] != null) {
        buffer.writeln('  Error: ${log['processingError']}');
      }
    }

    return buffer.toString();
  }

  /// Get mobile-specific diagnostics
  Map<String, dynamic> getMobileDiagnostics() {
    if (!_isMobile) {
      return {'isMobile': false, 'message': 'Not running on mobile platform'};
    }

    final recentMobileErrors = getRecentMobileErrors(limit: 10);
    final hasRecentMobileIssues = hasRecentMobileFailures();
    final authErrorsOnMobile =
        _apiLogs
            .where(
              (log) =>
                  log['platform'] == 'mobile' && log['isAuthError'] == true,
            )
            .length;

    return {
      'isMobile': true,
      'operatingSystem': Platform.operatingSystem,
      'recentMobileErrors': recentMobileErrors.length,
      'hasRecentMobileIssues': hasRecentMobileIssues,
      'authErrorsOnMobile': authErrorsOnMobile,
      'networkLogsCount': _networkLogs.length,
      'totalMobileApiCalls':
          _apiLogs.where((log) => log['platform'] == 'mobile').length,
      'mobileErrorDetails': recentMobileErrors,
    };
  }
}
