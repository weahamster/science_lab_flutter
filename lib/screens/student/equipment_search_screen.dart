import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EquipmentSearchScreen extends StatefulWidget {
  const EquipmentSearchScreen({super.key});

  @override
  State<EquipmentSearchScreen> createState() => _EquipmentSearchScreenState();
}

class _EquipmentSearchScreenState extends State<EquipmentSearchScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _equipment = [];
  List<Map<String, dynamic>> _filteredEquipment = [];
  String _searchQuery = '';
  bool _isLoading = true;
  
  // 통계
  int _totalEquipment = 0;
  int _availableCount = 0;
  int _repairCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('equipment')
          .select('*')
          .order('name');
      
      final equipmentList = List<Map<String, dynamic>>.from(response);
      
      setState(() {
        _equipment = equipmentList;
        _totalEquipment = equipmentList.length;
        _availableCount = equipmentList.where((e) => e['status'] == 'normal').length;
        _repairCount = equipmentList.where((e) => e['status'] == 'repair').length;
        _applyFilter();
      });
    } catch (e) {
      print('Error loading equipment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredEquipment = _equipment.where((item) {
        return _searchQuery.isEmpty ||
            item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item['model'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'normal':
        return '정상';
      case 'repair':
        return '수리중';
      case 'broken':
        return '고장';
      case 'lost':
        return '분실';
      default:
        return '알수없음';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'repair':
        return Colors.orange;
      case 'broken':
        return Colors.red;
      case 'lost':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showImageDialog(String? imageUrl, String itemName) {
    if (imageUrl == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black54),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            padding: const EdgeInsets.all(40),
                            color: Colors.white,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isPhoneScreen = screenWidth < 600;

    return Column(
      children: [
        // 검색 바
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '기자재명, 모델명 또는 위치로 검색...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilter();
                },
              ),
              const SizedBox(height: 12),
              // 통계
              Row(
                children: [
                  _buildStatCard('전체 기자재', '$_totalEquipment개', Colors.purple),
                  const SizedBox(width: 8),
                  _buildStatCard('총 수량', '${_availableCount}개', Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatCard('보관 위치', '3곳', Colors.green),
                ],
              ),
            ],
          ),
        ),
        
        // 테이블
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: isPhoneScreen ? 15 : 30,
                columns: [
                  DataColumn(label: Text('번호', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('사진', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('기자재명', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('모델명', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('수량', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('위치', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('상태', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('비고', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                ],
                rows: _filteredEquipment.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            if (item['image_url'] != null) {
                              _showImageDialog(item['image_url'], item['name'] ?? '기자재');
                            }
                          },
                          child: Container(
                            width: isPhoneScreen ? 40 : 50,
                            height: isPhoneScreen ? 40 : 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: item['image_url'] != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          item['image_url'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.image_not_supported),
                                        ),
                                      ),
                                      Positioned(
                                        right: 2,
                                        bottom: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: const Icon(
                                            Icons.zoom_in,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.precision_manufacturing, color: Colors.grey),
                          ),
                        ),
                      ),
                      DataCell(Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          fontSize: isPhoneScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                      DataCell(Text(
                        item['model'] ?? '-',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(Text(
                        '${item['quantity'] ?? 0}개',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              item['location'] ?? '화학실',
                              style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(item['status']),
                            style: TextStyle(
                              fontSize: isPhoneScreen ? 11 : 12,
                              color: _getStatusColor(item['status']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(
                        item['notes'] ?? '-',
                        style: TextStyle(
                          fontSize: isPhoneScreen ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}