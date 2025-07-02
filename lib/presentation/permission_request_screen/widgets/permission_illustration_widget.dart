
import '../../../core/app_export.dart';

class PermissionIllustrationWidget extends StatefulWidget {
  const PermissionIllustrationWidget({super.key});

  @override
  State<PermissionIllustrationWidget> createState() =>
      _PermissionIllustrationWidgetState();
}

class _PermissionIllustrationWidgetState
    extends State<PermissionIllustrationWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeOut));

    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      height: 30.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with driving context
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  AppTheme.lightTheme.colorScheme.tertiary.withValues(
                    alpha: 0.1,
                  ),
                ],
              ),
            ),
          ),

          // Animated sound waves
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (index) {
                  final delay = index * 0.3;
                  final animationValue = (_waveAnimation.value - delay).clamp(
                    0.0,
                    1.0,
                  );

                  return Container(
                    width: (20.w + (index * 8.w)) * animationValue,
                    height: (20.w + (index * 8.w)) * animationValue,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            AppTheme.lightTheme.colorScheme.primary.withValues(
                          alpha: (0.6 - (index * 0.2)) * (1 - animationValue),
                        ),
                        width: 2,
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Central microphone icon with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'mic',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 8.w,
                    ),
                  ),
                ),
              );
            },
          ),

          // Driving education context icons
          Positioned(
            top: 5.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                      alpha: 0.1,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'directions_car',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),

          Positioned(
            top: 5.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                      alpha: 0.1,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'school',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
            ),
          ),

          Positioned(
            bottom: 5.h,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                      alpha: 0.1,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'record_voice_over',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
