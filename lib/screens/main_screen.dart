import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'purchase/purchase_screen.dart';
import 'class_management/class_management_screen.dart';
import 'material_request/material_request_screen.dart';
import 'item_management/item_management_screen.dart';
import 'equipment_management/equipment_management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentTitle = '대시보드';
  Widget _currentScreen = DashboardScreen();  // const 제거

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
                            user?.email?.substring(0, 1).toUpperCase() ?? 'T',
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '교사',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                user?.email ?? 'teacher@school.com',
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
                      onTap: () => _selectMenu('대시보드', DashboardScreen()),  // const 제거
                      isSelected: _currentTitle == '대시보드',
                    ),
                    _buildMenuItem(
                      icon: Icons.shopping_cart,
                      title: '물품 구입',
                      onTap: () => _selectMenu('물품 구입', PurchaseScreen()),  // const 제거
                      isSelected: _currentTitle == '물품 구입',
                    ),
                    _buildMenuItem(
                      icon: Icons.school,
                      title: '강의 관리',
                      count: 1,
                      onTap: () => _selectMenu('강의 관리', ClassManagementScreen()),  // const 제거
                      isSelected: _currentTitle == '강의 관리',
                    ),
                    _buildMenuItem(
                      icon: Icons.inbox,
                      title: '재료 신청 관리',
                      count: 2,
                      onTap: () => _selectMenu('재료 신청 관리', MaterialRequestScreen()),  // const 제거
                      isSelected: _currentTitle == '재료 신청 관리',
                    ),
                    _buildMenuItem(
                      icon: Icons.inventory,
                      title: '물품 관리',
                      onTap: () => _selectMenu('물품 관리', ItemManagementScreen()),  // const 제거
                      isSelected: _currentTitle == '물품 관리',
                    ),
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: '기자재 관리',
                      onTap: () => _selectMenu('기자재 관리', EquipmentManagementScreen()),  // const 제거
                      isSelected: _currentTitle == '기자재 관리',
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