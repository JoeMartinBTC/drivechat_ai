import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../services/connection_error_handler.dart';
import '../../../widgets/custom_icon_widget.dart';

class DiagnosticInfoWidget extends StatefulWidget {
  final ConnectionErrorDetails errorDetails;
  final bool showAdvancedInfo;

  const DiagnosticInfoWidget({
    super.key,
    required this.errorDetails,
    this.showAdvancedInfo = false,
  });

  @override
  State<DiagnosticInfoWidget> createState() => _DiagnosticInfoWidgetState();
}

class _DiagnosticInfoWidgetState extends State<DiagnosticInfoWidget> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  String _timestamp = '';
  String _errorCode = '';

  @override
  void initState() {
    super.initState();
    _initDiagnostics();
  }

  void _initDiagnostics() {
    _timestamp = DateTime.now().toIso8601String();
    _errorCode = _generateErrorCode();
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      if (mounted) {
        setState(() {
          _connectivityResult = result;
        });
      }
    } catch (e) {
      // Handle connectivity check error
    }
  }

  String _generateErrorCode() {
    final typeCode =
        widget.errorDetails.type.toString().split('.').last.toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    return 'ERR-$typeCode-$timestamp';
  }

  String _getNetworkStatusText() {
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi Connected';
      case ConnectivityResult.mobile:
        return 'Mobile Data Connected';
      case ConnectivityResult.ethernet:
        return 'Ethernet Connected';
      case ConnectivityResult.vpn:
        return 'VPN Connected';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth Connected';
      case ConnectivityResult.other:
        return 'Other Connection';
      case ConnectivityResult.none:
      default:
        return 'No Connection';
    }
  }

  Color _getNetworkStatusColor() {
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return Colors.green;
      case ConnectivityResult.vpn:
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.other:
        return Colors.orange;
      case ConnectivityResult.none:
      default:
        return Colors.red;
    }
  }

  void _copyDiagnostics() {
    final diagnosticsText =
        '''
Error Code: $_errorCode
Timestamp: $_timestamp
Error Type: ${widget.errorDetails.type.toString()}
Message: ${widget.errorDetails.message}
Network Status: ${_getNetworkStatusText()}
Can Retry: ${widget.errorDetails.canRetry}
${widget.errorDetails.technicalDetails != null ? 'Technical Details: ${widget.errorDetails.technicalDetails}' : ''}
    '''.trim();

    Clipboard.setData(ClipboardData(text: diagnosticsText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Diagnostics copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(iconName: 'info', size: 20, color: Colors.blue),
              SizedBox(width: 2.w),
              Text(
                'Diagnostic Information',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _copyDiagnostics,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'copy',
                        size: 14,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Copy',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Basic Info
          _buildInfoRow('Error Code', _errorCode, Icons.qr_code_2),
          _buildInfoRow(
            'Timestamp',
            _formatTimestamp(_timestamp),
            Icons.access_time,
          ),
          _buildNetworkStatusRow(),

          if (widget.showAdvancedInfo) ...[
            SizedBox(height: 2.h),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 2.h),

            // Advanced Info
            _buildInfoRow(
              'Error Type',
              widget.errorDetails.type.toString().split('.').last,
              Icons.category,
            ),
            if (widget.errorDetails.technicalDetails != null)
              _buildInfoRow(
                'Technical Details',
                widget.errorDetails.technicalDetails!,
                Icons.code,
                isMultiline: true,
              ),
            _buildInfoRow(
              'Can Retry',
              widget.errorDetails.canRetry ? 'Yes' : 'No',
              widget.errorDetails.canRetry ? Icons.refresh : Icons.block,
            ),
            if (widget.errorDetails.retryAfter != null)
              _buildInfoRow(
                'Retry After',
                '${widget.errorDetails.retryAfter!.inSeconds}s',
                Icons.timer,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 3.w),
          SizedBox(
            width: 20.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey.shade800,
              ),
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusRow() {
    final statusColor = _getNetworkStatusColor();
    final statusText = _getNetworkStatusText();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(Icons.network_check, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 3.w),
          SizedBox(
            width: 20.w,
            child: Text(
              'Network',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
