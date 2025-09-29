import 'package:flutter/material.dart';  // ← 추가

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('시스템 설정'),
      ),
      body: const Center(
        child: Text('시스템 설정 화면'),
      ),
    );
  }
}