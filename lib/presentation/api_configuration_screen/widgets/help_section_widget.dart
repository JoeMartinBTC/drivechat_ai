import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

// lib/presentation/api_configuration_screen/widgets/help_section_widget.dart

class HelpSectionWidget extends StatelessWidget {
  const HelpSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'help',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Help & Information',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          _buildHelpItem(
            'How to get an ElevenLabs API key',
            'Sign up at elevenlabs.io, go to your profile settings, and generate an API key.',
            'launch',
            () {
              // Implement URL launch to ElevenLabs API key page
              _showInformationDialog(
                context,
                'Get ElevenLabs API Key',
                'To get your ElevenLabs API key:\n\n'
                    '1. Create an account at elevenlabs.io\n'
                    '2. Log in to your account\n'
                    '3. Go to your profile settings\n'
                    '4. Click on "API" in the menu\n'
                    '5. Generate a new API key\n'
                    '6. Copy the key and paste it here\n\n'
                    'Note: ElevenLabs may offer different subscription tiers with varying API access levels.',
              );
            },
          ),

          _buildHelpItem(
            'Finding your ElevenLabs agent number',
            'Access your ElevenLabs dashboard, navigate to conversational agents, and copy your agent ID.',
            'launch',
            () {
              // Implement URL launch to ElevenLabs API key page
              _showInformationDialog(
                context,
                'Get Your Agent Number',
                'To find your ElevenLabs agent number:\n\n'
                    '1. Log in to your ElevenLabs account\n'
                    '2. Navigate to the Conversational AI section\n'
                    '3. Select your agent from the list\n'
                    '4. Find the agent ID/number in the agent details page\n'
                    '5. Copy the number and paste it in the agent number field\n\n'
                    'Note: The agent number is required to connect to your specific conversational AI agent.',
              );
            },
          ),

          _buildHelpItem(
            'Troubleshooting connection issues',
            'Check your internet connection, API key format, and ElevenLabs service status.',
            'build',
            () {
              _showInformationDialog(
                context,
                'Troubleshooting Connection',
                'If you are experiencing connection issues:\n\n'
                    '1. Check your internet connection\n'
                    '2. Verify your API key is correct and not expired\n'
                    '3. Ensure your agent number is correctly entered\n'
                    '4. Check if you have reached your API usage limits\n'
                    '5. Visit elevenlabs.io/status to check service status\n'
                    '6. Try again later if ElevenLabs services are experiencing downtime',
              );
            },
          ),

          _buildHelpItem(
            'Privacy and data security',
            'Learn how your API keys and voice data are protected in this app.',
            'security',
            () {
              _showInformationDialog(
                context,
                'Privacy & Security',
                'DriveChat AI takes your privacy seriously:\n\n'
                    '• Your API key is stored securely on your device only\n'
                    '• Your agent number is stored locally and never shared\n'
                    '• Voice recordings are processed temporarily and not permanently stored\n'
                    '• All communication with ElevenLabs is encrypted\n'
                    '• No conversation data is shared with third parties\n'
                    '• Optional biometric protection adds an extra layer of security\n\n'
                    'For more information, please see our privacy policy.',
              );
            },
          ),

          _buildHelpItem(
            'Contact support',
            'Need help? Reach out to our support team for assistance.',
            'support',
            () {
              _showInformationDialog(
                context,
                'Contact Support',
                'For assistance with DriveChat AI:\n\n'
                    'Email: support@drivechat-ai.com\n'
                    'Hours: Monday-Friday, 9AM-5PM CET\n\n'
                    'Please include the following in your support request:\n'
                    '• Your device model\n'
                    '• App version\n'
                    '• Description of the issue\n'
                    '• Screenshots (if applicable)\n\n'
                    'We typically respond within 24-48 hours.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
      String title, String description, String iconName, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textSecondaryLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInformationDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
