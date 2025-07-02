// lib/presentation/diagnostics_screen/widgets/error_log_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_icon_widget.dart';

class ErrorLogCardWidget extends StatefulWidget {
  final Map<String, dynamic> errorLog;
  final VoidCallback? onRetry;

  const ErrorLogCardWidget({super.key, required this.errorLog, this.onRetry});

  @override
  State<ErrorLogCardWidget> createState() => _ErrorLogCardWidgetState();
}

class _ErrorLogCardWidgetState extends State<ErrorLogCardWidget> {
  bool _isExpanded = false;

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Color _getErrorColor() {
    if (widget.errorLog['isCritical'] == true) {
      return Colors.red;
    }
    return Colors.orange;
  }

  IconData _getErrorIcon() {
    if (widget.errorLog['isCritical'] == true) {
      return Icons.dangerous;
    }
    return Icons.warning;
  }

  void _copyErrorDetails() {
    final errorDetails = '''
Error: ${widget.errorLog['error']}
Category: ${widget.errorLog['category']}
Timestamp: ${widget.errorLog['timestamp']}
Platform: ${widget.errorLog['platform']}
Critical: ${widget.errorLog['isCritical']}
${widget.errorLog['context'] != null ? 'Context: ${widget.errorLog['context']}' : ''}
${widget.errorLog['stackTrace'] != null ? 'Stack Trace: ${widget.errorLog['stackTrace']}' : ''}
''';

    Clipboard.setData(ClipboardData(text: errorDetails));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = _getErrorColor();
    final errorIcon = _getErrorIcon();

    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12.sp),
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(errorIcon, color: errorColor, size: 20.sp),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          widget.errorLog['category'] ?? 'Unknown',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: errorColor,
                          ),
                        ),
                      ),
                      if (widget.errorLog['isCritical'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.sp,
                            vertical: 2.sp,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          child: Text(
                            'CRITICAL',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      SizedBox(width: 8.sp),
                      Text(
                        _formatTimestamp(widget.errorLog['timestamp']),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    widget.errorLog['error'] ?? 'No error message',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: _isExpanded ? null : 2,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                  ),

                  // Platform indicator
                  if (widget.errorLog['platform'] != null) ...[
                    SizedBox(height: 8.sp),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: widget.errorLog['isMobile'] == true
                              ? 'smartphone'
                              : 'computer',
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4.sp),
                        Text(
                          widget.errorLog['platform'],
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded details
          if (_isExpanded) ...[
            Divider(height: 1, color: errorColor.withValues(alpha: 0.2)),
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Context information
                  if (widget.errorLog['context'] != null &&
                      (widget.errorLog['context'] as Map).isNotEmpty) ...[
                    Text(
                      'Context',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.sp),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        widget.errorLog['context'].toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.sp),
                  ],

                  // Recovery suggestions
                  if (widget.errorLog['recoverySuggestions'] != null &&
                      (widget.errorLog['recoverySuggestions'] as List)
                          .isNotEmpty) ...[
                    Text(
                      'Recovery Suggestions',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    ...(widget.errorLog['recoverySuggestions'] as List).map(
                      (suggestion) => Container(
                        margin: EdgeInsets.only(bottom: 4.sp),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                suggestion.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.sp),
                  ],

                  // Stack trace (if available)
                  if (widget.errorLog['stackTrace'] != null) ...[
                    Text(
                      'Stack Trace',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxHeight: 150.sp),
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.sp),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.errorLog['stackTrace'],
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.sp),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyErrorDetails,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Details'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      if (widget.onRetry != null) ...[
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onRetry,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
