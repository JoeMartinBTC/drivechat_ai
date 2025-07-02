import '../../../core/app_export.dart';

class SplashLogoWidget extends StatelessWidget {
  const SplashLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'directions_car',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 48,
                ),
                SizedBox(height: 4),
                CustomIconWidget(
                  iconName: 'chat_bubble',
                  color: AppTheme.accentLight,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 24),

        // App Name
        Text(
          'GetMyLappen',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 8),

        // Tagline
        Text(
          'Ihr KI-Fahrlehrer',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
