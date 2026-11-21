import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await AppConfig.initializeSupabase();
  }

  runApp(const BarakaApp());
}

class BarakaApp extends StatelessWidget {
  const BarakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BARAKA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16834A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F6),
      ),
      home: const HomeScreen(),
    );
  }
}
