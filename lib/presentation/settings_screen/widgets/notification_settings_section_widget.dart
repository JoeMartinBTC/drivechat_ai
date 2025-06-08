import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_item_widget.dart';
import './settings_section_widget.dart';

class NotificationSettingsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> settingsData;
  final Function(String, dynamic) onSettingChanged;

  const NotificationSettingsSectionWidget({
    super.key,
    required this.settingsData,
    required this.onSettingChanged,
  });

  void _showReminderTimeDialog(BuildContext context) {
    TimeOfDay currentTime = TimeOfDay.now();

    showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
              hourMinuteTextColor: AppTheme.textPrimaryLight,
              dayPeriodTextColor: AppTheme.textPrimaryLight,
              dialHandColor: AppTheme.primaryLight,
              dialBackgroundColor: AppTheme.surfaceLight,
              hourMinuteColor: AppTheme.surfaceLight,
              dayPeriodColor: AppTheme.surfaceLight,
            ),
          ),
          child: child!,
        );
      },
    ).then((TimeOfDay? selectedTime) {
      if (selectedTime != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erinnerungszeit auf ${selectedTime.format(context)} gesetzt'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    });
  }

  void _showNotificationFrequencyDialog(BuildContext context) {
    final List<Map<String, dynamic>> frequencies = [
      {
        'value': 'daily',
        'label': 'Täglich',
        'description': 'Jeden Tag zur gleichen Zeit'
      },
      {
        'value': 'weekdays',
        'label': 'Wochentags',
        'description': 'Montag bis Freitag'
      },
      {
        'value': 'custom',
        'label': 'Benutzerdefiniert',
        'description': 'Bestimmte Wochentage auswählen'
      },
      {
        'value': 'off',
        'label': 'Aus',
        'description': 'Keine regelmäßigen Erinnerungen'
      },
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
                'Erinnerungshäufigkeit',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...frequencies.map((frequency) => ListTile(
                    title: Text(frequency['label']),
                    subtitle: Text(frequency['description']),
                    leading: Radio<String>(
                      value: frequency['value'],
                      groupValue: 'daily', // Mock current selection
                      onChanged: (String? value) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Häufigkeit auf "${frequency['label']}" gesetzt'),
                            backgroundColor: AppTheme.successLight,
                          ),
                        );
                      },
                      activeColor: AppTheme.primaryLight,
                    ),
                  )),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
      title: 'Benachrichtigungen',
      children: [
        // Session Reminders
        SettingsItemWidget(
          title: 'Sitzungserinnerungen',
          subtitle: 'Erinnerungen für regelmäßige Lerneinheiten',
          leadingIcon: CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['sessionRemindersEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('sessionRemindersEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Reminder Time (only show if reminders are enabled)
        if (settingsData['sessionRemindersEnabled'] as bool)
          SettingsItemWidget(
            title: 'Erinnerungszeit',
            subtitle: '18:00 Uhr',
            leadingIcon: CustomIconWidget(
              iconName: 'access_time',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            onTap: () => _showReminderTimeDialog(context),
          ),

        // Reminder Frequency (only show if reminders are enabled)
        if (settingsData['sessionRemindersEnabled'] as bool)
          SettingsItemWidget(
            title: 'Häufigkeit',
            subtitle: 'Täglich',
            leadingIcon: CustomIconWidget(
              iconName: 'repeat',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            onTap: () => _showNotificationFrequencyDialog(context),
          ),

        // Learning Streak Alerts
        SettingsItemWidget(
          title: 'Lernstreak-Benachrichtigungen',
          subtitle: 'Benachrichtigungen für Lernfortschritte',
          leadingIcon: CustomIconWidget(
            iconName: 'local_fire_department',
            color: AppTheme.warningLight,
            size: 24,
          ),
          trailing: Switch(
            value: settingsData['learningStreakAlertsEnabled'] as bool,
            onChanged: (value) {
              onSettingChanged('learningStreakAlertsEnabled', value);
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Achievement Notifications
        SettingsItemWidget(
          title: 'Erfolgs-Benachrichtigungen',
          subtitle: 'Bei erreichten Meilensteinen benachrichtigen',
          leadingIcon: CustomIconWidget(
            iconName: 'emoji_events',
            color: AppTheme.successLight,
            size: 24,
          ),
          trailing: Switch(
            value: true, // Mock value
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value
                      ? 'Erfolgs-Benachrichtigungen aktiviert'
                      : 'Erfolgs-Benachrichtigungen deaktiviert'),
                ),
              );
            },
            activeColor: AppTheme.primaryLight,
          ),
          showTrailing: false,
        ),

        // Do Not Disturb
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.textSecondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.textSecondaryLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'do_not_disturb',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Nicht stören',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Keine Benachrichtigungen zwischen 22:00 und 07:00 Uhr',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _showReminderTimeDialog(context),
                      child: Text('Startzeit ändern'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _showReminderTimeDialog(context),
                      child: Text('Endzeit ändern'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Notification Sound
        SettingsItemWidget(
          title: 'Benachrichtigungston',
          subtitle: 'Standard',
          leadingIcon: CustomIconWidget(
            iconName: 'notifications_active',
            color: AppTheme.primaryLight,
            size: 24,
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (BuildContext context) {
                final List<String> sounds = [
                  'Standard',
                  'Sanft',
                  'Klassisch',
                  'Modern',
                  'Stumm'
                ];
                return Container(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benachrichtigungston auswählen',
                        style: AppTheme.lightTheme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 2.h),
                      ...sounds.map((sound) => ListTile(
                            title: Text(sound),
                            leading: CustomIconWidget(
                              iconName:
                                  sound == 'Stumm' ? 'volume_off' : 'volume_up',
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                            trailing: sound == 'Standard'
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: AppTheme.successLight,
                                    size: 20,
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Benachrichtigungston auf "$sound" gesetzt'),
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
          },
        ),

        // Test Notification
        SettingsItemWidget(
          title: 'Test-Benachrichtigung',
          subtitle: 'Eine Beispiel-Benachrichtigung senden',
          leadingIcon: CustomIconWidget(
            iconName: 'send',
            color: AppTheme.accentLight,
            size: 24,
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'notifications',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Test-Benachrichtigung gesendet!'),
                  ],
                ),
                backgroundColor: AppTheme.accentLight,
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ],
    );
  }
}
