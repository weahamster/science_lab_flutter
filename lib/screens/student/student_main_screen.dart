import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/login_screen.dart';
import 'student_dashboard_screen.dart';
import 'student_courses_screen.dart';
import 'all_courses_screen.dart';
import 'feedback_history_screen.dart';
import 'inventory_search_screen.dart';
import 'equipment_search_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentTitle = '대시보드';
  late Widget _currentScreen;
  
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }
  
  void _initializeDashboard() {
    _currentScreen = StudentDashboardScreen(
      onMenuSelect: _handleMenuSelection,
    );
  }
  
  void _handleMenuSelection(String title) {
    setState(() {
      _currentTitle = title;
      switch (title) {
        case '참여 중인 강의':
          _currentScreen = StudentCoursesScreen();
          break;
        case '전체 강의':
          _currentScreen = AllCoursesScreen();
          break;
        case '물품 검색':
          _currentScreen = InventorySearchScreen();
          break;
        case '기자재 검색':
          _currentScreen = EquipmentSearchScreen();
          break;
      }
    });
  }

  void _selectMenu(String title, Widget screen) {
    setState(() {
      _currentTitle = title;
      _currentScreen = screen;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
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
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 30,
                          child: Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? 'S',
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '학생2',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '테스트학교',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      icon: Icons.home,
                      title: '대시보드',
                      onTap: () {
                        _selectMenu('대시보드', StudentDashboardScreen(
                          onMenuSelect: _handleMenuSelection,
                        ));
                      },
                      isSelected: _currentTitle == '대시보드',
                    ),
                    _buildMenuItem(
                      icon: Icons.book,
                      title: '참여 중인 강의',
                      count: 1,
                      onTap: () => _selectMenu('참여 중인 강의', StudentCoursesScreen()),
                      isSelected: _currentTitle == '참여 중인 강의',
                    ),
                    _buildMenuItem(
                      icon: Icons.school,
                      title: '전체 강의 목록',
                      count: 1,
                      onTap: () => _selectMenu('전체 강의 목록', AllCoursesScreen()),
                      isSelected: _currentTitle == '전체 강의 목록',
                    ),
                    _buildMenuItem(
                      icon: Icons.feedback,
                      title: '피드백 히스토리',
                      onTap: () => _selectMenu('피드백 히스토리', FeedbackHistoryScreen()),
                      isSelected: _currentTitle == '피드백 히스토리',
                    ),
                    _buildMenuItem(
                      icon: Icons.inventory,
                      title: '물품 검색',
                      onTap: () => _selectMenu('물품 검색', InventorySearchScreen()),
                      isSelected: _currentTitle == '물품 검색',
                    ),
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: '기자재 검색',
                      onTap: () => _selectMenu('기자재 검색', EquipmentSearchScreen()),
                      isSelected: _currentTitle == '기자재 검색',
                    ),
                    
                    const Divider(height: 30),
                    
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('로그아웃'),
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      body: _currentScreen,
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int? count,
    bool isSelected = false,
  }) {
    return Container(
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: count != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}