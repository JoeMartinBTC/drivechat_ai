// lib/presentation/diagnostics_screen/widgets/mobile_diagnostics_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../../services/debug_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class MobileDiagnosticsWidget extends StatelessWidget {
  const MobileDiagnosticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final debugService = DebugService();
    final mobileDiagnostics = debugService.getMobileDiagnostics();

    if (!mobileDiagnostics['isMobile']) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'smartphone',
                color: Colors.blue,
                size: 24.sp,
              ),
              SizedBox(width: 8.sp),
              Text(
                'Mobile Platform Diagnostics',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.sp),

          // Operating System
          _buildInfoRow(
            context,
            'Operating System',
            mobileDiagnostics['operatingSystem'] ?? 'Unknown',
            Icons.phone_android,
          ),

          // Mobile Error Statistics
          _buildInfoRow(
            context,
            'Recent Mobile Errors',
            mobileDiagnostics['recentMobileErrors'].toString(),
            Icons.error_outline,
            valueColor: mobileDiagnostics['recentMobileErrors'] > 0
                ? Colors.red
                : Colors.green,
          ),

          _buildInfoRow(
            context,
            'Auth Errors on Mobile',
            mobileDiagnostics['authErrorsOnMobile'].toString(),
            Icons.security,
            valueColor: mobileDiagnostics['authErrorsOnMobile'] > 0
                ? Colors.red
                : Colors.green,
          ),

          _buildInfoRow(
            context,
            'Network Logs',
            mobileDiagnostics['networkLogsCount'].toString(),
            Icons.network_check,
          ),

          _buildInfoRow(
            context,
            'Total Mobile API Calls',
            mobileDiagnostics['totalMobileApiCalls'].toString(),
            Icons.api,
          ),

          // Mobile-specific issues indicator
          if (mobileDiagnostics['hasRecentMobileIssues'] == true) ...[
            SizedBox(height: 12.sp),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.sp),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20.sp),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Mobile Issues Detected',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        Text(
                          'Check connectivity and API configuration',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Mobile-specific recommendations
          SizedBox(height: 16.sp),
          Text(
            'Mobile Optimization Tips',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8.sp),

          ..._getMobileRecommendations(mobileDiagnostics).map(
            (recommendation) => Padding(
              padding: EdgeInsets.only(bottom: 4.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 8.sp),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getMobileRecommendations(Map<String, dynamic> diagnostics) {
    final recommendations = <String>[];

    // General mobile recommendations
    recommendations.add('Ensure stable network connection for API calls');
    recommendations.add('Monitor battery usage during extended voice sessions');

    // Error-specific recommendations
    if (diagnostics['authErrorsOnMobile'] > 0) {
      recommendations.add('Verify API key configuration and validity');
      recommendations.add('Check if API key has mobile app permissions');
    }

    if (diagnostics['recentMobileErrors'] > 0) {
      recommendations.add(
        'Switch between WiFi and mobile data to test connectivity',
      );
      recommendations.add('Clear app cache if errors persist');
    }

    if (diagnostics['networkLogsCount'] > 50) {
      recommendations.add(
        'High network activity detected - monitor data usage',
      );
    }

    // Platform-specific recommendations
    if (Platform.isAndroid) {
      recommendations.add('Check Android battery optimization settings');
      recommendations.add('Ensure microphone permissions are granted');
    } else if (Platform.isIOS) {
      recommendations.add('Verify iOS microphone and network permissions');
      recommendations.add('Check if Low Power Mode affects API performance');
    }

    return recommendations;
  }
}
