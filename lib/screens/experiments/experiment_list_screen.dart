// lib/screens/experiments/experiment_list_screen.dart

import 'package:flutter/material.dart';

class ExperimentListScreen extends StatefulWidget {
  const ExperimentListScreen({super.key});

  @override
  State<ExperimentListScreen> createState() => _ExperimentListScreenState();
}

class _ExperimentListScreenState extends State<ExperimentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  
  // 임시 데이터 (나중에 Supabase에서 가져올 예정)
  final List<Map<String, dynamic>> experiments = [
    {
      'id': '1',
      'title': '화학 반응 실험',
      'status': 'in_progress',
      'researcher': '김연구원',
      'date': '2024-01-20',
      'description': '산과 염기의 중화 반응 실험',
    },
    {
      'id': '2',
      'title': '세포 배양 실험',
      'status': 'completed',
      'researcher': '박연구원',
      'date': '2024-01-19',
      'description': 'HeLa 세포 배양 및 관찰',
    },
    {
      'id': '3',
      'title': '물리 실험',
      'status': 'pending',
      'researcher': '이연구원',
      'date': '2024-01-21',
      'description': '진자의 주기 측정 실험',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 바
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '실험 검색...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                // 검색 로직
              });
            },
          ),
        ),
        
        // 상태 필터 칩
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('전체', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('진행 중', 'in_progress'),
              const SizedBox(width: 8),
              _buildFilterChip('완료', 'completed'),
              const SizedBox(width: 8),
              _buildFilterChip('대기', 'pending'),
            ],
          ),
        ),
        
        // 실험 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: experiments.length,
            itemBuilder: (context, index) {
              final experiment = experiments[index];
              return _ExperimentCard(experiment: experiment);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == value,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }
}

// 실험 카드 위젯
class _ExperimentCard extends StatelessWidget {
  final Map<String, dynamic> experiment;

  const _ExperimentCard({required this.experiment});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (experiment['status']) {
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = '진행 중';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = '완료';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = '대기';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '알 수 없음';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 상세 화면으로 이동
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      experiment['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                experiment['description'],
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(experiment['researcher']),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(experiment['date']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}