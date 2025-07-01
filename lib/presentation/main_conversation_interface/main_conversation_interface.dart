import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/audio_controls_widget.dart';
import './widgets/chat_message_widget.dart';
import './widgets/connection_status_widget.dart';
import './widgets/text_input_widget.dart';
import './widgets/voice_recording_widget.dart';

class MainConversationInterface extends StatefulWidget {
  const MainConversationInterface({super.key});

  @override
  State<MainConversationInterface> createState() =>
      _MainConversationInterfaceState();
}

class _MainConversationInterfaceState extends State<MainConversationInterface>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _isVoiceMode = true;
  bool _isRecording = false;
  final bool _isConnected = true;
  bool _isMuted = false;
  bool _isAiProcessing = false;
  double _volume = 0.8;
  final bool _isOffline = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  // Mock conversation data
  final List<Map<String, dynamic>> _conversationHistory = [
    {
      "id": 1,
      "message":
          "Hallo! Ich bin dein KI-Fahrlehrer. Wie kann ich dir heute beim Lernen helfen?",
      "isUser": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "hasAudio": true,
    },
    {
      "id": 2,
      "message":
          "Ich möchte über Verkehrsregeln lernen, besonders über Vorfahrtsregeln.",
      "isUser": true,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 4)),
      "hasAudio": false,
    },
    {
      "id": 3,
      "message":
          "Ausgezeichnet! Vorfahrtsregeln sind sehr wichtig. Lass uns mit der Grundregel beginnen: Rechts vor Links. Kannst du mir erklären, was das bedeutet?",
      "isUser": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "hasAudio": true,
    },
    {
      "id": 4,
      "message":
          "Das bedeutet, dass Fahrzeuge von rechts Vorfahrt haben, wenn keine anderen Verkehrszeichen vorhanden sind.",
      "isUser": true,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 2)),
      "hasAudio": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/conversation-history');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings-screen');
        break;
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    if (_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  void _startRecording() {
    // Simulate recording start
    print("Recording started");
  }

  void _stopRecording() {
    // Simulate recording stop and AI processing
    setState(() {
      _isAiProcessing = true;
    });

    // Simulate AI response after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
          _conversationHistory.add({
            "id": _conversationHistory.length + 1,
            "message":
                "Das ist korrekt! Sehr gut erklärt. Lass uns nun über Verkehrszeichen sprechen, die die Vorfahrt regeln.",
            "isUser": false,
            "timestamp": DateTime.now(),
            "hasAudio": true,
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _sendTextMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _conversationHistory.add({
        "id": _conversationHistory.length + 1,
        "message": _textController.text.trim(),
        "isUser": true,
        "timestamp": DateTime.now(),
        "hasAudio": false,
      });
      _isAiProcessing = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
          _conversationHistory.add({
            "id": _conversationHistory.length + 1,
            "message":
                "Danke für deine Frage! Lass mich dir dabei helfen. Welchen spezifischen Aspekt möchtest du vertiefen?",
            "isUser": false,
            "timestamp": DateTime.now(),
            "hasAudio": true,
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _onMessageLongPress(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'content_copy',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('Text kopieren'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message['message']));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text kopiert')),
                    );
                  },
                ),
                if (message['hasAudio'])
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'replay',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: const Text('Audio wiederholen'),
                    onTap: () {
                      Navigator.pop(context);
                      // Implement audio replay
                    },
                  ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'report',
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  title: const Text('Problem melden'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement report issue
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Future<void> _onRefresh() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Refresh conversation history
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            if (_isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(context).colorScheme.error,
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'wifi_off',
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Offline - Nur gespeicherte Unterhaltungen verfügbar',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Header with connection status and AI agent name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ConnectionStatusWidget(isConnected: _isConnected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GetMyLappen',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _isConnected
                              ? 'Verbunden'
                              : 'Verbindung wird hergestellt...',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                _isConnected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mode toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isVoiceMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _isVoiceMode
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'mic',
                                  color:
                                      _isVoiceMode
                                          ? Colors.white
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sprache',
                                  style: TextStyle(
                                    color:
                                        _isVoiceMode
                                            ? Colors.white
                                            : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isVoiceMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  !_isVoiceMode
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'keyboard',
                                  color:
                                      !_isVoiceMode
                                          ? Colors.white
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Text',
                                  style: TextStyle(
                                    color:
                                        !_isVoiceMode
                                            ? Colors.white
                                            : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Conversation history
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      _conversationHistory.length + (_isAiProcessing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _conversationHistory.length &&
                        _isAiProcessing) {
                      return ChatMessageWidget(
                        message: {
                          "id": -1,
                          "message": "",
                          "isUser": false,
                          "timestamp": DateTime.now(),
                          "hasAudio": false,
                          "isTyping": true,
                        },
                        onLongPress: (_) {},
                      );
                    }

                    final message = _conversationHistory[index];
                    return ChatMessageWidget(
                      message: message,
                      onLongPress: _onMessageLongPress,
                    );
                  },
                ),
              ),
            ),

            // Audio controls (floating above input)
            if (_isVoiceMode)
              AudioControlsWidget(
                volume: _volume,
                isMuted: _isMuted,
                onVolumeChanged: (value) => setState(() => _volume = value),
                onMuteToggle: () => setState(() => _isMuted = !_isMuted),
              ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child:
                  _isVoiceMode
                      ? VoiceRecordingWidget(
                        isRecording: _isRecording,
                        onToggleRecording: _toggleRecording,
                      )
                      : TextInputWidget(
                        controller: _textController,
                        onSend: _sendTextMessage,
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'chat',
              color:
                  _currentTabIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Unterhaltung',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'history',
              color:
                  _currentTabIndex == 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Verlauf',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color:
                  _currentTabIndex == 2
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
