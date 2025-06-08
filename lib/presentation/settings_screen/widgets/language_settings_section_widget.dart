import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_item_widget.dart';
import './settings_section_widget.dart';

class LanguageSettingsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const LanguageSettingsSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  void _showLanguageSelection(BuildContext context) {
    final List<Map<String, String>> languages = [
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sprache auswählen',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...languages.map((language) => ListTile(
                    leading: Text(
                      language['flag']!,
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(language['name']!),
                    trailing: settingsData['languageCode'] == language['code']
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.successLight,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onSettingChanged('languageCode', language['code']);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Sprache wurde auf ${language['name']} geändert'),
                          backgroundColor: AppTheme.successLight,
                        ),
                      );
                    },
                  )),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'de':
        return 'Deutsch 🇩🇪';
      case 'en':
        return 'English 🇺🇸';
      case 'fr':
        return 'Français 🇫🇷';
      case 'es':
        return 'Español 🇪🇸';
      case 'it':
        return 'Italiano 🇮🇹';
      default:
        return 'Unbekannt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Sprach-Einstellungen',
      children: [
        // Language Selection
        SettingsItemWidget(
          title: 'App-Sprache',
          subtitle:
              _getLanguageDisplayName(settingsData['languageCode'] as String),
          leadingIcon: CustomIconWidget(
            iconName: 'language',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () => _showLanguageSelection(context),
        ),

        // Voice Recognition Optimization
        SettingsItemWidget(
          title: 'Spracherkennung optimiert',
          subtitle: 'Für deutsche Aussprache optimiert',
          leadingIcon: CustomIconWidget(
            iconName: 'record_voice_over',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['voiceRecognitionOptimized'] as bool,
            onChanged: (value) {
              onSettingChanged('voiceRecognitionOptimized', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // German Keyboard Layout
        SettingsItemWidget(
          title: 'Deutsche Tastatur',
          subtitle: 'QWERTZ-Layout mit Umlauten verwenden',
          leadingIcon: CustomIconWidget(
            iconName: 'keyboard',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['germanKeyboardEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('germanKeyboardEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Driving Terminology
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
                iconName: 'school',
                color: AppTheme.primaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fahrschul-Terminologie',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Deutsche Verkehrsregeln und Fachbegriffe',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 20,
              ),
            ],
          ),
        ),

        // Regional Settings
        SettingsItemWidget(
          title: 'Regionale Einstellungen',
          subtitle: 'Datum, Zeit und Maßeinheiten',
          leadingIcon: CustomIconWidget(
            iconName: 'location_on',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Regionale Einstellungen'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRegionalSetting('Datumsformat:', 'DD.MM.YYYY'),
                      SizedBox(height: 1.h),
                      _buildRegionalSetting('Zeitformat:', '24-Stunden'),
                      SizedBox(height: 1.h),
                      _buildRegionalSetting(
                          'Dezimaltrennzeichen:', 'Komma (,)'),
                      SizedBox(height: 1.h),
                      _buildRegionalSetting('Währung:', 'Euro (€)'),
                      SizedBox(height: 1.h),
                      _buildRegionalSetting('Geschwindigkeit:', 'km/h'),
                      SizedBox(height: 1.h),
                      _buildRegionalSetting('Entfernung:', 'Meter/Kilometer'),
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

  Widget _buildRegionalSetting(String label, String value) {
    return Row(
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
    );
  }
}
