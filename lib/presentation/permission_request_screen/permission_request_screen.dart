import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/permission_actions_widget.dart';
import './widgets/permission_benefits_widget.dart';
import './widgets/permission_illustration_widget.dart';
import './widgets/privacy_assurance_widget.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool _isLoading = false;

  void _handleMicrophonePermission() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate permission request delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to main conversation interface after permission granted
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main-conversation-interface');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _handleTextOnlyMode() {
    // Navigate to main conversation interface with text-only mode
    Navigator.pushReplacementNamed(context, '/main-conversation-interface');
  }

  void _handleClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),

                  // Illustration
                  PermissionIllustrationWidget(),

                  SizedBox(height: 4.h),

                  // Headline
                  Text(
                    'Mikrofon für Sprachlernen',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 2.h),

                  // Description
                  Text(
                    'Für die beste Lernerfahrung benötigt DriveChat AI Zugriff auf Ihr Mikrofon. Sprechen Sie natürlich mit Ihrem KI-Fahrlehrer und erhalten Sie sofortiges Feedback.',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 4.h),

                  // Benefits
                  PermissionBenefitsWidget(),

                  SizedBox(height: 4.h),

                  // Privacy assurance
                  PrivacyAssuranceWidget(),

                  SizedBox(height: 6.h),

                  // Action buttons
                  PermissionActionsWidget(
                    onAllowMicrophone: _handleMicrophonePermission,
                    onTextOnlyMode: _handleTextOnlyMode,
                    isLoading: _isLoading,
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 2.h,
              right: 4.w,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow
                              .withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
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
