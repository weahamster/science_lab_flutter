// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 화면 imports
import 'home_screen.dart';
import 'login_screen.dart';

// 실험 관련 화면들
import 'experiments/experiment_list_screen.dart';
import 'experiments/new_experiment_screen.dart';
import 'experiments/experiment_report_screen.dart';

// 장비 관련 화면들
import 'equipment/equipment_list_screen.dart';
import 'equipment/equipment_reservation_screen.dart';
import 'equipment/maintenance_screen.dart';

// 재고 관련 화면들
import 'inventory/inventory_screen.dart';
import 'inventory/chemical_list_screen.dart';
import 'inventory/purchase_request_screen.dart';

// 보고서 관련 화면들
import 'reports/report_screen.dart';
import 'reports/data_analysis_screen.dart';
import 'reports/report_generator_screen.dart';
import 'reports/statistics_screen.dart';

// 설정 관련 화면들
import 'settings/user_management_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _currentTitle = '홈';
  Widget _currentScreen = const HomeScreen();
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToScreen(String title, Widget screen) {
    setState(() {
      _currentTitle = title;
      _currentScreen = screen;
      _selectedIndex = -1; // 하단 네비게이션 선택 해제
    });
    Navigator.pop(context); // Drawer 닫기
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          _currentTitle,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // 알림 화면
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              // 프로필 화면
            },
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: _currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            switch (index) {
              case 0:
                _currentTitle = '홈';
                _currentScreen = const HomeScreen();
                break;
              case 1:
                _currentTitle = '실험';
                _currentScreen = const ExperimentListScreen();
                break;
              case 2:
                _currentTitle = '장비';
                _currentScreen = const EquipmentListScreen();
                break;
              case 3:
                _currentTitle = '재고';
                _currentScreen = const InventoryScreen();
                break;
              case 4:
                _currentTitle = '더보기';
                // 더보기 화면
                break;
            }
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: '실험',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: '장비',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '재고',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: '더보기',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
            ),
            child: Column(
              children: [
                // 프로필 정보
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? '사용자',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '실험실 관리자',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // 메뉴 리스트
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 실험 관리 섹션
                _buildSectionHeader('실험 관리'),
                _buildDrawerItem(
                  icon: Icons.science,
                  title: '실험 목록',
                  onTap: () {
                    _navigateToScreen('실험 목록', ExperimentListScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.add_circle_outline,
                  title: '새 실험 등록',
                  onTap: () {
                    _navigateToScreen('새 실험 등록', NewExperimentScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assignment,
                  title: '실험 보고서',
                  onTap: () {
                    _navigateToScreen('실험 보고서', ExperimentReportScreen());
                  },
                ),
                
                const Divider(),
                
                // 장비 관리 섹션
                _buildSectionHeader('장비 관리'),
                _buildDrawerItem(
                  icon: Icons.devices,
                  title: '장비 목록',
                  onTap: () {
                    _navigateToScreen('장비 목록', EquipmentListScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: '장비 예약',
                  onTap: () {
                    _navigateToScreen('장비 예약', EquipmentReservationScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.build,
                  title: '유지보수 일정',
                  onTap: () {
                    _navigateToScreen('유지보수 일정', MaintenanceScreen());
                  },
                ),
                
                const Divider(),
                
                // 재고 관리 섹션
                _buildSectionHeader('재고 관리'),
                _buildDrawerItem(
                  icon: Icons.inventory,
                  title: '재고 현황',
                  onTap: () {
                    _navigateToScreen('재고 현황', InventoryScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.warning_amber,
                  title: '화학물질 관리',
                  onTap: () {
                    _navigateToScreen('화학물질 관리', ChemicalListScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  title: '구매 요청',
                  onTap: () {
                    _navigateToScreen('구매 요청', PurchaseRequestScreen());
                  },
                ),
                
                const Divider(),
                
                // 데이터 분석 섹션
                _buildSectionHeader('데이터 & 보고서'),
                _buildDrawerItem(
                  icon: Icons.analytics,
                  title: '데이터 분석',
                  onTap: () {
                    _navigateToScreen('데이터 분석', DataAnalysisScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assessment,
                  title: '보고서 생성',
                  onTap: () {
                    _navigateToScreen('보고서 생성', ReportGeneratorScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: '통계',
                  onTap: () {
                    _navigateToScreen('통계', StatisticsScreen());
                  },
                ),
                
                const Divider(),
                
                // 설정 섹션
                _buildSectionHeader('설정'),
                _buildDrawerItem(
                  icon: Icons.people,
                  title: '사용자 관리',
                  onTap: () {
                    _navigateToScreen('사용자 관리', UserManagementScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: '시스템 설정',
                  onTap: () {
                    _navigateToScreen('시스템 설정', SettingsScreen());
                  },
                ),
              ],
            ),
          ),
          
          // 로그아웃 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}