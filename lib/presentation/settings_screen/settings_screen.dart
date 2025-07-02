
import '../../core/app_export.dart';
import './widgets/audio_settings_section_widget.dart';
import './widgets/connection_settings_section_widget.dart';
import './widgets/language_settings_section_widget.dart';
import './widgets/notification_settings_section_widget.dart';
import './widgets/privacy_settings_section_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock settings data
  final Map<String, dynamic> _settingsData = {
    'microphoneSensitivity': 0.7,
    'noiseSuppressionEnabled': true,
    'preferredAudioDevice': 'speaker',
    'volumeLevel': 0.8,
    'apiKey': 'sk-test-api-key-12345',
    'websocketTimeout': 30,
    'autoReconnectEnabled': true,
    'languageCode': 'de',
    'voiceRecognitionOptimized': true,
    'germanKeyboardEnabled': true,
    'conversationStorageEnabled': true,
    'gdprCompliantDeletion': true,
    'sessionRemindersEnabled': true,
    'learningStreakAlertsEnabled': false,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _settingsData[key] = value;
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Einstellungen zurücksetzen',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Möchten Sie alle Einstellungen auf die Standardwerte zurücksetzen? Diese Aktion kann nicht rückgängig gemacht werden.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetToDefaults();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text('Zurücksetzen'),
            ),
          ],
        );
      },
    );
  }

  void _resetToDefaults() {
    setState(() {
      _settingsData['microphoneSensitivity'] = 0.5;
      _settingsData['noiseSuppressionEnabled'] = true;
      _settingsData['preferredAudioDevice'] = 'speaker';
      _settingsData['volumeLevel'] = 0.7;
      _settingsData['websocketTimeout'] = 30;
      _settingsData['autoReconnectEnabled'] = true;
      _settingsData['languageCode'] = 'de';
      _settingsData['voiceRecognitionOptimized'] = true;
      _settingsData['germanKeyboardEnabled'] = true;
      _settingsData['conversationStorageEnabled'] = true;
      _settingsData['gdprCompliantDeletion'] = true;
      _settingsData['sessionRemindersEnabled'] = true;
      _settingsData['learningStreakAlertsEnabled'] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Einstellungen wurden zurückgesetzt'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _showDeleteConversationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alle Gespräche löschen',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.errorLight,
            ),
          ),
          content: Text(
            'Möchten Sie wirklich alle gespeicherten Gespräche löschen? Diese Aktion kann nicht rückgängig gemacht werden und alle Ihre Lernfortschritte gehen verloren.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alle Gespräche wurden gelöscht'),
                    backgroundColor: AppTheme.errorLight,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getFilteredSections() {
    if (_searchQuery.isEmpty) {
      return [
        AudioSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
        SizedBox(height: 2.h),
        ConnectionSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
        SizedBox(height: 2.h),
        LanguageSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
        SizedBox(height: 2.h),
        PrivacySettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
          onDeleteConversations: _showDeleteConversationsDialog,
        ),
        SizedBox(height: 2.h),
        NotificationSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
        SizedBox(height: 2.h),
        SettingsSectionWidget(
          title: 'Allgemein',
          children: [
            SettingsItemWidget(
              title: 'Auf Standardwerte zurücksetzen',
              subtitle: 'Alle Einstellungen zurücksetzen',
              leadingIcon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.errorLight,
                size: 24,
              ),
              onTap: _showResetDialog,
              showTrailing: false,
            ),
          ],
        ),
      ];
    }

    // Filter sections based on search query
    List<Widget> filteredSections = [];
    String query = _searchQuery.toLowerCase();

    if ('audio mikrofon lautstärke'.contains(query)) {
      filteredSections.add(
        AudioSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
      );
    }

    if ('verbindung api websocket'.contains(query)) {
      filteredSections.add(
        ConnectionSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
      );
    }

    if ('sprache deutsch keyboard'.contains(query)) {
      filteredSections.add(
        LanguageSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
      );
    }

    if ('datenschutz privat gespräche'.contains(query)) {
      filteredSections.add(
        PrivacySettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
          onDeleteConversations: _showDeleteConversationsDialog,
        ),
      );
    }

    if ('benachrichtigung erinnerung'.contains(query)) {
      filteredSections.add(
        NotificationSettingsSectionWidget(
          settingsData: _settingsData,
          onSettingChanged: _updateSetting,
        ),
      );
    }

    if ('zurücksetzen standard'.contains(query)) {
      filteredSections.add(
        SettingsSectionWidget(
          title: 'Allgemein',
          children: [
            SettingsItemWidget(
              title: 'Auf Standardwerte zurücksetzen',
              subtitle: 'Alle Einstellungen zurücksetzen',
              leadingIcon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.errorLight,
                size: 24,
              ),
              onTap: _showResetDialog,
              showTrailing: false,
            ),
          ],
        ),
      );
    }

    return filteredSections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Einstellungen',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                AppTheme.textPrimaryLight,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                  AppTheme.textPrimaryLight,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hilfe-Funktion wird bald verfügbar sein'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Einstellungen durchsuchen...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.textSecondaryLight,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryLight,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),

          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getFilteredSections().isEmpty
                    ? [
                        SizedBox(height: 10.h),
                        Center(
                          child: Column(
                            children: [
                              CustomIconWidget(
                                iconName: 'search_off',
                                color: AppTheme.textSecondaryLight,
                                size: 48,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Keine Einstellungen gefunden',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Versuchen Sie einen anderen Suchbegriff',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : _getFilteredSections(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
