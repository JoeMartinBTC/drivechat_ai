import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/splash_loading_widget.dart';
import './widgets/splash_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingFadeAnimation;

  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _loadingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _loadingController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isInitializing = true;
        _hasError = false;
        _showRetryButton = false;
      });

      // Simulate initialization tasks
      await Future.wait([
        _checkMicrophonePermissions(),
        _setupWebSocketConnection(),
        _authenticateElevenLabsAPI(),
        _loadConversationHistory(),
        _prepareAudioSession(),
        _validateNetworkConnectivity(),
      ]);

      // Minimum splash display time
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
          _isInitializing = false;
        });

        // Show retry button after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _hasError) {
            setState(() {
              _showRetryButton = true;
            });
          }
        });
      }
    }
  }

  Future<void> _checkMicrophonePermissions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate permission check
  }

  Future<void> _setupWebSocketConnection() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate WebSocket setup
  }

  Future<void> _authenticateElevenLabsAPI() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simulate API authentication
    // Uncomment to test error handling:
    // throw Exception('API authentication failed');
  }

  Future<void> _loadConversationHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate loading conversation history
  }

  Future<void> _prepareAudioSession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate audio session preparation
  }

  Future<void> _validateNetworkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simulate network validation
    // Uncomment to test network timeout:
    // throw Exception('Network timeout');
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('timeout')) {
      return 'Netzwerkverbindung fehlgeschlagen. Bitte überprüfen Sie Ihre Internetverbindung.';
    } else if (errorString.contains('api') ||
        errorString.contains('authentication')) {
      return 'Authentifizierung fehlgeschlagen. Bitte versuchen Sie es erneut.';
    } else if (errorString.contains('permission')) {
      return 'Mikrofonberechtigung erforderlich. Bitte gewähren Sie die Berechtigung.';
    }
    return 'Initialisierung fehlgeschlagen. Bitte versuchen Sie es erneut.';
  }

  void _navigateToNextScreen() {
    // Navigation logic based on app state
    // For demo purposes, navigate to main conversation interface
    Navigator.pushReplacementNamed(context, '/main-conversation-interface');
  }

  void _retryInitialization() {
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.primaryColor,
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.accentLight,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo Section
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: SplashLogoWidget(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 48),

                // Loading Section
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _loadingFadeAnimation.value,
                      child: SplashLoadingWidget(
                        isLoading: _isInitializing,
                        hasError: _hasError,
                        errorMessage: _errorMessage,
                        showRetryButton: _showRetryButton,
                        onRetry: _retryInitialization,
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // App Version
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'GetMyLappen v1.0.0',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
