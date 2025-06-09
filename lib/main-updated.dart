import 'custom_inspector.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import './controllers/api_config_controller.dart';
import './controllers/audio_controller.dart';
import './routes/app_routes.dart';
import './theme/app_theme.dart';

var backendURL = "https://drivechat4524back.builtwithrocket.new/log-error";

void main() async {
  FlutterError.onError = (details) {
    _sendOverflowError(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
          child: MaterialApp(
            title: 'DriveChat AI',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.splashScreen,
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}


    void _sendOverflowError(FlutterErrorDetails details) {
      try {
        final errorMessage = details.exception.toString();
        final exceptionType = details.exception.runtimeType.toString();

        String location = 'Unknown';
        final locationMatch = RegExp(r'file:///.*\.dart').firstMatch(details.toString());
        if (locationMatch != null) {
          location = locationMatch.group(0)?.replaceAll("file://", '') ?? 'Unknown';
        }
        String errorType = "RUNTIME_ERROR";
        if(errorMessage.contains('overflowed by') || errorMessage.contains('RenderFlex overflowed')) {
          errorType = 'OVERFLOW_ERROR';
        }
        final payload = {
          'errorType': errorType,
          'exceptionType': exceptionType,
          'message': errorMessage,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
        };
        final jsonData = jsonEncode(payload);
        final request = html.HttpRequest();
        request.open('POST', backendURL, async: true);
        request.setRequestHeader('Content-Type', 'application/json');
        request.onReadyStateChange.listen((_) {
          if (request.readyState == html.HttpRequest.DONE) {
            if (request.status == 200) {
              print('Successfully reported error');
            } else {
              print('Error reporting overflow');
            }
          }
        });
        request.onError.listen((event) {
          print('Failed to send overflow report');
        });
        request.send(jsonData);
      } catch (e) {
        print('Exception while reporting overflow error: $e');
      }
    }
    