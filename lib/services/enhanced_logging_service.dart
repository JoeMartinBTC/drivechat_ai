import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './debug_service.dart';

// lib/services/enhanced_logging_service.dart

/// Enhanced logging service for detailed error tracking and diagnostics
class EnhancedLoggingService {
  static final EnhancedLoggingService _instance =
      EnhancedLoggingService._internal();
  factory EnhancedLoggingService() => _instance;
  EnhancedLoggingService._internal();

  final DebugService _debugService = DebugService();
  final List<Map<String, dynamic>> _errorLogs = [];
  final List<Map<String, dynamic>> _performanceLogs = [];
  final List<Map<String, dynamic>> _userInteractionLogs = [];
  bool _isEnabled = true;

  /// Initialize the logging service
  Future<void> initialize() async {
    await _debugService.initialize();
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('enhanced_logging_enabled') ?? true;

    // Log initialization
    logEvent('EnhancedLoggingService', 'Service initialized', {
      'platform': Platform.operatingSystem,
      'isMobile': Platform.isAndroid || Platform.isIOS,
      'debugMode': kDebugMode,
    });
  }

  /// Log general events with context
  void logEvent(String category, String event, Map<String, dynamic>? context) {
    if (!_isEnabled) return;

    final logEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': category,
      'event': event,
      'context': context ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'isMobile': Platform.isAndroid || Platform.isIOS,
    };

    _performanceLogs.add(logEntry);

    // Keep only last 100 performance logs
    if (_performanceLogs.length > 100) {
      _performanceLogs.removeAt(0);
    }

    if (kDebugMode) {
      print('📊 Event: [$category] $event');
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  /// Log errors with stack trace and recovery suggestions
  void logError(
    String category,
    String error, {
    String? stackTrace,
    Map<String, dynamic>? context,
    List<String>? recoverySuggestions,
    bool isCritical = false,
  }) {
    if (!_isEnabled) return;

    final logEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': category,
      'error': error,
      'stackTrace': stackTrace,
      'context': context ?? {},
      'recoverySuggestions': recoverySuggestions ?? [],
      'isCritical': isCritical,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'isMobile': Platform.isAndroid || Platform.isIOS,
    };

    _errorLogs.add(logEntry);

    // Keep only last 50 error logs
    if (_errorLogs.length > 50) {
      _errorLogs.removeAt(0);
    }

    if (kDebugMode) {
      print('❌ Error: [$category] $error');
      if (isCritical) {
        print('🚨 CRITICAL ERROR');
      }
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
      if (recoverySuggestions != null && recoverySuggestions.isNotEmpty) {
        print('   Recovery: $recoverySuggestions');
      }
    }
  }

  /// Log user interactions for better UX analysis
  void logUserInteraction(
    String action, {
    String? screen,
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled) return;

    final logEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'screen': screen ?? 'unknown',
      'data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'isMobile': Platform.isAndroid || Platform.isIOS,
    };

    _userInteractionLogs.add(logEntry);

    // Keep only last 100 interaction logs
    if (_userInteractionLogs.length > 100) {
      _userInteractionLogs.removeAt(0);
    }

    if (kDebugMode) {
      print('👤 User: $action on ${screen ?? "unknown screen"}');
    }
  }

  /// Get recent error logs
  List<Map<String, dynamic>> getRecentErrors({int limit = 10}) {
    return _errorLogs.reversed.take(limit).toList();
  }

  /// Get critical errors only
  List<Map<String, dynamic>> getCriticalErrors() {
    return _errorLogs.where((log) => log['isCritical'] == true).toList();
  }

  /// Get errors by category
  List<Map<String, dynamic>> getErrorsByCategory(String category) {
    return _errorLogs.where((log) => log['category'] == category).toList();
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final totalEvents = _performanceLogs.length;
    final totalErrors = _errorLogs.length;
    final criticalErrors = getCriticalErrors().length;
    final userInteractions = _userInteractionLogs.length;

    // Calculate error rate
    final errorRate = totalEvents > 0 ? (totalErrors / totalEvents * 100) : 0;

    // Get most common error categories
    final errorCategories = <String, int>{};
    for (final error in _errorLogs) {
      final category = error['category'] as String;
      errorCategories[category] = (errorCategories[category] ?? 0) + 1;
    }

    return {
      'totalEvents': totalEvents,
      'totalErrors': totalErrors,
      'criticalErrors': criticalErrors,
      'userInteractions': userInteractions,
      'errorRate': errorRate.toStringAsFixed(2),
      'errorCategories': errorCategories,
      'platform': Platform.operatingSystem,
      'isMobile': Platform.isAndroid || Platform.isIOS,
    };
  }

  /// Get comprehensive diagnostics report
  Map<String, dynamic> getDiagnosticsReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'loggingEnabled': _isEnabled,
      'platform': {
        'operatingSystem': Platform.operatingSystem,
        'isMobile': Platform.isAndroid || Platform.isIOS,
        'debugMode': kDebugMode,
      },
      'metrics': getPerformanceMetrics(),
      'recentErrors': getRecentErrors(limit: 5),
      'criticalErrors': getCriticalErrors(),
      'debugServiceData': _debugService.getDebugSummary(),
      'mobileDiagnostics': _debugService.getMobileDiagnostics(),
    };
  }

  /// Export all logs as a formatted string
  String exportAllLogs() {
    final buffer = StringBuffer();
    final diagnostics = getDiagnosticsReport();

    buffer.writeln('=== Enhanced Diagnostics Report ===');
    buffer.writeln('Generated: ${diagnostics['timestamp']}');
    buffer.writeln('Platform: ${diagnostics['platform']['operatingSystem']}');
    buffer.writeln('Mobile: ${diagnostics['platform']['isMobile']}');
    buffer.writeln('Debug Mode: ${diagnostics['platform']['debugMode']}');
    buffer.writeln('');

    buffer.writeln('=== Performance Metrics ===');
    final metrics = diagnostics['metrics'] as Map<String, dynamic>;
    metrics.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    buffer.writeln('');

    buffer.writeln('=== Recent Errors (${_errorLogs.length}) ===');
    for (final error in _errorLogs.reversed.take(10)) {
      buffer.writeln(
        '${error['timestamp']}: [${error['category']}] ${error['error']}',
      );
      if (error['isCritical'] == true) {
        buffer.writeln('  🚨 CRITICAL');
      }
      if (error['context'] != null && (error['context'] as Map).isNotEmpty) {
        buffer.writeln('  Context: ${error['context']}');
      }
    }
    buffer.writeln('');

    buffer.writeln('=== Performance Events (${_performanceLogs.length}) ===');
    for (final event in _performanceLogs.reversed.take(20)) {
      buffer.writeln(
        '${event['timestamp']}: [${event['category']}] ${event['event']}',
      );
    }

    return buffer.toString();
  }

  /// Clear all logs
  void clearAllLogs() {
    _errorLogs.clear();
    _performanceLogs.clear();
    _userInteractionLogs.clear();

    logEvent('EnhancedLoggingService', 'All logs cleared', {});
  }

  /// Enable/disable logging
  Future<void> setLoggingEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enhanced_logging_enabled', enabled);

    logEvent(
      'EnhancedLoggingService',
      'Logging ${enabled ? "enabled" : "disabled"}',
      {},
    );
  }

  // Getters
  bool get isEnabled => _isEnabled;
  List<Map<String, dynamic>> get errorLogs => List.unmodifiable(_errorLogs);
  List<Map<String, dynamic>> get performanceLogs =>
      List.unmodifiable(_performanceLogs);
  List<Map<String, dynamic>> get userInteractionLogs =>
      List.unmodifiable(_userInteractionLogs);
}
