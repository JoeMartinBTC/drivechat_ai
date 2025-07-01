import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/connection_error_handler.dart';

class ErrorIconWidget extends StatefulWidget {
  final ConnectionErrorType errorType;
  final bool isAnimated;

  const ErrorIconWidget({
    super.key,
    required this.errorType,
    this.isAnimated = true,
  });

  @override
  State<ErrorIconWidget> createState() => _ErrorIconWidgetState();
}

class _ErrorIconWidgetState extends State<ErrorIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    if (widget.isAnimated) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getErrorIcon() {
    switch (widget.errorType) {
      case ConnectionErrorType.networkUnavailable:
        return Icons.wifi_off_rounded;
      case ConnectionErrorType.timeout:
        return Icons.timer_off_outlined;
      case ConnectionErrorType.serverError:
        return Icons.dns_outlined;
      case ConnectionErrorType.unauthorized:
      case ConnectionErrorType.apiKeyInvalid:
        return Icons.key_off_outlined;
      case ConnectionErrorType.quotaExceeded:
        return Icons.account_balance_wallet_outlined;
      case ConnectionErrorType.rateLimited:
        return Icons.speed_outlined;
      case ConnectionErrorType.dnsFailure:
        return Icons.router_outlined;
      case ConnectionErrorType.sslError:
        return Icons.security_outlined;
      default:
        return Icons.error_outline_rounded;
    }
  }

  Color _getErrorColor() {
    switch (widget.errorType) {
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
        return Colors.amber.shade700;
      case ConnectionErrorType.serverError:
        return Colors.purple;
      case ConnectionErrorType.sslError:
        return Colors.redAccent;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getConnectionStatus() {
    switch (widget.errorType) {
      case ConnectionErrorType.networkUnavailable:
        return 'Offline';
      case ConnectionErrorType.timeout:
        return 'Slow Connection';
      case ConnectionErrorType.serverError:
        return 'Server Down';
      case ConnectionErrorType.unauthorized:
      case ConnectionErrorType.apiKeyInvalid:
        return 'Access Denied';
      case ConnectionErrorType.quotaExceeded:
        return 'Quota Exceeded';
      case ConnectionErrorType.rateLimited:
        return 'Rate Limited';
      case ConnectionErrorType.dnsFailure:
        return 'DNS Failed';
      case ConnectionErrorType.sslError:
        return 'Security Error';
      default:
        return 'Connection Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = _getErrorColor();
    final icon = _getErrorIcon();
    final status = _getConnectionStatus();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Error Icon with Animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isAnimated ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: errorColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(child: Icon(icon, size: 10.w, color: errorColor)),
              ),
            );
          },
        ),

        SizedBox(height: 2.h),

        // Connection Status Indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: errorColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: errorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
