import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  final Function(String)? onMenuSelect;
  
  const StudentDashboardScreen({
    super.key,
    this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? 4 : 2;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 카드들
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildMenuCard(
                title: '참여 중인 강의',
                subtitle: '내가 참여한 강의 목록',
                count: '1개',
                icon: Icons.book,
                color: Colors.blue,
                onTap: () {
                  if (onMenuSelect != null) {
                    onMenuSelect!('참여 중인 강의');
                  }
                },
              ),
              _buildMenuCard(
                title: '전체 강의',
                subtitle: '참여 가능한 전체 강의',
                count: '1개',
                icon: Icons.calendar_month,
                color: Colors.green,
                onTap: () {
                  if (onMenuSelect != null) {
                    onMenuSelect!('전체 강의');
                  }
                },
              ),
              _buildMenuCard(
                title: '물품 검색',
                subtitle: '실험 재료 검색 및 재고 확인',
                count: '',
                icon: Icons.inventory_2,
                color: Colors.purple,
                onTap: () {
                  if (onMenuSelect != null) {
                    onMenuSelect!('물품 검색');
                  }
                },
              ),
              _buildMenuCard(
                title: '기자재 검색',
                subtitle: '실험 기자재 대여 현황',
                count: '',
                icon: Icons.precision_manufacturing,
                color: Colors.orange,
                onTap: () {
                  if (onMenuSelect != null) {
                    onMenuSelect!('기자재 검색');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 최근 실험 섹션
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '최근 실험 신청 현황',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('전체보기'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExperimentItem(
                  date: '신과 염기',
                  time: '2025. 9. 28.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 피드백 히스토리
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '피드백 히스토리',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.feedback_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        '받은 피드백이 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildExperimentItem({
    required String date,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.science, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}