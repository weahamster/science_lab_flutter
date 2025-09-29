
import 'package:flutter/material.dart'; 
// lib/screens/experiments/experiment_report_screen.dart
class ExperimentReportScreen extends StatelessWidget {
  const ExperimentReportScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('실험 보고서 화면'));
  }
}

// lib/screens/equipment/equipment_reservation_screen.dart
class EquipmentReservationScreen extends StatelessWidget {
  const EquipmentReservationScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ← Scaffold 추가
      appBar: AppBar(
        title: const Text('실험 보고서'),
      ),
      body: const Center(
        child: Text('실험 보고서 화면'),
      ),
    );
  }
}

// lib/screens/equipment/maintenance_screen.dart
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('유지보수 일정 화면'));
  }
}

// lib/screens/inventory/chemical_list_screen.dart
class ChemicalListScreen extends StatelessWidget {
  const ChemicalListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('화학물질 관리 화면'));
  }
}

// lib/screens/inventory/purchase_request_screen.dart
class PurchaseRequestScreen extends StatelessWidget {
  const PurchaseRequestScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('구매 요청 화면'));
  }
}

// lib/screens/reports/data_analysis_screen.dart
class DataAnalysisScreen extends StatelessWidget {
  const DataAnalysisScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('데이터 분석 화면'));
  }
}

// lib/screens/reports/report_generator_screen.dart
class ReportGeneratorScreen extends StatelessWidget {
  const ReportGeneratorScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('보고서 생성 화면'));
  }
}

// lib/screens/reports/statistics_screen.dart
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('통계 화면'));
  }
}

// lib/screens/settings/user_management_screen.dart
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('사용자 관리 화면'));
  }
}

// lib/screens/settings/settings_screen.dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('시스템 설정 화면'));
  }
}