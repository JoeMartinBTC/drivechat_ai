import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final Widget animatedIcon;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.animatedIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Hero illustration
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.textPrimaryLight.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),

                    // Animated icon overlay
                    Positioned(bottom: 24, right: 24, child: animatedIcon),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Content section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Description
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryLight,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
