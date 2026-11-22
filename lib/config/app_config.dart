import 'package:firebase_core/firebase_core.dart';

class AppConfig {
  AppConfig._();

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }
}
