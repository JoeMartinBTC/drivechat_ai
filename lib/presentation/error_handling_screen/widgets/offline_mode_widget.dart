import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_icon_widget.dart';

class OfflineModeWidget extends StatefulWidget {
  final bool isOfflineModeEnabled;
  final VoidCallback? onToggleOfflineMode;
  final VoidCallback? onContactSupport;

  const OfflineModeWidget({
    super.key,
    required this.isOfflineModeEnabled,
    this.onToggleOfflineMode,
    this.onContactSupport,
  });

  @override
  State<OfflineModeWidget> createState() => _OfflineModeWidgetState();
}

class _OfflineModeWidgetState extends State<OfflineModeWidget> {
  bool _isContactingSuppport = false;

  void _handleContactSupport() async {
    if (_isContactingSuppport || widget.onContactSupport == null) return;

    setState(() {
      _isContactingSuppport = true;
    });

    // Add delay for UX feedback
    await Future.delayed(const Duration(milliseconds: 1000));

    widget.onContactSupport!();

    if (mounted) {
      setState(() {
        _isContactingSuppport = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline Mode Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: widget.isOfflineModeEnabled
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isOfflineModeEnabled
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: widget.isOfflineModeEnabled
                          ? 'cloud_off'
                          : 'cloud_queue',
                      size: 20,
                      color: widget.isOfflineModeEnabled
                          ? Colors.orange
                          : Colors.grey.shade600,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Offline Mode',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.isOfflineModeEnabled
                              ? Colors.orange.shade700
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Switch(
                      value: widget.isOfflineModeEnabled,
                      onChanged: widget.onToggleOfflineMode != null
                          ? (value) => widget.onToggleOfflineMode!()
                          : null,
                      activeColor: Colors.orange,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Description
                Text(
                  widget.isOfflineModeEnabled
                      ? 'Offline mode is active. You can use basic app features without AI functionality.'
                      : 'Enable offline mode to use the app without network connectivity. AI features will be disabled.',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                if (widget.isOfflineModeEnabled) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Limited Functionality',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '• Voice conversations are disabled\n• Real-time AI responses unavailable\n• Local driving theory content only\n• Settings and history remain accessible',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.orange.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Contact Support Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'support_agent',
                      size: 20,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Need Help?',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                Text(
                  'Our support team can help you resolve connection issues and get GetMyLappen working properly.',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 3.h),

                // Contact Support Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isContactingSuppport ? null : _handleContactSupport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    icon: _isContactingSuppport
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'email',
                            size: 18,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isContactingSuppport
                          ? 'Opening Email...'
                          : 'Contact Support Team',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Support Info
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support will include:',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      ...[
                        'Pre-filled diagnostic information',
                        'Device specifications',
                        'Error logs and technical details',
                        'Step-by-step troubleshooting guide',
                      ].map(
                        (item) => Padding(
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
                                  item,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
