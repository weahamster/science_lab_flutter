import 'package:flutter/material.dart';  // ← 추가

class EquipmentReservationScreen extends StatelessWidget {
  const EquipmentReservationScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('장비 예약'),
      ),
      body: const Center(
        child: Text('장비 예약 화면'),
      ),
    );
  }
}