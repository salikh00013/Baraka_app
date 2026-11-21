import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  AppConfig._();

  // Configure with the Supabase project URL and anon/publishable key.
  // Never put a service-role key in this mobile application.
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
