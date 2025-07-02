// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/permission_request_screen/permission_request_screen.dart';
import '../presentation/conversation_history/conversation_history.dart';
import '../presentation/main_conversation_interface/main_conversation_interface.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/audio_settings_screen/audio_settings_screen.dart';
import '../presentation/api_configuration_screen/api_configuration_screen.dart';
import '../presentation/agent_selection_screen/agent_selection_screen.dart';
import '../presentation/help_screen/help_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String mainConversationInterface =
      '/main-conversation-interface';
  static const String conversationHistory = '/conversation-history';
  static const String settingsScreen = '/settings-screen';
  static const String permissionRequestScreen = '/permission-request-screen';
  static const String audioSettingsScreen = '/audio-settings-screen';
  static const String apiConfigurationScreen = '/api-configuration-screen';
  static const String agentSelectionScreen = '/agent-selection-screen';
  static const String helpScreen = '/help-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    mainConversationInterface: (context) => const MainConversationInterface(),
    conversationHistory: (context) => const ConversationHistory(),
    settingsScreen: (context) => const SettingsScreen(),
    permissionRequestScreen: (context) => const PermissionRequestScreen(),
    audioSettingsScreen: (context) => const AudioSettingsScreen(),
    apiConfigurationScreen: (context) => const ApiConfigurationScreen(),
    agentSelectionScreen: (context) => const AgentSelectionScreen(),
    helpScreen: (context) => const HelpScreen(),
  };
}
