import 'package:flutter/material.dart';  // ← 추가

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('사용자 관리'),
      ),
      body: const Center(
        child: Text('사용자 관리 화면'),
      ),
    );
  }
}