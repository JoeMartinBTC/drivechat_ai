import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/enhanced_logging_service.dart';
import '../../../services/connection_error_handler.dart';
import '../../../widgets/custom_icon_widget.dart';

class AdvancedTroubleshootingWidget extends StatefulWidget {
  final ConnectionErrorDetails errorDetails;
  final EnhancedLoggingService? loggingService;

  const AdvancedTroubleshootingWidget({
    super.key,
    required this.errorDetails,
    this.loggingService,
  });

  @override
  State<AdvancedTroubleshootingWidget> createState() =>
      _AdvancedTroubleshootingWidgetState();
}

class _AdvancedTroubleshootingWidgetState
    extends State<AdvancedTroubleshootingWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<Map<String, dynamic>> _mockApiEndpoints = [
    {
      'name': 'ElevenLabs API',
      'status': 'Offline',
      'latency': 'N/A',
      'isHealthy': false,
    },
    {
      'name': 'WebSocket Server',
      'status': 'Timeout',
      'latency': '5000ms+',
      'isHealthy': false,
    },
    {
      'name': 'Authentication',
      'status': 'Failed',
      'latency': 'N/A',
      'isHealthy': false,
    },
  ];

  final Map<String, dynamic> _mockConnectionMetrics = {
    'signalStrength': -72,
    'downloadSpeed': '12.3 Mbps',
    'uploadSpeed': '2.1 Mbps',
    'ping': '45ms',
    'packetLoss': '0.2%',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _exportLogs() {
    final logData = _generateLogData();
    Clipboard.setData(ClipboardData(text: logData));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Technical logs copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _generateLogData() {
    return '''
=== ADVANCED TROUBLESHOOTING REPORT ===
Timestamp: ${DateTime.now().toIso8601String()}
Error Type: ${widget.errorDetails.type}
Error Message: ${widget.errorDetails.message}

API Endpoint Status:
${_mockApiEndpoints.map((endpoint) => '- ${endpoint['name']}: ${endpoint['status']} (${endpoint['latency']})').join('\n')}

Connection Quality Metrics:
- Signal Strength: ${_mockConnectionMetrics['signalStrength']} dBm
- Download Speed: ${_mockConnectionMetrics['downloadSpeed']}
- Upload Speed: ${_mockConnectionMetrics['uploadSpeed']}
- Ping: ${_mockConnectionMetrics['ping']}
- Packet Loss: ${_mockConnectionMetrics['packetLoss']}

System Information:
- Platform: ${Theme.of(context).platform.name}
- User Agent: Flutter/GetMyLappen v1.0.0

Technical Details:
${widget.errorDetails.technicalDetails ?? 'No additional technical details available'}
    '''.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'settings',
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Advanced Troubleshooting',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: EdgeInsets.only(top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Endpoint Status
                  _buildSectionHeader('API Endpoint Status', Icons.api),
                  SizedBox(height: 1.h),
                  ..._mockApiEndpoints.map(
                    (endpoint) => _buildEndpointRow(endpoint),
                  ),

                  SizedBox(height: 3.h),

                  // Connection Quality Metrics
                  _buildSectionHeader(
                    'Connection Quality Metrics',
                    Icons.speed,
                  ),
                  SizedBox(height: 1.h),
                  _buildMetricsGrid(),

                  SizedBox(height: 3.h),

                  // Detailed Logs Section
                  if (widget.loggingService != null) ...[
                    _buildSectionHeader('Recent Error Logs', Icons.bug_report),
                    SizedBox(height: 1.h),
                    _buildErrorLogsList(),
                    SizedBox(height: 2.h),
                  ],

                  // Export Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _exportLogs,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            side: BorderSide(color: Colors.blue.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: CustomIconWidget(
                            iconName: 'download',
                            size: 16,
                            color: Colors.blue,
                          ),
                          label: Text(
                            'Export Logs',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 2.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEndpointRow(Map<String, dynamic> endpoint) {
    final isHealthy = endpoint['isHealthy'] as bool;
    final statusColor = isHealthy ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              endpoint['name'],
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Text(
            endpoint['status'],
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            endpoint['latency'],
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 2.w,
      mainAxisSpacing: 1.h,
      children:
          _mockConnectionMetrics.entries.map((entry) {
            return Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.key
                        .replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (match) => ' ${match.group(1)}',
                        )
                        .trim(),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildErrorLogsList() {
    // Mock error logs for demonstration
    final mockLogs = [
      {
        'time': '10:23:45',
        'level': 'ERROR',
        'message': 'WebSocket connection failed',
      },
      {'time': '10:23:42', 'level': 'WARN', 'message': 'API response timeout'},
      {
        'time': '10:23:40',
        'level': 'ERROR',
        'message': 'Authentication failed',
      },
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: 20.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mockLogs.length,
        itemBuilder: (context, index) {
          final log = mockLogs[index];
          final levelColor =
              log['level'] == 'ERROR'
                  ? Colors.red
                  : log['level'] == 'WARN'
                  ? Colors.orange
                  : Colors.white;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['time']!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade400,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.w,
                    vertical: 0.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log['level']!,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: levelColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    log['message']!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
