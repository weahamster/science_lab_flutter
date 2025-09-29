import 'package:flutter/material.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보고서 목록'),
      ),
      body: const Center(
        child: Text('보고서 목록 화면'),
      ),
    );
  }
}