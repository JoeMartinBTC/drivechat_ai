import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

// lib/presentation/api_configuration_screen/widgets/agent_selection_widget.dart

class AgentSelectionWidget extends StatelessWidget {
  final List<Map<String, String>> agents;
  final String? selectedAgent;
  final ValueChanged<String> onAgentSelected;

  const AgentSelectionWidget({
    super.key,
    required this.agents,
    required this.selectedAgent,
    required this.onAgentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'person',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Agent Selection',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            'Choose an ElevenLabs agent optimized for driving education',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),

          SizedBox(height: 2.h),

          // Agent List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agents.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final agent = agents[index];
              final isSelected = selectedAgent == agent['id'];

              return GestureDetector(
                onTap: () => onAgentSelected(agent['id']!),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.primaryLight.withValues(alpha: 0.1)
                            : AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Selection Radio
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppTheme.primaryLight
                                    : AppTheme.borderLight,
                            width: 2,
                          ),
                          color:
                              isSelected
                                  ? AppTheme.primaryLight
                                  : Colors.transparent,
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  size: 12,
                                  color: AppTheme.backgroundLight,
                                )
                                : null,
                      ),

                      SizedBox(width: 3.w),

                      // Agent Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    agent['name']!,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? AppTheme.primaryLight
                                                  : AppTheme.textPrimaryLight,
                                        ),
                                  ),
                                ),
                                if (agent['id'] == 'agent_1')
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successLight.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.successLight.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'RECOMMENDED',
                                      style: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.successLight,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              agent['description']!,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'volume_up',
                                  color: AppTheme.textSecondaryLight,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    agent['voice']!,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryLight,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Voice Preview Button
                      IconButton(
                        icon: CustomIconWidget(
                          iconName: 'play_arrow',
                          color: AppTheme.primaryLight,
                          size: 20,
                        ),
                        onPressed: () {
                          _showVoicePreview(context, agent);
                        },
                        tooltip: 'Preview voice',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVoicePreview(BuildContext context, Map<String, String> agent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Voice Preview - ${agent['name']}',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sample Text:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: Text(
                  '"Welcome to DriveChat AI. Today we\'ll practice highway merging techniques. Remember to check your mirrors and signal early for safe lane changes."',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Simulate voice preview
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Playing voice preview for ${agent['name']}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: CustomIconWidget(
                        iconName: 'play_arrow',
                        color: AppTheme.backgroundLight,
                        size: 16,
                      ),
                      label: const Text('Play Sample'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                onAgentSelected(agent['id']!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected ${agent['name']} as your agent'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              },
              child: const Text('Select Agent'),
            ),
          ],
        );
      },
    );
  }
}
