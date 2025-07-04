import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import './controllers/api_config_controller.dart';
import './controllers/audio_controller.dart';
import './routes/app_routes.dart';
import './theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle .env file loading with error handling
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Continue without .env file if it doesn't exist
    print('Warning: .env file not found or could not be loaded: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiConfigController()),
            ChangeNotifierProxyProvider<ApiConfigController, AudioController>(
              create: (context) => AudioController(
                Provider.of<ApiConfigController>(context, listen: false),
              ),
              update: (context, apiConfigController, previous) =>
                  previous ?? AudioController(apiConfigController),
            ),
          ],
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: MaterialApp(
              title: 'GetMyLappen',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              initialRoute: AppRoutes.splashScreen,
              routes: AppRoutes.routes,
              debugShowCheckedModeBanner: false,
            ),
          ),
        );
      },
    );
  }
}
