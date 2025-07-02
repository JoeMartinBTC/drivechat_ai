// lib/controllers/conversation_controller.dart
import 'package:flutter/foundation.dart';

import '../services/elevenlabs_service.dart';
import '../services/mock_elevenlabs_service.dart';
import '../services/debug_service.dart';
import '../services/enhanced_logging_service.dart';
import '../services/connection_error_handler.dart';
import './api_config_controller.dart';
import './audio_controller.dart';

/// Controller for managing conversation flow and message processing
class ConversationController extends ChangeNotifier {
  final ApiConfigController _apiConfigController;
  final AudioController _audioController;
  final DebugService _debugService = DebugService();
  final EnhancedLoggingService _loggingService = EnhancedLoggingService();
  final ElevenLabsService _elevenlabsService = ElevenLabsService();
  final MockElevenLabsService _mockElevenlabsService = MockElevenLabsService();
  final ConnectionErrorHandler _errorHandler = ConnectionErrorHandler();

  final List<Map<String, dynamic>> _conversationHistory = [];
  bool _isProcessing = false;
  bool _isConnected = false;
  String _connectionStatus = 'Checking connection...';
  bool _audioEnabled = true;
  bool _textOutputEnabled = true;

  // Connection error tracking
  ConnectionErrorDetails? _lastConnectionError;
  bool _hasActiveConnectionIssues = false;

  // AI Response templates for driving instructor
  final List<String> _aiResponses = [
    'Das ist eine sehr gute Frage! Bei Verkehrsregeln ist es wichtig, dass Sie die Grundlagen verstehen.',
    'Ausgezeichnet! Sie zeigen, dass Sie die Verkehrsregeln ernst nehmen und lernen möchten.',
    'Lassen Sie mich Ihnen dabei helfen. Dieses Thema ist besonders wichtig für die praktische Prüfung.',
    'Sehr gut beobachtet! Das ist ein wichtiger Punkt, den viele Fahrschüler übersehen.',
    'Das ist korrekt! Sie machen gute Fortschritte beim Verstehen der Verkehrsregeln.',
    'Eine wichtige Frage zur Verkehrssicherheit. Lassen Sie uns das genauer betrachten.',
    'Perfekt! Das zeigt, dass Sie aufmerksam sind und die Regeln verstehen.',
    'Das ist ein typisches Szenario in der Fahrprüfung. Gut, dass Sie danach fragen!',
  ];

  // Getters
  List<Map<String, dynamic>> get conversationHistory =>
      List.unmodifiable(_conversationHistory);
  bool get isProcessing => _isProcessing;
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  bool get audioEnabled => _audioEnabled;
  bool get textOutputEnabled => _textOutputEnabled;
  bool get isUsingLiveApi => !_apiConfigController.useMockServices;
  ConnectionErrorDetails? get lastConnectionError => _lastConnectionError;
  bool get hasActiveConnectionIssues => _hasActiveConnectionIssues;

  ConversationController(this._apiConfigController, this._audioController) {
    _initialize();

    // Listen to API config changes
    _apiConfigController.addListener(_onApiConfigChanged);
  }

  @override
  void dispose() {
    _apiConfigController.removeListener(_onApiConfigChanged);
    super.dispose();
  }

  /// Handle API configuration changes
  void _onApiConfigChanged() {
    _loggingService.logEvent('ConversationController', 'API config changed', {
      'isConnected': _apiConfigController.isConnected,
      'isInDemoMode': _apiConfigController.useMockServices,
    });
    _checkConnection();
  }

  /// Initialize the conversation controller
  Future<void> _initialize() async {
    try {
      await _debugService.initialize();
      await _loggingService.initialize();

      _loggingService.logEvent(
        'ConversationController',
        'Initializing controller',
        {},
      );

      _checkConnection();

      // Add initial greeting message based on API status
      _addSystemMessage(_getInitialGreeting());

      _loggingService.logEvent(
        'ConversationController',
        'Controller initialized successfully',
        {},
      );
    } catch (e) {
      _loggingService.logError(
        'ConversationController',
        'Failed to initialize controller: $e',
        isCritical: true,
        recoverySuggestions: ['Restart the app', 'Check system permissions'],
      );
    }
  }

  /// Get initial greeting based on API connection status
  String _getInitialGreeting() {
    if (_apiConfigController.useMockServices) {
      return 'Hallo! Ich bin Ihr KI-Fahrlehrer für GetMyLappen. '
          'Sie befinden sich im Demo-Modus. '
          'Konfigurieren Sie Ihre ElevenLabs API für vollständige Funktionalität mit Sprachausgabe. '
          'Wie kann ich Ihnen heute beim Lernen der Verkehrsregeln helfen?';
    } else if (_apiConfigController.isConnected) {
      return 'Hallo! Ich bin Ihr KI-Fahrlehrer für GetMyLappen. '
          'Ich bin bereit, Ihnen beim Lernen der Verkehrsregeln zu helfen. '
          'Fragen Sie mich alles über Verkehrszeichen, Vorfahrtsregeln oder Fahrpraxis!';
    } else {
      return 'Hallo! Ich bin Ihr KI-Fahrlehrer für GetMyLappen. '
          'Derzeit läuft der Service im Demo-Modus. '
          'Bitte konfigurieren Sie Ihre ElevenLabs API für vollständige Funktionalität. '
          'Wie kann ich Ihnen helfen?';
    }
  }

  /// Check connection status and update error tracking
  void _checkConnection() {
    _isConnected = _apiConfigController.isConnected;
    // _lastConnectionError = _apiConfigController.lastConnectionError;
    // _hasActiveConnectionIssues = _apiConfigController.hasConnectionIssues;

    if (_apiConfigController.config.hasValidCredentials) {
      _connectionStatus = 'Demo-Modus - Konfigurieren Sie ElevenLabs API';
    } else if (_isConnected) {
      _connectionStatus = 'Verbunden mit ElevenLabs API';
    } else if (_lastConnectionError != null) {
      _connectionStatus = _lastConnectionError!.userFriendlyMessage;
    } else {
      _connectionStatus = 'Keine Verbindung zur API';
    }

    _loggingService
        .logEvent('ConversationController', 'Connection status updated', {
      'isConnected': _isConnected,
      'connectionStatus': _connectionStatus,
      'hasActiveConnectionIssues': _hasActiveConnectionIssues,
    });

    notifyListeners();
  }

  /// Add a system message
  void _addSystemMessage(String message) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final messageData = {
      'id': messageId,
      'message': message,
      'isUser': false,
      'timestamp': DateTime.now(),
      'hasAudio': false,
      'isSystem': true,
    };

    _conversationHistory.add(messageData);

    _debugService.logMessage(
      messageId: messageId,
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
      hasAudio: false,
    );

    _loggingService.logEvent('ConversationController', 'System message added', {
      'messageLength': message.length,
      'messageType': 'system',
    });

    notifyListeners();
  }

  /// Process user message and generate AI response with connection error handling
  Future<void> processUserMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || _isProcessing) return;

    _isProcessing = true;
    notifyListeners();

    try {
      _loggingService.logUserInteraction(
        'send_message',
        screen: 'conversation',
        data: {'messageLength': userMessage.length},
      );

      // Check network connectivity before processing
      if (!await _errorHandler.hasNetworkConnection()) {
        _addConnectionErrorMessage(
          'Keine Internetverbindung verfügbar. Ihre Nachricht konnte nicht versendet werden.',
          ConnectionErrorType.networkUnavailable,
        );
        return;
      }

      // Add user message
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      final userMessageData = {
        'id': userMessageId,
        'message': userMessage.trim(),
        'isUser': true,
        'timestamp': DateTime.now(),
        'hasAudio': false,
      };

      _conversationHistory.add(userMessageData);

      _debugService.logMessage(
        messageId: userMessageId,
        text: userMessage.trim(),
        isUser: true,
        timestamp: DateTime.now(),
        hasAudio: false,
      );

      notifyListeners();

      // Generate AI response
      await _generateAiResponse(userMessage);
    } catch (e) {
      final errorDetails = _errorHandler.parseConnectionError(e);

      _loggingService.logError(
        'ConversationController',
        'Failed to process user message: ${errorDetails.message}',
        context: {'userMessageLength': userMessage.length},
        recoverySuggestions: errorDetails.recoveryActions,
        isCritical: false,
      );

      if (kDebugMode) {
        print('Error processing user message: ${errorDetails.message}');
      }

      _addConnectionErrorMessage(
        'Fehler beim Verarbeiten der Nachricht: ${errorDetails.userFriendlyMessage}',
        errorDetails.type,
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Add a connection error message to the conversation
  void _addConnectionErrorMessage(
    String message,
    ConnectionErrorType errorType,
  ) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final messageData = {
      'id': messageId,
      'message': message,
      'isUser': false,
      'timestamp': DateTime.now(),
      'hasAudio': false,
      'isError': true,
      'errorType': errorType.toString(),
      'canRetry': true,
    };

    _conversationHistory.add(messageData);

    _loggingService.logEvent(
      'ConversationController',
      'Connection error message added',
      {'errorType': errorType.toString(), 'messageLength': message.length},
    );

    notifyListeners();
  }

  /// Generate AI response based on user message with context-aware responses
  Future<void> _generateAiResponse(String userMessage) async {
    // Simulate thinking time for AI response
    await Future.delayed(const Duration(milliseconds: 800));

    String response = _generateContextualResponse(userMessage);
    await _addAiMessage(response);
  }

  /// Generate contextual response based on user input
  String _generateContextualResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Context-aware responses for driving-related topics
    if (message.contains('vorfahrt') || message.contains('vorrang')) {
      return 'Vorfahrtsregeln sind fundamental wichtig! Die Grundregel ist "Rechts vor Links". '
          'Aber es gibt Ausnahmen: Verkehrszeichen, Ampeln und bestimmte Straßentypen '
          'können diese Grundregel außer Kraft setzen. Haben Sie eine spezifische Situation, '
          'über die Sie sprechen möchten?';
    }

    if (message.contains('verkehrszeichen') || message.contains('schild')) {
      return 'Verkehrszeichen sind die "Sprache der Straße"! Sie werden in verschiedene '
          'Kategorien unterteilt: Gefahrenzeichen (dreieckig), Vorschriftzeichen (rund) '
          'und Richtzeichen (rechteckig). Welche Art von Verkehrszeichen interessiert Sie besonders?';
    }

    if (message.contains('geschwindigkeit') || message.contains('tempo')) {
      return 'Geschwindigkeitsbegrenzungen sind entscheidend für die Verkehrssicherheit! '
          'In Deutschland gelten: Innerorts 50 km/h, außerorts 100 km/h auf Landstraßen. '
          'Auf Autobahnen gibt es oft Richtgeschwindigkeit von 130 km/h. '
          'Beachten Sie immer die ausgeschilderten Limits!';
    }

    if (message.contains('parken') || message.contains('halten')) {
      return 'Parken und Halten haben klare Regeln! Halten ist bis zu 3 Minuten erlaubt, '
          'Parken darüber hinaus. Beide sind verboten: vor Einfahrten, an Bushaltestellen, '
          'im Halteverbot. Achten Sie auf Parkverbotsschilder und Markierungen!';
    }

    if (message.contains('abstand') || message.contains('sicherheitsabstand')) {
      return 'Der Sicherheitsabstand rettet Leben! Als Faustregel gilt: '
          'Halber Tacho = Mindestabstand in Metern. Bei 50 km/h also 25 Meter Abstand. '
          'Bei schlechten Bedingungen (Regen, Nebel) den Abstand verdoppeln!';
    }

    if (message.contains('kreisverkehr') || message.contains('kreisel')) {
      return 'Kreisverkehr ist einfacher als viele denken! Regel: Wer im Kreis fährt, hat Vorfahrt. '
          'Beim Einfahren blinken Sie nicht, beim Ausfahren schon. '
          'Achtung: Fußgänger an Zebrastreifen vor dem Kreis haben Vorrang!';
    }

    if (message.contains('prüfung') || message.contains('test')) {
      return 'Für die Fahrprüfung ist gute Vorbereitung der Schlüssel! '
          'Üben Sie besonders: Einparken, Anfahren am Berg, Verkehrsbeobachtung '
          'und das Befolgen der Anweisungen des Prüfers. Bleiben Sie ruhig und konzentriert!';
    }

    if (message.contains('alkohol') || message.contains('promille')) {
      return 'Alkohol am Steuer ist extrem gefährlich und strafbar! '
          'Für Fahranfänger und unter 21 Jahren gilt: 0,0 Promille! '
          'Für erfahrene Fahrer: 0,5 Promille Grenze, aber schon ab 0,3 Promille '
          'bei Auffälligkeiten strafbar. Mein Rat: Gar kein Alkohol am Steuer!';
    }

    if (message.contains('handy') ||
        message.contains('telefon') ||
        message.contains('smartphone')) {
      return 'Handynutzung am Steuer ist gefährlich und verboten! '
          'Das Handy darf nur mit Freisprecheinrichtung benutzt werden. '
          'Selbst das Aufheben eines heruntergefallenen Handys ist strafbar. '
          'Strafe: 100€ und 1 Punkt in Flensburg!';
    }

    // Generic responses for other topics
    return '${_aiResponses[DateTime.now().millisecond % _aiResponses.length]} Können Sie mir mehr Details zu Ihrer Frage geben?';
  }

  /// Add AI message with optional audio generation and enhanced error handling
  Future<void> _addAiMessage(String message) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final messageData = {
      'id': messageId,
      'message': _textOutputEnabled ? message : '[Audio-only response]',
      'isUser': false,
      'timestamp': DateTime.now(),
      'hasAudio': _audioEnabled,
      'originalText':
          message, // Store original text even if text output is disabled
    };

    _conversationHistory.add(messageData);
    notifyListeners();

    // Generate audio if enabled and not in demo mode
    if (_audioEnabled && !_apiConfigController.useMockServices) {
      await _generateAudioForMessage(messageId, message);
    } else if (_audioEnabled && _apiConfigController.useMockServices) {
      // In demo mode, simulate audio generation
      await Future.delayed(const Duration(milliseconds: 500));
      final messageIndex = _conversationHistory.indexWhere(
        (msg) => msg['id'] == messageId,
      );
      if (messageIndex != -1) {
        _conversationHistory[messageIndex]['audioGenerated'] = false;
        _conversationHistory[messageIndex]['demoAudioNote'] =
            'Audio-Generierung verfügbar mit ElevenLabs API';
        notifyListeners();
      }
    }

    _debugService.logMessage(
      messageId: messageId,
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
      hasAudio: _audioEnabled,
    );
  }

  /// Generate audio for a message using ElevenLabs with enhanced error handling
  Future<void> _generateAudioForMessage(String messageId, String text) async {
    try {
      final startTime = DateTime.now();
      Map<String, dynamic> result;

      if (_apiConfigController.useMockServices) {
        result = await _mockElevenlabsService.textToSpeech(text);
      } else {
        result = await _elevenlabsService.textToSpeech(text);
      }

      final duration = DateTime.now().difference(startTime);

      // Log API call
      _debugService.logApiCall(
        endpoint: '/text-to-speech',
        method: 'POST',
        requestData: {
          'text': text,
          'voice_id': _apiConfigController.config.selectedVoiceId ?? 'default',
        },
        response: result,
        timestamp: startTime,
        duration: duration,
        error: result['success'] ? null : result['message'],
      );

      if (result['success']) {
        // Update message with audio data
        final messageIndex = _conversationHistory.indexWhere(
          (msg) => msg['id'] == messageId,
        );
        if (messageIndex != -1) {
          _conversationHistory[messageIndex]['audioData'] = result['audioData'];
          _conversationHistory[messageIndex]['audioGenerated'] = true;
          notifyListeners();
        }
      } else {
        // Handle audio generation error
        final messageIndex = _conversationHistory.indexWhere(
          (msg) => msg['id'] == messageId,
        );
        if (messageIndex != -1) {
          _conversationHistory[messageIndex]['audioError'] = result['message'];
          _conversationHistory[messageIndex]['audioGenerated'] = false;

          // Add error details if available
          if (result.containsKey('error_type')) {
            _conversationHistory[messageIndex]['audioErrorType'] =
                result['error_type'];
            _conversationHistory[messageIndex]['recoveryActions'] =
                result['recovery_actions'];
            _conversationHistory[messageIndex]['canRetryAudio'] =
                result['can_retry'];
          }

          notifyListeners();
        }

        if (kDebugMode) {
          print('Failed to generate audio: ${result['message']}');
        }
      }
    } catch (e) {
      final errorDetails = _errorHandler.parseConnectionError(e);

      if (kDebugMode) {
        print('Error generating audio: ${errorDetails.message}');
      }

      // Update message with error information
      final messageIndex = _conversationHistory.indexWhere(
        (msg) => msg['id'] == messageId,
      );
      if (messageIndex != -1) {
        _conversationHistory[messageIndex]['audioError'] =
            errorDetails.userFriendlyMessage;
        _conversationHistory[messageIndex]['audioErrorType'] =
            errorDetails.type.toString();
        _conversationHistory[messageIndex]['audioGenerated'] = false;
        _conversationHistory[messageIndex]['canRetryAudio'] =
            errorDetails.canRetry;
        _conversationHistory[messageIndex]['recoveryActions'] =
            errorDetails.recoveryActions;
        notifyListeners();
      }

      _debugService.logMessage(
        messageId: messageId,
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        hasAudio: false,
        processingError: 'Audio generation failed: ${errorDetails.message}',
      );
    }
  }

  /// Retry audio generation for a specific message
  Future<void> retryAudioGeneration(String messageId) async {
    final messageIndex = _conversationHistory.indexWhere(
      (msg) => msg['id'] == messageId,
    );
    if (messageIndex == -1) return;

    final messageData = _conversationHistory[messageIndex];
    final originalText = messageData['originalText'] as String? ??
        messageData['message'] as String;

    // Reset error state
    _conversationHistory[messageIndex]['audioError'] = null;
    _conversationHistory[messageIndex]['audioErrorType'] = null;
    _conversationHistory[messageIndex]['audioGenerated'] =
        null; // Set to loading state
    notifyListeners();

    // Retry audio generation
    await _generateAudioForMessage(messageId, originalText);
  }

  /// Add error message
  void _addErrorMessage(String error) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final messageData = {
      'id': messageId,
      'message': error,
      'isUser': false,
      'timestamp': DateTime.now(),
      'hasAudio': false,
      'isError': true,
    };

    _conversationHistory.add(messageData);
    notifyListeners();
  }

  /// Toggle audio generation for AI responses
  void toggleAudioOutput(bool enabled) {
    _audioEnabled = enabled;
    notifyListeners();

    if (kDebugMode) {
      print('Audio output ${enabled ? "enabled" : "disabled"}');
    }
  }

  /// Toggle text output for AI responses
  void toggleTextOutput(bool enabled) {
    _textOutputEnabled = enabled;
    notifyListeners();

    if (kDebugMode) {
      print('Text output ${enabled ? "enabled" : "disabled"}');
    }
  }

  /// Clear conversation history
  void clearConversation() {
    _conversationHistory.clear();
    _addSystemMessage(_getInitialGreeting());
  }

  /// Refresh connection status
  Future<void> refreshConnection() async {
    await _apiConfigController.testConnection();
    _checkConnection();
  }

  /// Retry connection and clear any connection errors
  Future<void> retryConnection() async {
    final success = await _apiConfigController.resetConfiguration();
    if (success) {
      _lastConnectionError = null;
      _hasActiveConnectionIssues = false;
    }
    _checkConnection();
  }

  /// Check connection health periodically
  Future<void> checkConnectionHealth() async {
    await _apiConfigController.testConnection();
    _checkConnection();
  }

  /// Get debug information with connection error details
  Map<String, dynamic> getDebugInfo() {
    return {
      'conversationLength': _conversationHistory.length,
      'isProcessing': _isProcessing,
      'isConnected': _isConnected,
      'connectionStatus': _connectionStatus,
      'audioEnabled': _audioEnabled,
      'textOutputEnabled': _textOutputEnabled,
      'isUsingLiveApi': isUsingLiveApi,
      'hasActiveConnectionIssues': _hasActiveConnectionIssues,
      'lastConnectionError': _lastConnectionError?.type.toString(),
      'connectionErrorInfo': _apiConfigController.resetConfiguration(),
      'debugSummary': _debugService.getDebugSummary(),
    };
  }
}
