// lib/presentation/diagnostics_screen/widgets/system_info_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../../services/debug_service.dart';
import '../../../services/enhanced_logging_service.dart';

class SystemInfoWidget extends StatelessWidget {
  const SystemInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final debugService = DebugService();
    final loggingService = EnhancedLoggingService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Information',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.sp),

        // Platform Information
        _buildInfoSection(context, 'Platform Details', Icons.info_outline, [
          _InfoItem('Operating System', Platform.operatingSystem),
          _InfoItem(
            'Platform Type',
            Platform.isAndroid
                ? 'Android'
                : Platform.isIOS
                    ? 'iOS'
                    : Platform.isWindows
                        ? 'Windows'
                        : Platform.isMacOS
                            ? 'macOS'
                            : Platform.isLinux
                                ? 'Linux'
                                : 'Unknown',
          ),
          _InfoItem(
            'Is Mobile',
            (Platform.isAndroid || Platform.isIOS).toString(),
          ),
          _InfoItem('Debug Mode', _isDebugMode().toString()),
        ]),

        SizedBox(height: 20.sp),

        // App Information
        _buildInfoSection(context, 'Application Details', Icons.apps, [
          _InfoItem('App Name', 'GetMyLappen'),
          _InfoItem('Package Name', 'com.getmylappen.app'),
          _InfoItem(
            'Debug Service Active',
            debugService.isDebugEnabled.toString(),
          ),
          _InfoItem('Enhanced Logging', loggingService.isEnabled.toString()),
        ]),

        SizedBox(height: 20.sp),

        // Debug Statistics
        _buildInfoSection(
          context,
          'Debug Statistics',
          Icons.bug_report,
          _buildDebugStats(debugService),
        ),

        SizedBox(height: 20.sp),

        // System Capabilities
        _buildInfoSection(
          context,
          'System Capabilities',
          Icons.featured_play_list,
          [
            _InfoItem('Clipboard Access', 'Available'),
            _InfoItem('Network Detection', 'Available'),
            _InfoItem(
              'File System',
              Platform.isAndroid || Platform.isIOS
                  ? 'Sandboxed'
                  : 'Full Access',
            ),
            _InfoItem(
              'Permissions',
              Platform.isAndroid || Platform.isIOS ? 'Runtime' : 'System',
            ),
          ],
        ),

        SizedBox(height: 24.sp),

        // Export System Report Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                _exportSystemReport(context, debugService, loggingService),
            icon: const Icon(Icons.download),
            label: const Text('Export System Report'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<_InfoItem> items,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.sp),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          ...items.map(
            (item) => _buildInfoRow(context, item.label, item.value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  List<_InfoItem> _buildDebugStats(DebugService debugService) {
    final summary = debugService.getDebugSummary();

    return [
      _InfoItem('API Calls Logged', summary['totalApiCalls'].toString()),
      _InfoItem('Successful Calls', summary['successfulApiCalls'].toString()),
      _InfoItem('Failed Calls', summary['failedApiCalls'].toString()),
      _InfoItem('Auth Errors', summary['authenticationErrors'].toString()),
      if (summary['isMobile'] == true)
        _InfoItem('Mobile Errors', summary['mobileErrors'].toString()),
      _InfoItem('Messages Logged', summary['totalMessages'].toString()),
      _InfoItem('With Audio', summary['messagesWithAudio'].toString()),
    ];
  }

  bool _isDebugMode() {
    bool debugMode = false;
    assert(() {
      debugMode = true;
      return true;
    }());
    return debugMode;
  }

  void _exportSystemReport(
    BuildContext context,
    DebugService debugService,
    EnhancedLoggingService loggingService,
  ) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final platformInfo = {
        'operatingSystem': Platform.operatingSystem,
        'isMobile': Platform.isAndroid || Platform.isIOS,
        'debugMode': _isDebugMode(),
        'timestamp': timestamp,
      };

      final systemReport = '''
=== GetMyLappen System Report ===
Generated: $timestamp

=== Platform Information ===
Operating System: ${platformInfo['operatingSystem']}
Platform Type: ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : Platform.isWindows ? 'Windows' : Platform.isMacOS ? 'macOS' : Platform.isLinux ? 'Linux' : 'Unknown'}
Is Mobile: ${platformInfo['isMobile']}
Debug Mode: ${platformInfo['debugMode']}

=== Application Details ===
App Name: GetMyLappen
Package Name: com.getmylappen.app
Debug Service: ${debugService.isDebugEnabled}
Enhanced Logging: ${loggingService.isEnabled}

=== Debug Summary ===
${debugService.getDebugSummary().entries.map((e) => '${e.key}: ${e.value}').join('\n')}

=== Performance Metrics ===
${loggingService.getPerformanceMetrics().entries.map((e) => '${e.key}: ${e.value}').join('\n')}

=== Mobile Diagnostics ===
${debugService.getMobileDiagnostics().entries.map((e) => '${e.key}: ${e.value}').join('\n')}
''';

      Clipboard.setData(ClipboardData(text: systemReport));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('System report exported to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export system report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}
