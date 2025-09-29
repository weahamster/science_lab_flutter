import 'package:flutter/material.dart';  // ← 추가

class ChemicalListScreen extends StatelessWidget {
  const ChemicalListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('화학물질 관리'),
      ),
      body: const Center(
        child: Text('화학물질 관리 화면'),
      ),
    );
  }
}