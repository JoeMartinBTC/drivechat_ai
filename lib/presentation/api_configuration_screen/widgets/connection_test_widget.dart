import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

// lib/presentation/api_configuration_screen/widgets/connection_test_widget.dart

class ConnectionTestWidget extends StatelessWidget {
  final bool isLoading;
  final String connectionStatus;
  final bool isConnected;
  final VoidCallback onTestConnection;
  final Map<String, dynamic>? connectionDetails;
  final bool? forceLiveApiMode; // New parameter to show force live mode status

  const ConnectionTestWidget({
    super.key,
    required this.isLoading,
    required this.connectionStatus,
    required this.isConnected,
    required this.onTestConnection,
    this.connectionDetails,
    this.forceLiveApiMode,
  });

  Color _getStatusColor() {
    if (isLoading) return AppTheme.warningLight;
    if (isConnected) {
      // Show different colors based on mode
      if (forceLiveApiMode == true) return AppTheme.successLight;
      if (connectionDetails?['subscription']?['tier'] == 'mock' ||
          connectionDetails?['subscription']?['status'] == 'demo') {
        return AppTheme.warningLight;
      }
      return AppTheme.successLight;
    }
    if (connectionStatus.contains('failed') ||
        connectionStatus.contains('error')) {
      return AppTheme.errorLight;
    }
    return AppTheme.textSecondaryLight;
  }

  IconData _getStatusIcon() {
    if (isLoading) return Icons.sync;
    if (isConnected) {
      if (forceLiveApiMode == true) return Icons.verified;
      if (connectionDetails?['subscription']?['tier'] == 'mock' ||
          connectionDetails?['subscription']?['status'] == 'demo') {
        return Icons.science;
      }
      return Icons.check_circle;
    }
    if (connectionStatus.contains('failed') ||
        connectionStatus.contains('error')) {
      return Icons.error;
    }
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3), width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Section Header
          Row(children: [
            CustomIconWidget(
                iconName: 'network_check',
                color: AppTheme.primaryLight,
                size: 24),
            SizedBox(width: 2.w),
            Text('Connection Test',
                style: AppTheme.lightTheme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),

            // Show mode indicator
            if (forceLiveApiMode == true) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'FORCE LIVE',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ] else if (connectionDetails?['subscription']?['tier'] == 'mock' ||
                connectionDetails?['subscription']?['status'] == 'demo') ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEMO MODE',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ]),

          SizedBox(height: 2.h),

          // Connection Status
          Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.3),
                      width: 1)),
              child: Row(children: [
                if (isLoading)
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_getStatusColor())))
                else
                  CustomIconWidget(
                      iconName: isConnected
                          ? (forceLiveApiMode == true
                              ? 'verified'
                              : (connectionDetails?['subscription']?['tier'] ==
                                          'mock' ||
                                      connectionDetails?['subscription']
                                              ?['status'] ==
                                          'demo'
                                  ? 'science'
                                  : 'check_circle'))
                          : connectionStatus.contains('failed')
                              ? 'error'
                              : 'help_outline',
                      color: _getStatusColor(),
                      size: 20),
                SizedBox(width: 2.w),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Status',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      Text(connectionStatus,
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w500)),
                    ])),
              ])),

          SizedBox(height: 2.h),

          // Test Connection Button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: isLoading ? null : onTestConnection,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading
                          ? AppTheme.textSecondaryLight
                          : (forceLiveApiMode == true
                              ? AppTheme.successLight
                              : AppTheme.primaryLight),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h)),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.backgroundLight))),
                              SizedBox(width: 2.w),
                              Text('Testing Connection...',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                          color: AppTheme.backgroundLight,
                                          fontWeight: FontWeight.w500)),
                            ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              CustomIconWidget(
                                  iconName: forceLiveApiMode == true
                                      ? 'verified'
                                      : 'sync',
                                  color: AppTheme.backgroundLight,
                                  size: 16),
                              SizedBox(width: 2.w),
                              Text(
                                  forceLiveApiMode == true
                                      ? 'Test Live API'
                                      : 'Test Connection',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                          color: AppTheme.backgroundLight,
                                          fontWeight: FontWeight.w500)),
                            ]))),

          // Additional Information
          if (isConnected && connectionDetails != null) ...[
            SizedBox(height: 2.h),
            Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Connection Details',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor())),
                        if (forceLiveApiMode == true) ...[
                          SizedBox(width: 2.w),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                  color: AppTheme.successLight
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('FORCE LIVE MODE',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppTheme.successLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10))),
                        ] else if (connectionDetails?['subscription']
                                    ?['tier'] ==
                                'mock' ||
                            connectionDetails?['subscription']?['status'] ==
                                'demo') ...[
                          SizedBox(width: 2.w),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                  color: AppTheme.warningLight
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('DEMO MODE',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppTheme.warningLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10))),
                        ],
                      ]),
                      SizedBox(height: 1.h),
                      _buildConnectionDetail(
                          'Subscription',
                          connectionDetails?['subscription']?['tier'] ??
                              'Unknown'),
                      _buildConnectionDetail('Available Characters',
                          '${connectionDetails?['subscription']?['character_count'] ?? 'Unknown'}'),
                      _buildConnectionDetail('Character Limit',
                          '${connectionDetails?['subscription']?['character_limit'] ?? 'Unknown'}'),
                      _buildConnectionDetail(
                          'Subscription Status',
                          connectionDetails?['subscription']?['status'] ??
                              'Unknown'),

                      // Add appropriate warnings
                      if (forceLiveApiMode == true) ...[
                        SizedBox(height: 1.h),
                        Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                                color: AppTheme.successLight
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppTheme.successLight
                                        .withValues(alpha: 0.3),
                                    width: 1)),
                            child: Row(children: [
                              CustomIconWidget(
                                  iconName: 'verified',
                                  color: AppTheme.successLight,
                                  size: 16),
                              SizedBox(width: 2.w),
                              Expanded(
                                  child: Text(
                                      'Force Live API Mode is active. The app will only use the live ElevenLabs API. Demo mode is disabled.',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.successLight,
                                              fontWeight: FontWeight.w500))),
                            ])),
                      ] else if (connectionDetails?['subscription']?['tier'] ==
                              'mock' ||
                          connectionDetails?['subscription']?['status'] ==
                              'demo') ...[
                        SizedBox(height: 1.h),
                        Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                                color: AppTheme.warningLight
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppTheme.warningLight
                                        .withValues(alpha: 0.3),
                                    width: 1)),
                            child: Row(children: [
                              CustomIconWidget(
                                  iconName: 'warning',
                                  color: AppTheme.warningLight,
                                  size: 16),
                              SizedBox(width: 2.w),
                              Expanded(
                                  child: Text(
                                      'You are connected to the demo service. Enable "Force Live ElevenLabs API" to access the real API and disable demo mode.',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.warningLight,
                                              fontWeight: FontWeight.w500))),
                            ])),
                      ],
                    ])),
          ] else if (connectionStatus.contains('failed')) ...[
            SizedBox(height: 2.h),
            Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color: AppTheme.errorLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Troubleshooting Tips',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.errorLight)),
                      SizedBox(height: 1.h),
                      _buildTroubleshootingTip(
                          '• Verify your API key is correct'),
                      _buildTroubleshootingTip(
                          '• Check your internet connection'),
                      _buildTroubleshootingTip(
                          '• Ensure you have API quota remaining'),
                      _buildTroubleshootingTip(
                          '• Try generating a new API key'),
                      _buildTroubleshootingTip(
                          '• Enable "Force Live API" if in demo mode'),
                    ])),
          ],
        ]));
  }

  Widget _buildConnectionDetail(String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: AppTheme.lightTheme.textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textSecondaryLight)),
          Text(value,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(), fontWeight: FontWeight.w500)),
        ]));
  }

  Widget _buildTroubleshootingTip(String tip) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.3.h),
        child: Text(tip,
            style: AppTheme.lightTheme.textTheme.bodySmall
                ?.copyWith(color: AppTheme.textSecondaryLight)));
  }
}
