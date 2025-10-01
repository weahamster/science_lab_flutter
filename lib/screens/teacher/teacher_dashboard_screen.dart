import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatelessWidget {
  final Function(String)? onMenuSelect;
  
  const TeacherDashboardScreen({
    super.key,
    this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? 3 : 2;
    
    final menuItems = [
      {
        'title': '물품 구입',
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
      {
        'title': '강의 관리',
        'icon': Icons.school,
        'color': Colors.green,
      },
      {
        'title': '재료 신청 관리',
        'icon': Icons.inbox,
        'color': Colors.orange,
      },
      {
        'title': '물품 관리',
        'icon': Icons.inventory,
        'color': Colors.purple,
      },
      {
        'title': '기자재 관리',
        'icon': Icons.precision_manufacturing,
        'color': Colors.red,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '메뉴',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuCard(
                  context,
                  title: item['title'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  onTap: () {
                    // 콜백 함수 호출
                    if (onMenuSelect != null) {
                      onMenuSelect!(item['title'] as String);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}