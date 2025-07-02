// lib/presentation/diagnostics_screen/widgets/performance_metrics_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../services/enhanced_logging_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final EnhancedLoggingService loggingService;

  const PerformanceMetricsWidget({super.key, required this.loggingService});

  @override
  Widget build(BuildContext context) {
    final metrics = loggingService.getPerformanceMetrics();
    final errorCategories = metrics['errorCategories'] as Map<String, int>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.sp),

        // Metrics grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.sp,
          mainAxisSpacing: 12.sp,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              context,
              'Total Events',
              metrics['totalEvents'].toString(),
              Icons.event,
              Colors.blue,
            ),
            _buildMetricCard(
              context,
              'Error Rate',
              '${metrics['errorRate']}%',
              Icons.error_outline,
              double.parse(metrics['errorRate']) > 10
                  ? Colors.red
                  : Colors.green,
            ),
            _buildMetricCard(
              context,
              'User Actions',
              metrics['userInteractions'].toString(),
              Icons.touch_app,
              Colors.purple,
            ),
            _buildMetricCard(
              context,
              'Platform',
              metrics['isMobile'] ? 'Mobile' : 'Desktop',
              metrics['isMobile'] ? Icons.smartphone : Icons.computer,
              Colors.orange,
            ),
          ],
        ),

        SizedBox(height: 24.sp),

        // Error distribution chart
        if (errorCategories.isNotEmpty) ...[
          Text(
            'Error Distribution',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.sp),
          Container(
            height: 200.sp,
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: errorCategories.length == 1
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'pie_chart',
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 8.sp),
                        Text(
                          errorCategories.keys.first,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${errorCategories.values.first} errors',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(errorCategories),
                      centerSpaceRadius: 40.sp,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          SizedBox(height: 16.sp),

          // Legend
          Wrap(
            spacing: 16.sp,
            runSpacing: 8.sp,
            children: errorCategories.entries.map((entry) {
              final color = _getCategoryColor(
                entry.key,
                errorCategories.keys.toList().indexOf(entry.key),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.sp,
                    height: 12.sp,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.sp),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  size: 48.sp,
                  color: Colors.green,
                ),
                SizedBox(height: 12.sp),
                Text(
                  'No Errors Detected',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Your app is performing optimally',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 24.sp),

        // Recent performance events
        Text(
          'Recent Activity',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.sp),

        Container(
          constraints: BoxConstraints(maxHeight: 200.sp),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: loggingService.performanceLogs.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(24.sp),
                  child: Center(
                    child: Text(
                      'No performance data available',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: loggingService.performanceLogs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final log = loggingService.performanceLogs[
                        loggingService.performanceLogs.length - 1 - index];
                    final timestamp = DateTime.parse(log['timestamp']);

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12.sp,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        child: CustomIconWidget(
                          iconName: 'timeline',
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        '[${log['category']}] ${log['event']}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.sp),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> errorCategories,
  ) {
    final total = errorCategories.values.fold(0, (sum, count) => sum + count);
    final categories = errorCategories.entries.toList();

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final percentage = (category.value / total * 100);
      final color = _getCategoryColor(category.key, index);

      return PieChartSectionData(
        value: category.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 60.sp,
        titleStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category, int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.pink,
      Colors.teal,
    ];

    return colors[index % colors.length];
  }
}
