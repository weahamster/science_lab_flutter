import 'package:flutter/material.dart';  // ← 추가

class DataAnalysisScreen extends StatelessWidget {
  const DataAnalysisScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('데이터 분석'),
      ),
      body: const Center(
        child: Text('데이터 분석 화면'),
      ),
    );
  }
}