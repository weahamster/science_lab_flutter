import 'package:flutter/material.dart';  // ← 추가

class ReportGeneratorScreen extends StatelessWidget {
  const ReportGeneratorScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('보고서 생성'),
      ),
      body: const Center(
        child: Text('보고서 생성 화면'),
      ),
    );
  }
}