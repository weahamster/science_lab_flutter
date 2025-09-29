// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';  // ← login_screen import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://whkwwvtgweyrfkxcequj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indoa3d3dnRnd2V5cmZreGNlcXVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0NjY3MTEsImV4cCI6MjA3NDA0MjcxMX0.z5B-7vpYxlOMfpe4-NuW9XxoZqabG7cR4OHGTgj-6Z0',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Science Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),  // LoginScreen은 이제 별도 파일에서 import
      debugShowCheckedModeBanner: false,
    );
  }
}

// LoginScreen 클래스는 삭제 (login_screen.dart로 이동했으므로)