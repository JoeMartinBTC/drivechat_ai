// lib/widgets/connection_error_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/connection_error_handler.dart';
import '../widgets/custom_icon_widget.dart';
import '../theme/app_theme.dart';

class ConnectionErrorWidget extends StatefulWidget {
  final ConnectionErrorDetails errorDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;
  final bool isFullScreen;

  const ConnectionErrorWidget({
    super.key,
    required this.errorDetails,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = true,
    this.isFullScreen = false,
  });

  @override
  State<ConnectionErrorWidget> createState() => _ConnectionErrorWidgetState();
}

class _ConnectionErrorWidgetState extends State<ConnectionErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getErrorColor() {
    switch (widget.errorDetails.type) {
      case ConnectionErrorType.networkUnavailable:
      case ConnectionErrorType.timeout:
      case ConnectionErrorType.dnsFailure:
        return Colors.orange;
      case ConnectionErrorType.unauthorized:
      case ConnectionErrorType.apiKeyInvalid:
        return Colors.red;
      case ConnectionErrorType.quotaExceeded:
        return Colors.deepOrange;
      case ConnectionErrorType.rateLimited:
        return Colors.amber;
      case ConnectionErrorType.serverError:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getErrorIcon() {
    switch (widget.errorDetails.type) {
      case ConnectionErrorType.networkUnavailable:
        return Icons.wifi_off;
      case ConnectionErrorType.timeout:
        return Icons.timer_off;
      case ConnectionErrorType.unauthorized:
      case ConnectionErrorType.apiKeyInvalid:
        return Icons.key_off;
      case ConnectionErrorType.quotaExceeded:
        return Icons.account_balance_wallet;
      case ConnectionErrorType.rateLimited:
        return Icons.speed;
      case ConnectionErrorType.serverError:
        return Icons.dns;
      case ConnectionErrorType.dnsFailure:
        return Icons.router;
      case ConnectionErrorType.sslError:
        return Icons.security;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    switch (widget.errorDetails.type) {
      case ConnectionErrorType.networkUnavailable:
        return 'Keine Internetverbindung';
      case ConnectionErrorType.timeout:
        return 'Verbindung zu langsam';
      case ConnectionErrorType.unauthorized:
      case ConnectionErrorType.apiKeyInvalid:
        return 'API-Schlüssel ungültig';
      case ConnectionErrorType.quotaExceeded:
        return 'Kontingent aufgebraucht';
      case ConnectionErrorType.rateLimited:
        return 'Zu viele Anfragen';
      case ConnectionErrorType.serverError:
        return 'Server nicht verfügbar';
      case ConnectionErrorType.dnsFailure:
        return 'Serveradresse nicht gefunden';
      case ConnectionErrorType.sslError:
        return 'Sicherheitsfehler';
      default:
        return 'Verbindungsfehler';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      return _buildFullScreenError();
    } else {
      return _buildInlineError();
    }
  }

  Widget _buildFullScreenError() {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildErrorIcon(size: 80),
                SizedBox(height: 3.h),
                _buildErrorContent(),
                SizedBox(height: 4.h),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineError() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getErrorColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getErrorColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildErrorIcon(size: 24),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getErrorTitle(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getErrorColor(),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      widget.errorDetails.userFriendlyMessage,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onDismiss != null)
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: CustomIconWidget(
                    iconName: 'close',
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          if (widget.errorDetails.recoveryActions.isNotEmpty) ...[
            SizedBox(height: 2.h),
            _buildRecoveryActions(),
          ],
          if (widget.showRetryButton && widget.errorDetails.canRetry) ...[
            SizedBox(height: 2.h),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorIcon({required double size}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getErrorColor().withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getErrorIcon(),
              color: _getErrorColor(),
              size: size * 0.6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent() {
    return Column(
      children: [
        Text(
          _getErrorTitle(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _getErrorColor(),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.errorDetails.userFriendlyMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
        ),
        if (widget.errorDetails.recoveryActions.isNotEmpty) ...[
          SizedBox(height: 3.h),
          _buildRecoveryActions(),
        ],
      ],
    );
  }

  Widget _buildRecoveryActions() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                size: 16,
                color: Colors.amber[700],
              ),
              SizedBox(width: 2.w),
              Text(
                'Lösungsvorschläge:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
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
                      color: Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      action,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[700],
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.showRetryButton && widget.errorDetails.canRetry)
          _buildRetryButton(),
        if (widget.onDismiss != null) ...[
          SizedBox(height: 2.h),
          TextButton(
            onPressed: widget.onDismiss,
            child: Text(
              'Schließen',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isRetrying ? null : _handleRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getErrorColor(),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: _isRetrying
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : CustomIconWidget(
                iconName: 'refresh',
                size: 16,
                color: Colors.white,
              ),
        label: Text(
          _isRetrying ? 'Wird wiederholt...' : 'Erneut versuchen',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    // Add a small delay to show the loading state
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onRetry!();

    // Reset retry state after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    });
  }
}
