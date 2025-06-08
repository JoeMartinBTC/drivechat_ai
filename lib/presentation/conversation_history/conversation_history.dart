import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/conversation_session_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/search_bar_widget.dart';

class ConversationHistory extends StatefulWidget {
  const ConversationHistory({super.key});

  @override
  State<ConversationHistory> createState() => _ConversationHistoryState();
}

class _ConversationHistoryState extends State<ConversationHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final List<String> _selectedSessions = [];
  bool _isSelectionMode = false;

  // Mock conversation data
  final List<Map<String, dynamic>> _conversationSessions = [
    {
      "id": "session_001",
      "date": DateTime(2024, 1, 15, 14, 30),
      "duration": "25 Min",
      "firstExchange": "Hallo! Heute möchte ich über Verkehrsregeln sprechen.",
      "topics": ["Verkehrsregeln", "Vorfahrt"],
      "completionStatus": "completed",
      "progress": 100,
      "isArchived": false,
      "audioAvailable": true,
    },
    {
      "id": "session_002",
      "date": DateTime(2024, 1, 14, 16, 45),
      "duration": "18 Min",
      "firstExchange": "Können Sie mir beim Parken helfen?",
      "topics": ["Parken", "Einparken"],
      "completionStatus": "completed",
      "progress": 100,
      "isArchived": false,
      "audioAvailable": true,
    },
    {
      "id": "session_003",
      "date": DateTime(2024, 1, 13, 10, 15),
      "duration": "32 Min",
      "firstExchange": "Ich habe Fragen zu Verkehrsschildern.",
      "topics": ["Verkehrsschilder", "Bedeutung"],
      "completionStatus": "in_progress",
      "progress": 75,
      "isArchived": false,
      "audioAvailable": true,
    },
    {
      "id": "session_004",
      "date": DateTime(2024, 1, 12, 9, 20),
      "duration": "15 Min",
      "firstExchange": "Was sind die wichtigsten Sicherheitsregeln?",
      "topics": ["Sicherheit", "Grundlagen"],
      "completionStatus": "completed",
      "progress": 100,
      "isArchived": true,
      "audioAvailable": false,
    },
    {
      "id": "session_005",
      "date": DateTime(2024, 1, 11, 13, 50),
      "duration": "28 Min",
      "firstExchange": "Wie funktioniert das Überholen richtig?",
      "topics": ["Überholen", "Autobahn"],
      "completionStatus": "completed",
      "progress": 100,
      "isArchived": false,
      "audioAvailable": true,
    },
  ];

  List<Map<String, dynamic>> get _filteredSessions {
    if (_searchQuery.isEmpty) {
      return _conversationSessions
          .where((session) => !session["isArchived"])
          .toList();
    }

    return _conversationSessions.where((session) {
      if (session["isArchived"]) return false;

      final query = _searchQuery.toLowerCase();
      final firstExchange = (session["firstExchange"] as String).toLowerCase();
      final topics = (session["topics"] as List).join(" ").toLowerCase();

      return firstExchange.contains(query) || topics.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedSessions.clear();
      }
    });
  }

  void _toggleSessionSelection(String sessionId) {
    setState(() {
      if (_selectedSessions.contains(sessionId)) {
        _selectedSessions.remove(sessionId);
      } else {
        _selectedSessions.add(sessionId);
      }

      if (_selectedSessions.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _onSessionLongPress(String sessionId) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedSessions.add(sessionId);
      });
    }
  }

  void _onSessionTap(String sessionId) {
    if (_isSelectionMode) {
      _toggleSessionSelection(sessionId);
    } else {
      // Navigate to detailed conversation view
      _showSessionDetails(sessionId);
    }
  }

  void _showSessionDetails(String sessionId) {
    final session =
        _conversationSessions.firstWhere((s) => s["id"] == sessionId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 90.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Unterhaltung Details',
                      style: AppTheme.lightTheme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Datum', _formatDate(session["date"])),
                    const SizedBox(height: 16),
                    _buildDetailItem('Dauer', session["duration"]),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                        'Themen', (session["topics"] as List).join(", ")),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                        'Status', _getStatusText(session["completionStatus"])),
                    const SizedBox(height: 24),
                    Text(
                      'Unterhaltung',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        session["firstExchange"],
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Resume conversation logic
                            },
                            icon: CustomIconWidget(
                              iconName: 'play_arrow',
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            label: const Text('Fortsetzen'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Export conversation logic
                            },
                            icon: CustomIconWidget(
                              iconName: 'share',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            label: const Text('Teilen'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Abgeschlossen';
      case 'in_progress':
        return 'In Bearbeitung';
      default:
        return 'Unbekannt';
    }
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unterhaltungen löschen'),
        content: Text(
            'Möchten Sie ${_selectedSessions.length} Unterhaltung(en) wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _conversationSessions.removeWhere(
                    (session) => _selectedSessions.contains(session["id"]));
                _selectedSessions.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _bulkArchive() {
    setState(() {
      for (final sessionId in _selectedSessions) {
        final sessionIndex =
            _conversationSessions.indexWhere((s) => s["id"] == sessionId);
        if (sessionIndex != -1) {
          _conversationSessions[sessionIndex]["isArchived"] = true;
        }
      }
      _selectedSessions.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedSessions.length} ausgewählt')
            : const Text('Unterhaltungsverlauf'),
        leading: _isSelectionMode
            ? IconButton(
                onPressed: _toggleSelectionMode,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  onPressed: _bulkArchive,
                  icon: CustomIconWidget(
                    iconName: 'archive',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: _bulkDelete,
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 24,
                  ),
                ),
              ]
            : [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/settings-screen'),
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              isSearching: _isSearching,
              onClear: () {
                _searchController.clear();
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              },
            ),
            Expanded(
              child: _filteredSessions.isEmpty
                  ? EmptyStateWidget(
                      isSearching: _isSearching,
                      onStartConversation: () => Navigator.pushNamed(
                          context, '/main-conversation-interface'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredSessions.length,
                      itemBuilder: (context, index) {
                        final session = _filteredSessions[index];
                        final isSelected =
                            _selectedSessions.contains(session["id"]);

                        return ConversationSessionCardWidget(
                          session: session,
                          isSelected: isSelected,
                          isSelectionMode: _isSelectionMode,
                          onTap: () => _onSessionTap(session["id"]),
                          onLongPress: () => _onSessionLongPress(session["id"]),
                          onResume: () => Navigator.pushNamed(
                              context, '/main-conversation-interface'),
                          onShare: () {
                            // Share functionality
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Unterhaltung löschen'),
                                content: const Text(
                                    'Möchten Sie diese Unterhaltung wirklich löschen?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Abbrechen'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _conversationSessions.removeWhere(
                                            (s) => s["id"] == session["id"]);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Löschen'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onArchive: () {
                            setState(() {
                              final sessionIndex = _conversationSessions
                                  .indexWhere((s) => s["id"] == session["id"]);
                              if (sessionIndex != -1) {
                                _conversationSessions[sessionIndex]
                                    ["isArchived"] = true;
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/main-conversation-interface'),
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
              label: const Text('Neue Unterhaltung'),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/main-conversation-interface');
              break;
            case 1:
              // Already on conversation history
              break;
            case 2:
              Navigator.pushNamed(context, '/settings-screen');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'chat',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'chat',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Verlauf',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
