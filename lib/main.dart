import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables FIRST (contains API keys)
  await dotenv.load(fileName: ".env");
  print('✅ Environment variables loaded');

  // Initialize Firebase once at app start with explicit options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: AiFitnessApp()));
}

class AiFitnessApp extends StatelessWidget {
  const AiFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AI Fitness App',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
