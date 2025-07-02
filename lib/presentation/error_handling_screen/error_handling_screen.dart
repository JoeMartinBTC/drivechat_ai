import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/connection_error_handler.dart';
import '../../services/enhanced_logging_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/error_icon_widget.dart';
import './widgets/diagnostic_info_widget.dart';
import './widgets/recovery_actions_widget.dart';
import './widgets/advanced_troubleshooting_widget.dart';
import './widgets/offline_mode_widget.dart';

class ErrorHandlingScreen extends StatefulWidget {
  final ConnectionErrorDetails? errorDetails;
  final String? customErrorMessage;
  final VoidCallback? onRetryCallback;

  const ErrorHandlingScreen({
    super.key,
    this.errorDetails,
    this.customErrorMessage,
    this.onRetryCallback,
  });

  @override
  State<ErrorHandlingScreen> createState() => _ErrorHandlingScreenState();
}

class _ErrorHandlingScreenState extends State<ErrorHandlingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _progressAnimation;

  final ConnectionErrorHandler _errorHandler = ConnectionErrorHandler();
  final EnhancedLoggingService _loggingService = EnhancedLoggingService();

  ConnectionErrorDetails? _currentErrorDetails;
  bool _isOfflineModeEnabled = false;
  bool _isRetrying = false;
  int _retryProgress = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeErrorHandling();
  }

  void _setupAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.easeIn),
    );

    _slideUpAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _mainAnimationController.forward();
  }

  void _initializeErrorHandling() async {
    await _loggingService.initialize();

    // Log screen access
    _loggingService.logUserInteraction(
      'screen_view',
      screen: 'error_handling',
      data: {
        'error_type': widget.errorDetails?.type.toString(),
        'custom_message': widget.customErrorMessage,
      },
    );

    // Set current error details
    if (widget.errorDetails != null) {
      _currentErrorDetails = widget.errorDetails;
    } else if (widget.customErrorMessage != null) {
      _currentErrorDetails = ConnectionErrorDetails(
        type: ConnectionErrorType.unknown,
        message: widget.customErrorMessage!,
        userFriendlyMessage: widget.customErrorMessage!,
        canRetry: true,
        recoveryActions: [
          'Überprüfen Sie Ihre Internetverbindung',
          'Starten Sie die App neu',
          'Versuchen Sie es später erneut',
        ],
      );
    } else {
      // Default splash screen timeout error
      _currentErrorDetails = ConnectionErrorDetails(
        type: ConnectionErrorType.timeout,
        message: 'Splash screen initialization timeout',
        userFriendlyMessage:
            'Die App-Initialisierung dauert zu lange. Möglicherweise liegt ein Verbindungsproblem vor.',
        canRetry: true,
        recoveryActions: [
          'Überprüfen Sie Ihre Internetverbindung',
          'Stellen Sie sicher, dass Sie eine stabile Verbindung haben',
          'Versuchen Sie es mit WLAN statt Mobilfunk',
          'Starten Sie die App neu',
        ],
      );
    }
  }

  void _handleRetryConnection() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _retryProgress = 0;
    });

    _loggingService.logUserInteraction(
      'retry_connection',
      screen: 'error_handling',
      data: {'error_type': _currentErrorDetails?.type.toString()},
    );

    // Simulate retry progress
    _progressAnimationController.forward();

    final steps = [
      'Checking network connectivity...',
      'Testing API endpoints...',
      'Authenticating services...',
      'Initializing connections...',
      'Finalizing setup...',
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _retryProgress = ((i + 1) / steps.length * 100).round();
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.onRetryCallback != null) {
      widget.onRetryCallback!();
    } else {
      // Default retry behavior - navigate back to splash
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _handleCheckNetwork() async {
    _loggingService.logUserInteraction(
      'check_network',
      screen: 'error_handling',
      data: {},
    );

    // This would typically open system network settings
    // For now, we'll show a dialog with network information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Settings'),
        content: const Text(
          'Please check your network settings in the system settings app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleSkipSetup() {
    _loggingService.logUserInteraction(
      'skip_setup',
      screen: 'error_handling',
      data: {},
    );

    // Enable offline mode and proceed
    setState(() {
      _isOfflineModeEnabled = true;
    });

    // Navigate to main app with limited functionality
    Navigator.of(context).pushReplacementNamed('/main-conversation');
  }

  void _handleToggleOfflineMode() {
    setState(() {
      _isOfflineModeEnabled = !_isOfflineModeEnabled;
    });

    _loggingService.logUserInteraction(
      'toggle_offline_mode',
      screen: 'error_handling',
      data: {'enabled': _isOfflineModeEnabled},
    );
  }

  void _handleContactSupport() async {
    _loggingService.logUserInteraction(
      'contact_support',
      screen: 'error_handling',
      data: {},
    );

    // Generate support email with diagnostic information
    final diagnosticInfo = '''
GetMyLappen Support Request

Error Information:
- Error Type: ${_currentErrorDetails?.type}
- Error Message: ${_currentErrorDetails?.message}
- Timestamp: ${DateTime.now().toIso8601String()}
- Can Retry: ${_currentErrorDetails?.canRetry}

Device Information:
- Platform: ${Theme.of(context).platform.name}
- App Version: 1.0.0

Please describe your issue and any steps you've already tried.
    ''';

    try {
      await Clipboard.setData(ClipboardData(text: diagnosticInfo));

      // Show instructions to user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contact Support'),
          content: const Text(
            'Diagnostic information has been copied to your clipboard. '
            'Please email support@getmylappen.com and paste this information '
            'along with your description of the issue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle clipboard error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to copy diagnostic information. Please contact support@getmylappen.com directly.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _mainAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideUpAnimation.value),
                child: Opacity(
                  opacity: _fadeInAnimation.value,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentErrorDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 4.h),

          // Header
          _buildHeader(),

          SizedBox(height: 4.h),

          // Error Icon and Status
          ErrorIconWidget(
            errorType: _currentErrorDetails!.type,
            isAnimated: !_isRetrying,
          ),

          SizedBox(height: 4.h),

          // Error Message
          _buildErrorMessage(),

          SizedBox(height: 4.h),

          // Retry Progress (shown during retry)
          if (_isRetrying) ...[_buildRetryProgress(), SizedBox(height: 4.h)],

          // Diagnostic Information
          DiagnosticInfoWidget(
            errorDetails: _currentErrorDetails!,
            showAdvancedInfo: false,
          ),

          SizedBox(height: 4.h),

          // Recovery Actions
          if (!_isRetrying) ...[
            RecoveryActionsWidget(
              errorDetails: _currentErrorDetails!,
              onRetryConnection: _handleRetryConnection,
              onCheckNetwork: _handleCheckNetwork,
              onSkipSetup: _handleSkipSetup,
              onContactSupport: _handleContactSupport,
            ),

            SizedBox(height: 4.h),

            // Advanced Troubleshooting
            AdvancedTroubleshootingWidget(
              errorDetails: _currentErrorDetails!,
              loggingService: _loggingService,
            ),

            SizedBox(height: 4.h),

            // Offline Mode & Support
            OfflineModeWidget(
              isOfflineModeEnabled: _isOfflineModeEnabled,
              onToggleOfflineMode: _handleToggleOfflineMode,
              onContactSupport: _handleContactSupport,
            ),
          ],

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                size: 20,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Connection Troubleshooting',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Text(
            _getErrorTitle(),
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            _currentErrorDetails!.userFriendlyMessage,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRetryProgress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Text(
            'Attempting to reconnect...',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: _retryProgress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 1.h),
          Text(
            '$_retryProgress% complete',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getErrorTitle() {
    switch (_currentErrorDetails!.type) {
      case ConnectionErrorType.networkUnavailable:
        return 'No Internet Connection';
      case ConnectionErrorType.timeout:
        return 'Connection Timeout';
      case ConnectionErrorType.serverError:
        return 'Server Unavailable';
      case ConnectionErrorType.unauthorized:
      case ConnectionErrorType.apiKeyInvalid:
        return 'Authentication Failed';
      case ConnectionErrorType.quotaExceeded:
        return 'Service Limit Reached';
      case ConnectionErrorType.rateLimited:
        return 'Too Many Requests';
      case ConnectionErrorType.dnsFailure:
        return 'Server Not Found';
      case ConnectionErrorType.sslError:
        return 'Security Error';
      default:
        return 'Connection Error';
    }
  }
}
