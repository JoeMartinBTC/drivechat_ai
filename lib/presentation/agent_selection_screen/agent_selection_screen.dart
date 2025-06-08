import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

// lib/presentation/agent_selection_screen/agent_selection_screen.dart

class AgentSelectionScreen extends StatefulWidget {
  const AgentSelectionScreen({super.key});

  @override
  State<AgentSelectionScreen> createState() => _AgentSelectionScreenState();
}

class _AgentSelectionScreenState extends State<AgentSelectionScreen> {
  String? _selectedAgentId;

  // Agent data
  final List<Map<String, dynamic>> _agents = [
    {
      'id': 'driveguide_pro',
      'name': 'DriveGuide Pro',
      'description': 'Optimized for German driving education',
      'voiceDescription': 'Professional, clear German accent',
      'isRecommended': true,
    },
    {
      'id': 'traffic_mentor',
      'name': 'Traffic Mentor',
      'description': 'Specialized in traffic law explanations',
      'voiceDescription': 'Patient, educational tone',
      'isRecommended': false,
    },
    {
      'id': 'road_safety_coach',
      'name': 'Road Safety Coach',
      'description': 'Focus on safety scenarios and best practices',
      'voiceDescription': 'Calm, reassuring guidance',
      'isRecommended': false,
    },
  ];

  void _selectAgent(String agentId) {
    setState(() {
      _selectedAgentId = agentId;
    });
  }

  void _continueWithSelectedAgent() {
    if (_selectedAgentId != null) {
      // Save the selected agent and navigate to next screen
      // You would typically store this in shared preferences or another state management solution

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Selected ${_agents.firstWhere((agent) => agent['id'] == _selectedAgentId)['name']}'),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to the main conversation interface
      Navigator.pushReplacementNamed(
          context, AppRoutes.mainConversationInterface);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an agent to continue'),
          backgroundColor: AppTheme.warningLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _previewAgentVoice(Map<String, dynamic> agent) {
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
                  border: Border.all(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
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
                                'Playing voice preview for ${agent['name']}'),
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
                _selectAgent(agent['id']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'person',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Agent Selection',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppTheme.backgroundLight,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                'Choose an ElevenLabs agent optimized for driving education',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Agent List
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: ListView.separated(
                  itemCount: _agents.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final agent = _agents[index];
                    final bool isSelected = _selectedAgentId == agent['id'];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _selectAgent(agent['id']),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            children: [
                              // Radio Button
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryLight
                                        : AppTheme.borderLight,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 3.w,
                                          height: 3.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppTheme.primaryLight,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),

                              SizedBox(width: 3.w),

                              // Agent Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Agent Name and Recommended Tag
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            agent['name'],
                                            style: AppTheme.lightTheme.textTheme
                                                .titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? AppTheme.primaryLight
                                                  : AppTheme.textPrimaryLight,
                                            ),
                                          ),
                                        ),
                                        if (agent['isRecommended'])
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                              vertical: 0.5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successLight
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppTheme.successLight
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              'RECOMMENDED',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
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

                                    // Agent Description
                                    Text(
                                      agent['description'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),

                                    SizedBox(height: 0.5.h),

                                    // Voice Description
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
                                            agent['voiceDescription'],
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  AppTheme.textSecondaryLight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Preview Button
                              IconButton(
                                icon: CustomIconWidget(
                                  iconName: 'arrow_forward_ios',
                                  color: AppTheme.primaryLight,
                                  size: 20,
                                ),
                                onPressed: () => _previewAgentVoice(agent),
                                tooltip: 'Preview',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(5.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAgentId != null
                      ? _continueWithSelectedAgent
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    backgroundColor: AppTheme.primaryLight,
                    disabledBackgroundColor:
                        AppTheme.textSecondaryLight.withAlpha(77),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.backgroundLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
