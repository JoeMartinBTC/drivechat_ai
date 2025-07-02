import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/connection_error_handler.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecoveryActionsWidget extends StatefulWidget {
  final ConnectionErrorDetails errorDetails;
  final VoidCallback? onRetryConnection;
  final VoidCallback? onCheckNetwork;
  final VoidCallback? onSkipSetup;
  final VoidCallback? onContactSupport;

  const RecoveryActionsWidget({
    super.key,
    required this.errorDetails,
    this.onRetryConnection,
    this.onCheckNetwork,
    this.onSkipSetup,
    this.onContactSupport,
  });

  @override
  State<RecoveryActionsWidget> createState() => _RecoveryActionsWidgetState();
}

class _RecoveryActionsWidgetState extends State<RecoveryActionsWidget> {
  bool _isRetrying = false;
  int _retryAttempts = 0;

  void _handleRetryConnection() async {
    if (_isRetrying || widget.onRetryConnection == null) return;

    setState(() {
      _isRetrying = true;
      _retryAttempts++;
    });

    // Add delay for UX feedback
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onRetryConnection!();

    // Reset retry state after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(iconName: 'build', size: 20, color: Colors.blue),
              SizedBox(width: 2.w),
              Text(
                'Recovery Actions',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Primary Actions
          if (widget.errorDetails.canRetry) ...[
            _buildPrimaryActionButton(
              'Retry Connection',
              'Attempt to reconnect to services',
              Icons.refresh,
              _isRetrying ? null : _handleRetryConnection,
              isLoading: _isRetrying,
              color: Colors.blue,
            ),
            SizedBox(height: 2.h),
          ],

          // Secondary Actions Row
          Row(
            children: [
              Expanded(
                child: _buildSecondaryActionButton(
                  'Check Network',
                  Icons.network_check,
                  widget.onCheckNetwork,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSecondaryActionButton(
                  'Skip Setup',
                  Icons.skip_next,
                  widget.onSkipSetup,
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Recovery Suggestions
          if (widget.errorDetails.recoveryActions.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Suggested Solutions',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  ...widget.errorDetails.recoveryActions.map(
                    (action) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.3.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              action,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Retry Information
          if (_retryAttempts > 0) ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Retry attempts: $_retryAttempts',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Contact Support Button
          _buildContactSupportButton(),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    bool isLoading = false,
    Color color = Colors.blue,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                        )
                      : Icon(icon, color: color, size: 6.w),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    String title,
    IconData icon,
    VoidCallback? onTap,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 6.w),
              SizedBox(height: 1.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSupportButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.onContactSupport,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: CustomIconWidget(
          iconName: 'support_agent',
          size: 18,
          color: Colors.grey.shade600,
        ),
        label: Text(
          'Contact Support',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
