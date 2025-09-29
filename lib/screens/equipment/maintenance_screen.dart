import 'package:flutter/material.dart';  // ← 추가

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('유지보수 일정'),
      ),
      body: const Center(
        child: Text('유지보수 일정 화면'),
      ),
    );
  }
}