import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/api_validation_utils.dart';

// lib/presentation/api_configuration_screen/widgets/api_key_input_widget.dart

class ApiKeyInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onVisibilityToggle;
  final ValueChanged<String> onChanged;

  const ApiKeyInputWidget({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onVisibilityToggle,
    required this.onChanged,
  });

  String _formatApiKey(String value) {
    return ApiValidationUtils.formatApiKeyForDisplay(value);
  }

  String? _validateApiKey(String? value) {
    final result = ApiValidationUtils.validateElevenLabsApiKey(value);

    // Log validation attempt for debugging
    if (value != null && value.isNotEmpty) {
      ApiValidationUtils.logValidationAttempt(value, result);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'key',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'ElevenLabs API Key',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // API Key Input Field
          TextFormField(
            controller: controller,
            obscureText: !isVisible,
            enableInteractiveSelection: false,
            onChanged: onChanged,
            validator: _validateApiKey,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: isVisible ? 14 : 16,
              letterSpacing: isVisible ? 1.2 : 2.0,
              color: AppTheme.textPrimaryLight,
            ),
            inputFormatters: [
              if (isVisible)
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final formatted = _formatApiKey(newValue.text);
                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }),
            ],
            decoration: InputDecoration(
              hintText: isVisible
                  ? 'sk_1234 5678 9012 3456...'
                  : '••••••••••••••••••••',
              hintStyle: TextStyle(
                fontFamily: 'Courier New',
                fontSize: isVisible ? 14 : 16,
                letterSpacing: isVisible ? 1.2 : 2.0,
                color: AppTheme.textSecondaryLight.withValues(alpha: 0.6),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Validation Status Icon
                  if (controller.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: CustomIconWidget(
                        iconName: _validateApiKey(controller.text) == null
                            ? 'check_circle'
                            : 'error',
                        color: _validateApiKey(controller.text) == null
                            ? AppTheme.successLight
                            : AppTheme.errorLight,
                        size: 20,
                      ),
                    ),
                  // Visibility Toggle
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: isVisible ? 'visibility_off' : 'visibility',
                      color: AppTheme.textSecondaryLight,
                      size: 20,
                    ),
                    onPressed: onVisibilityToggle,
                    tooltip: isVisible ? 'Hide API key' : 'Show API key',
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.primaryLight,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.errorLight,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.errorLight,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.backgroundLight,
            ),
          ),

          SizedBox(height: 1.h),

          // API Key Format Help
          if (ApiValidationUtils.hasIncorrectPrefix(controller.text))
            Container(
              margin: EdgeInsets.only(top: 1.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningLight,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'ElevenLabs API keys start with "sk_" (underscore), not "sk-" (hyphen)',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Security Information
          Row(
            children: [
              CustomIconWidget(
                iconName: 'shield',
                color: AppTheme.successLight,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  'Your API key is encrypted and stored securely on this device',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Character Count
          if (controller.text.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Characters: ${controller.text.replaceAll(RegExp(r'\s+'), '').length}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                if (_validateApiKey(controller.text) == null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
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
                          'Valid format',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
