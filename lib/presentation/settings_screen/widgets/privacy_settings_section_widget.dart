import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_item_widget.dart';
import './settings_section_widget.dart';

class PrivacySettingsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;
  final VoidCallback onDeleteConversations;

  const PrivacySettingsSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
    required this.onDeleteConversations,
  });

  void _showDataExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Daten exportieren',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wählen Sie das Exportformat:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'description',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('JSON-Format'),
                subtitle: Text('Strukturierte Daten für technische Nutzung'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export wird vorbereitet...'),
                      backgroundColor: AppTheme.primaryLight,
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'text_snippet',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                title: Text('Text-Format'),
                subtitle: Text('Lesbare Textdatei'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export wird vorbereitet...'),
                      backgroundColor: AppTheme.primaryLight,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
          ],
        );
      },
    );
  }

  void _showGdprInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'DSGVO-Informationen',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ihre Rechte nach der DSGVO:',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                _buildGdprRight('Recht auf Auskunft',
                    'Sie können jederzeit Auskunft über Ihre gespeicherten Daten verlangen.'),
                _buildGdprRight('Recht auf Berichtigung',
                    'Sie können die Korrektur unrichtiger Daten verlangen.'),
                _buildGdprRight('Recht auf Löschung',
                    'Sie können die Löschung Ihrer Daten verlangen.'),
                _buildGdprRight('Recht auf Datenübertragbarkeit',
                    'Sie können Ihre Daten in einem strukturierten Format erhalten.'),
                SizedBox(height: 2.h),
                Text(
                  'Datenspeicherung:',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Gespräche werden lokal auf Ihrem Gerät gespeichert\n'
                  '• Audio-Daten werden nur während der Übertragung verarbeitet\n'
                  '• Keine Weitergabe an Dritte ohne Ihre Zustimmung\n'
                  '• Automatische Löschung nach 30 Tagen Inaktivität',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Verstanden'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGdprRight(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '  $description',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Datenschutz & Privatsphäre',
      children: [
        // Conversation Storage
        SettingsItemWidget(
          title: 'Gespräche speichern',
          subtitle: 'Unterhaltungen für Lernfortschritt speichern',
          leadingIcon: CustomIconWidget(
            iconName: 'save',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['conversationStorageEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('conversationStorageEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Data Export
        SettingsItemWidget(
          title: 'Daten exportieren',
          subtitle: 'Ihre Gespräche und Einstellungen exportieren',
          leadingIcon: CustomIconWidget(
            iconName: 'download',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showDataExportDialog(context),
        ),

        // Delete All Conversations
        SettingsItemWidget(
          title: 'Alle Gespräche löschen',
          subtitle: 'Alle gespeicherten Unterhaltungen entfernen',
          leadingIcon: CustomIconWidget(
            iconName: 'delete_forever',
            color: AppTheme.errorLight,
            size: 24,
          ),
          onTap: onDeleteConversations,
        ),

        // GDPR Compliance
        SettingsItemWidget(
          title: 'DSGVO-konforme Löschung',
          subtitle: 'Automatische Datenlöschung nach Inaktivität',
          leadingIcon: CustomIconWidget(
            iconName: 'verified_user',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['gdprCompliantDeletion'] as bool,
            onChanged: (value) {
              onSettingChanged('gdprCompliantDeletion', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // GDPR Information
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.primaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DSGVO-Informationen',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Ihre Rechte und unsere Datenschutzpraktiken',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showGdprInfo(context),
                child: Text('Mehr'),
              ),
            ],
          ),
        ),

        // Data Usage Statistics
        SettingsItemWidget(
          title: 'Datennutzung anzeigen',
          subtitle: 'Übersicht über gespeicherte Daten',
          leadingIcon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Datennutzung'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDataUsageItem('Gespeicherte Gespräche:', '23'),
                      _buildDataUsageItem('Speicherplatz:', '2.4 MB'),
                      _buildDataUsageItem('Letzte Aktivität:', 'Heute'),
                      _buildDataUsageItem(
                          'Durchschnittliche Sitzungsdauer:', '15 Min'),
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

  Widget _buildDataUsageItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
