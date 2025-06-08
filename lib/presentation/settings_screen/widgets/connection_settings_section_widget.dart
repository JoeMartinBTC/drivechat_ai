import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_item_widget.dart';
import './settings_section_widget.dart';

// lib/presentation/settings_screen/widgets/connection_settings_section_widget.dart

class ConnectionSettingsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const ConnectionSettingsSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  void _showApiKeyDialog(BuildContext context) {
    final TextEditingController apiKeyController = TextEditingController(
      text: settingsData['apiKey'] as String,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ElevenLabs API-Schlüssel',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Geben Sie Ihren ElevenLabs API-Schlüssel ein:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: apiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'key',
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Ihr API-Schlüssel wird sicher gespeichert und verschlüsselt.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                onSettingChanged('apiKey', apiKeyController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API-Schlüssel wurde gespeichert'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeoutDialog(BuildContext context) {
    int currentTimeout = settingsData['websocketTimeout'] as int;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'WebSocket Timeout',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timeout-Dauer in Sekunden:',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text('10s'),
                      Expanded(
                        child: Slider(
                          value: currentTimeout.toDouble(),
                          min: 10,
                          max: 120,
                          divisions: 11,
                          label: '${currentTimeout}s',
                          onChanged: (value) {
                            setState(() {
                              currentTimeout = value.round();
                            });
                          },
                        ),
                      ),
                      Text('120s'),
                    ],
                  ),
                  Text(
                    'Aktuell: $currentTimeout Sekunden',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSettingChanged('websocketTimeout', currentTimeout);
                    Navigator.of(context).pop();
                  },
                  child: Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Verbindungseinstellungen',
      children: [
        // API Configuration - Navigate to dedicated screen
        SettingsItemWidget(
          title: 'API Configuration',
          subtitle: 'Configure ElevenLabs API key and agent settings',
          leadingIcon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.apiConfigurationScreen);
          },
        ),

        // API Key Configuration (Simplified)
        SettingsItemWidget(
          title: 'ElevenLabs API-Schlüssel',
          subtitle: settingsData['apiKey'] != null &&
                  (settingsData['apiKey'] as String).isNotEmpty
              ? '••••••••${(settingsData['apiKey'] as String).substring((settingsData['apiKey'] as String).length - 4)}'
              : 'Nicht konfiguriert',
          leadingIcon: CustomIconWidget(
            iconName: 'key',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showApiKeyDialog(context),
        ),

        // WebSocket Timeout
        SettingsItemWidget(
          title: 'WebSocket Timeout',
          subtitle: '${settingsData['websocketTimeout']} Sekunden',
          leadingIcon: CustomIconWidget(
            iconName: 'timer',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showTimeoutDialog(context),
        ),

        // Auto Reconnect
        SettingsItemWidget(
          title: 'Automatische Wiederverbindung',
          subtitle: 'Bei Verbindungsabbruch automatisch neu verbinden',
          leadingIcon: CustomIconWidget(
            iconName: 'sync',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['autoReconnectEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('autoReconnectEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Connection Status
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.successLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.successLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'wifi',
                color: AppTheme.successLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verbindungsstatus',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Verbunden - Letzte Prüfung: vor 2 Minuten',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.successLight,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verbindung wird getestet...'),
                    ),
                  );
                },
                child: Text('Testen'),
              ),
            ],
          ),
        ),

        // Network Quality
        SettingsItemWidget(
          title: 'Netzwerkqualität',
          subtitle: 'Aktuelle Verbindungsgeschwindigkeit anzeigen',
          leadingIcon: CustomIconWidget(
            iconName: 'network_check',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Netzwerkqualität'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ping:'),
                          Text('23 ms',
                              style: TextStyle(color: AppTheme.successLight)),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Download:'),
                          Text('45.2 Mbps',
                              style: TextStyle(color: AppTheme.successLight)),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Upload:'),
                          Text('12.8 Mbps',
                              style: TextStyle(color: AppTheme.successLight)),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Schließen'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
