import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/api_validation_utils.dart';

// lib/presentation/api_configuration_screen/widgets/agent_number_input_widget.dart

class AgentNumberInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const AgentNumberInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  String? _validateAgentNumber(String? value) {
    return ApiValidationUtils.validateAgentNumber(value);
  }

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
                iconName: 'tag',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'ElevenLabs Agent Number',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Agent Number Input Field
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: _validateAgentNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 16,
              color: AppTheme.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Enter agent number (e.g., 12345)',
              hintStyle: TextStyle(
                fontFamily: 'Courier New',
                fontSize: 14,
                color: AppTheme.textSecondaryLight.withValues(alpha: 0.6),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'numbers',
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: CustomIconWidget(
                        iconName: _validateAgentNumber(controller.text) == null
                            ? 'check_circle'
                            : 'error',
                        color: _validateAgentNumber(controller.text) == null
                            ? AppTheme.successLight
                            : AppTheme.errorLight,
                        size: 20,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.errorLight, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.errorLight, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.backgroundLight,
            ),
          ),

          SizedBox(height: 1.h),

          // Agent Number Information
          Row(
            children: [
              CustomIconWidget(iconName: 'info', size: 16),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  'Enter the specific agent number provided by ElevenLabs for your conversational AI agent',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),

          if (controller.text.isNotEmpty &&
              _validateAgentNumber(controller.text) == null)
            Container(
              margin: EdgeInsets.only(top: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.successLight,
                    size: 12,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Valid agent number',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successLight,
                      fontWeight: FontWeight.w500,
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
