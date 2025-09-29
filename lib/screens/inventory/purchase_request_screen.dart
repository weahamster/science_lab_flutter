import 'package:flutter/material.dart';  // ← 추가

class PurchaseRequestScreen extends StatelessWidget {
  const PurchaseRequestScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('구매 요청'),
      ),
      body: const Center(
        child: Text('구매 요청 화면'),
      ),
    );
  }
}