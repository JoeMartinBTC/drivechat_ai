import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _micAnimationController;
  late AnimationController _typingAnimationController;
  late Animation<double> _micScaleAnimation;
  late Animation<double> _typingOpacityAnimation;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "KI-gestütztes Fahren lernen",
      "subtitle": "Sprechen Sie mit Ihrem persönlichen Fahrlehrer",
      "description":
          "Führen Sie natürliche Gespräche über Verkehrsregeln, Fahrtechniken und Prüfungsvorbereitung. Unser KI-Instructor ist rund um die Uhr verfügbar.",
      "imageUrl":
          "https://images.unsplash.com/photo-1449824913935-59a10b8d2000",
      "type": "voice",
    },
    {
      "title": "Text-Chat Alternative",
      "subtitle": "Flexibles Lernen nach Ihrem Tempo",
      "description":
          "Bevorzugen Sie das Tippen? Nutzen Sie unseren intelligenten Chat für detaillierte Erklärungen und sofortige Antworten auf Ihre Fragen.",
      "imageUrl":
          "https://images.unsplash.com/photo-1516321318423-f06f85e504b3",
      "type": "chat",
    },
    {
      "title": "Personalisiertes Lernen",
      "subtitle": "Ihr Fortschritt, Ihre Ziele",
      "description":
          "Verfolgen Sie Ihren Lernfortschritt, erhalten Sie maßgeschneiderte Übungen und bereiten Sie sich gezielt auf die Führerscheinprüfung vor.",
      "imageUrl":
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173",
      "type": "progress",
    },
    {
      "title": "Mikrofon-Berechtigung",
      "subtitle": "Für optimales Sprachlernen",
      "description":
          "Gewähren Sie Mikrofon-Zugriff für Sprachkonversationen. Ihre Privatsphäre ist geschützt - Audio wird nur während aktiver Gespräche verarbeitet.",
      "imageUrl":
          "https://images.unsplash.com/photo-1478737270239-2f02b77fc618",
      "type": "permission",
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _micScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _micAnimationController,
      curve: Curves.easeInOut,
    ));

    _typingOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    _micAnimationController.repeat(reverse: true);
    _typingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _micAnimationController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    if (_currentPage == _onboardingData.length - 1) {
      await _requestMicrophonePermission();
    }

    // Store onboarding completion status
    // In a real app, you would use SharedPreferences here

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main-conversation-interface');
    }
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();

      if (status.isDenied) {
        _showPermissionDialog();
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
    } catch (e) {
      // Handle permission request error
      debugPrint('Permission request error: \$e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Mikrofon-Berechtigung',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Für Sprachkonversationen benötigen wir Mikrofon-Zugriff. Sie können die App auch im Text-Modus verwenden.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Später'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestMicrophonePermission();
              },
              child: Text('Erneut versuchen'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Berechtigung in Einstellungen aktivieren',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Öffnen Sie die App-Einstellungen, um die Mikrofon-Berechtigung zu aktivieren.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Einstellungen öffnen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedIcon(String type) {
    switch (type) {
      case 'voice':
        return AnimatedBuilder(
          animation: _micScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _micScaleAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'mic',
                  color: AppTheme.primaryLight,
                  size: 40,
                ),
              ),
            );
          },
        );
      case 'chat':
        return AnimatedBuilder(
          animation: _typingOpacityAnimation,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Opacity(
                opacity: _typingOpacityAnimation.value,
                child: CustomIconWidget(
                  iconName: 'chat_bubble_outline',
                  color: AppTheme.secondaryLight,
                  size: 40,
                ),
              ),
            );
          },
        );
      case 'progress':
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.successLight.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'trending_up',
            color: AppTheme.successLight,
            size: 40,
          ),
        );
      case 'permission':
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.warningLight.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'security',
            color: AppTheme.warningLight,
            size: 40,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // Spacer for centering
                  PageIndicatorWidget(
                    currentPage: _currentPage,
                    totalPages: _onboardingData.length,
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Überspringen',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  HapticFeedback.lightImpact();
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPageWidget(
                    title: data['title'],
                    subtitle: data['subtitle'],
                    description: data['description'],
                    imageUrl: data['imageUrl'],
                    animatedIcon: _buildAnimatedIcon(data['type']),
                  );
                },
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryLight
                              : AppTheme.primaryLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Loslegen'
                            : 'Weiter',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.backgroundLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back button (except on first page)
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Zurück',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
