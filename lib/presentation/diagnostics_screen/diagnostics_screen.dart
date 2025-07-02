// lib/presentation/diagnostics_screen/diagnostics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/enhanced_logging_service.dart';
import '../../services/debug_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/error_log_card_widget.dart';
import './widgets/performance_metrics_widget.dart';
import './widgets/mobile_diagnostics_widget.dart';
import './widgets/system_info_widget.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen>
    with TickerProviderStateMixin {
  final EnhancedLoggingService _loggingService = EnhancedLoggingService();
  final DebugService _debugService = DebugService();
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loggingService.initialize();
    _loggingService.logUserInteraction(
      'screen_view',
      screen: 'diagnostics',
      data: {'source': 'navigation'},
    );
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);

    _loggingService.logEvent(
      'DiagnosticsScreen',
      'Manual refresh triggered',
      {},
    );

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isRefreshing = false);
  }

  void _exportLogs() {
    try {
      final diagnosticsReport = _loggingService.exportAllLogs();
      final debugLogs = _debugService.exportLogs();

      final combinedLogs = '''$diagnosticsReport

$debugLogs''';

      Clipboard.setData(ClipboardData(text: combinedLogs));

      _loggingService.logUserInteraction(
        'export_logs',
        screen: 'diagnostics',
        data: {'success': true},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete diagnostics exported to clipboard'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Share',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Implement sharing functionality
            },
          ),
        ),
      );
    } catch (e) {
      _loggingService.logError(
        'DiagnosticsScreen',
        'Failed to export logs: $e',
        isCritical: false,
        recoverySuggestions: ['Try again', 'Check clipboard permissions'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export logs'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearAllLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Logs'),
        content: const Text(
          'Are you sure you want to clear all diagnostic logs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _loggingService.clearAllLogs();
              _debugService.clearLogs();

              Navigator.pop(context);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All logs cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'App Diagnostics',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _refresh,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.sp,
                  ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportLogs();
                  break;
                case 'clear':
                  _clearAllLogs();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear Logs', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Errors'),
            Tab(text: 'Performance'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildErrorsTab(),
          _buildPerformanceTab(),
          _buildSystemTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final diagnostics = _loggingService.getDiagnosticsReport();
    final metrics = diagnostics['metrics'] as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.sp),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'health_and_safety',
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        'App Health Status',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp),
                  _buildHealthIndicator(metrics),
                ],
              ),
            ),

            SizedBox(height: 20.sp),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Events',
                    metrics['totalEvents'].toString(),
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: _buildStatCard(
                    'Error Rate',
                    '${metrics['errorRate']}%',
                    Icons.error_outline,
                    double.parse(metrics['errorRate']) > 10
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.sp),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Critical Errors',
                    metrics['criticalErrors'].toString(),
                    Icons.warning,
                    metrics['criticalErrors'] > 0 ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: _buildStatCard(
                    'User Actions',
                    metrics['userInteractions'].toString(),
                    Icons.touch_app,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.sp),

            // Recent Critical Issues
            if (metrics['criticalErrors'] > 0) ...[
              Text(
                '🚨 Critical Issues Detected',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8.sp),
              ...(_loggingService.getCriticalErrors().take(3).map(
                    (error) => Container(
                      margin: EdgeInsets.only(bottom: 8.sp),
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.sp),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[${error['category']}] ${error['error']}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          if (error['recoverySuggestions'] != null &&
                              (error['recoverySuggestions'] as List).isNotEmpty)
                            Text(
                              'Suggested fix: ${(error['recoverySuggestions'] as List).first}',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.red.shade700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
            ],

            // Mobile-specific information
            if (diagnostics['platform']['isMobile'] == true) ...[
              SizedBox(height: 20.sp),
              MobileDiagnosticsWidget(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(Map<String, dynamic> metrics) {
    final errorRate = double.parse(metrics['errorRate']);
    final criticalErrors = metrics['criticalErrors'] as int;
    final diagnostics = _loggingService.getDiagnosticsReport();

    Color healthColor;
    String healthStatus;
    IconData healthIcon;

    if (criticalErrors > 0) {
      healthColor = Colors.red;
      healthStatus = 'Critical Issues Detected';
      healthIcon = Icons.dangerous;
    } else if (errorRate > 15) {
      healthColor = Colors.orange;
      healthStatus = 'High Error Rate';
      healthIcon = Icons.warning;
    } else if (errorRate > 5) {
      healthColor = Colors.yellow.shade700;
      healthStatus = 'Minor Issues';
      healthIcon = Icons.info;
    } else {
      healthColor = Colors.green;
      healthStatus = 'Healthy';
      healthIcon = Icons.check_circle;
    }

    return Row(
      children: [
        Icon(healthIcon, color: healthColor, size: 20.sp),
        SizedBox(width: 8.sp),
        Text(
          healthStatus,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: healthColor,
          ),
        ),
        const Spacer(),
        if (diagnostics['platform']['isMobile'] == true)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Text(
              'MOBILE',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.sp),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsTab() {
    final recentErrors = _loggingService.getRecentErrors(limit: 20);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: recentErrors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    size: 48.sp,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16.sp),
                  Text(
                    'No Errors Found',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'The app is running smoothly',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.sp),
              itemCount: recentErrors.length,
              itemBuilder: (context, index) {
                return ErrorLogCardWidget(
                  errorLog: recentErrors[index],
                  onRetry: () {
                    // TODO: Implement retry logic based on error type
                    _loggingService.logUserInteraction(
                      'retry_error',
                      screen: 'diagnostics',
                      data: {'errorId': recentErrors[index]['id']},
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildPerformanceTab() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [PerformanceMetricsWidget(loggingService: _loggingService)],
        ),
      ),
    );
  }

  Widget _buildSystemTab() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(children: [SystemInfoWidget()]),
      ),
    );
  }
}
