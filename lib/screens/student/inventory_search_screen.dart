import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student/search_service.dart';


class InventorySearchScreen extends StatefulWidget {
  const InventorySearchScreen({super.key});

  @override
  State<InventorySearchScreen> createState() => _InventorySearchScreenState();
}

class _InventorySearchScreenState extends State<InventorySearchScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _filteredInventory = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final items = await StudentSearchService.searchInventory(searchQuery: _searchQuery);
      
      setState(() {
        _inventory = List<Map<String, dynamic>>.from(response);
        _applyFilter();
      });
    } catch (e) {
      print('Error loading inventory: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredInventory = _inventory.where((item) {
        return _searchQuery.isEmpty ||
            item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
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
          child: TextField(
            decoration: InputDecoration(
              hintText: '물품명 또는 위치로 검색...',
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
        ),
        
        // 테이블
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: isPhoneScreen ? 20 : 40,
                columns: [
                  DataColumn(label: Text('재료명', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('수량', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('단위', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('위치', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('비고', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                ],
                rows: _filteredInventory.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          fontSize: isPhoneScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                      DataCell(
                        Text(
                          '${item['quantity'] ?? 0}',
                          style: TextStyle(
                            fontSize: isPhoneScreen ? 12 : 14,
                            color: (item['quantity'] ?? 0) < 10 ? Colors.red : Colors.black,
                            fontWeight: (item['quantity'] ?? 0) < 10 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      DataCell(Text(
                        item['unit'] ?? 'EA',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              item['location'] ?? '준비실',
                              style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                            ),
                          ],
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
}