// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Basic initialization (works on Android/iOS if google-services.json / GoogleService-Info.plist present)
  await Firebase.initializeApp();

  // If you have run `flutterfire configure` and have firebase_options.dart:
  // import 'firebase_options.dart';
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SharedLivesApp());
}

class SharedLivesApp extends StatelessWidget {
  const SharedLivesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Lives',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      // If you already implement auth flow, keep LoginScreen/HomeScreen logic.
      home: const HomeScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
