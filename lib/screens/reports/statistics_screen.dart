import 'package:flutter/material.dart';  // ← 추가

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: const Center(
        child: Text('통계 화면'),
      ),
    );
  }
}