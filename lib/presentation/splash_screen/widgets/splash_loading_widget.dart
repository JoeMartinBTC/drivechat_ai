import '../../../core/app_export.dart';

class SplashLoadingWidget extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool showRetryButton;
  final VoidCallback onRetry;

  const SplashLoadingWidget({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.showRetryButton,
    required this.onRetry,
  });

  @override
  State<SplashLoadingWidget> createState() => _SplashLoadingWidgetState();
}

class _SplashLoadingWidgetState extends State<SplashLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SplashLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasError) {
      return _buildErrorState();
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading Indicator
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 16),

        // Loading Text
        Text(
          'KI-System wird initialisiert...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 8),

        // Progress Steps
        Text(
          'Mikrofon • WebSocket • API • Audio',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.errorLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        SizedBox(height: 16),

        // Error Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            widget.errorMessage,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        if (widget.showRetryButton) ...[
          SizedBox(height: 24),

          // Retry Button
          ElevatedButton.icon(
            onPressed: widget.onRetry,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.primaryColor,
              size: 18,
            ),
            label: Text(
              'Erneut versuchen',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.lightTheme.primaryColor,
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
