import '../../../core/app_export.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppTheme.primaryLight
                : AppTheme.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
