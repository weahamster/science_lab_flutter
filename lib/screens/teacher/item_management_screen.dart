import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/teacher/item_service.dart';

class ItemManagementScreen extends StatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  Set<String> _selectedIds = {};
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '전체';
  
  final _categories = ['전체', '화학실', '생물실', '물리실', '지구과학실', '준비실'];
  final _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await ItemService.getSchoolItems();
      setState(() {
        _items = items;
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('물품 목록 로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesSearch = _searchQuery.isEmpty ||
            item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesCategory = _selectedCategory == '전체' ||
            item['location'] == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedIds = _filteredItems.map((i) => i['id'].toString()).toSet();
      } else {
        _selectedIds.clear();
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('선택한 ${_selectedIds.length}개 물품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      for (String id in _selectedIds) {
        await ItemService.deleteItem(id);
      }
      _selectedIds.clear();
      _loadItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 물품이 삭제되었습니다')),
      );
    }
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = 'EA';
    String selectedLocation = '화학실';
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('물품 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '물품명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '수량',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: '단위',
                        border: OutlineInputBorder(),
                      ),
                      items: ['EA', '개', '박스', 'kg', 'L', 'mL', 'g']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedUnit = value;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                decoration: const InputDecoration(
                  labelText: '위치',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .where((c) => c != '전체')
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedLocation = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '비고 (선택)',
                  hintText: '추가 정보나 주의사항',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('물품명을 입력해주세요')),
                );
                return;
              }
              
              Navigator.pop(context);
              await ItemService.addItem({
                'name': nameController.text.trim(),
                'quantity': int.parse(quantityController.text),
                'unit': selectedUnit,
                'location': selectedLocation,
                'note': noteController.text.trim(),
              });
              
              _loadItems();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('물품이 추가되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('추가', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final quantityController = TextEditingController(text: item['quantity'].toString());
    String selectedUnit = item['unit'] ?? 'EA';
    String selectedLocation = item['location'] ?? '화학실';
    final noteController = TextEditingController(text: item['note'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('물품 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '물품명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '수량',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: '단위',
                        border: OutlineInputBorder(),
                      ),
                      items: ['EA', '개', '박스', 'kg', 'L', 'mL', 'g']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedUnit = value;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                decoration: const InputDecoration(
                  labelText: '위치',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .where((c) => c != '전체')
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedLocation = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '비고',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ItemService.updateItem(item['id'], {
                'name': nameController.text.trim(),
                'quantity': int.parse(quantityController.text),
                'unit': selectedUnit,
                'location': selectedLocation,
                'note': noteController.text.trim(),
              });
              
              _loadItems();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('물품이 수정되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('수정', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhoneScreen = screenWidth < 600;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 상단 검색/필터 바
        Container(
          padding: EdgeInsets.all(isPhoneScreen ? 8 : 16),
          color: Colors.white,
          child: isPhoneScreen
              ? Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '물품명으로 검색...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFilter();
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _categories
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _selectedCategory = value;
                                _applyFilter();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showAddItemDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('추가'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '물품명으로 검색...',
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
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: _categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _selectedCategory = value;
                            _applyFilter();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddItemDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('물품 추가'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
        
        // 액션 바
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPhoneScreen ? 8 : 16,
            vertical: 8,
          ),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: isPhoneScreen ? 0.8 : 1.0,
                    child: Checkbox(
                      value: _selectedIds.length == _filteredItems.length &&
                             _filteredItems.isNotEmpty,
                      onChanged: _toggleSelectAll,
                    ),
                  ),
                  Text(
                    isPhoneScreen
                        ? '${_selectedIds.length}/${_filteredItems.length}'
                        : '전체 선택 (${_selectedIds.length}/${_filteredItems.length})',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '총 ${_filteredItems.length}개',
                    style: TextStyle(
                      fontSize: isPhoneScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _loadItems,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  if (_selectedIds.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: _deleteSelected,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // 테이블
        Expanded(
          child: _filteredItems.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty && _selectedCategory == '전체'
                        ? '등록된 물품이 없습니다\n물품을 추가해주세요'
                        : '검색 결과가 없습니다',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: isPhoneScreen ? 12 : 30,
                      horizontalMargin: isPhoneScreen ? 8 : 24,
                      columns: [
                        const DataColumn(label: Text('')),
                        DataColumn(label: Text('제품명',
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('수량',
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('단위',
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('위치',
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('비고',
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('작업',
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                      ],
                      rows: _filteredItems.map((item) {
                        final id = item['id'].toString();
                        
                        return DataRow(
                          selected: _selectedIds.contains(id),
                          cells: [
                            DataCell(
                              Transform.scale(
                                scale: isPhoneScreen ? 0.8 : 1.0,
                                child: Checkbox(
                                  value: _selectedIds.contains(id),
                                  onChanged: (_) => _toggleSelect(id),
                                ),
                              ),
                            ),
                            DataCell(Text(
                              item['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isPhoneScreen ? 12 : 14,
                              ),
                            )),
                            DataCell(Text(
                              item['quantity'].toString(),
                              style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                            )),
                            DataCell(Text(
                              item['unit'] ?? 'EA',
                              style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                            )),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['location'] ?? '',
                                style: TextStyle(
                                  fontSize: isPhoneScreen ? 11 : 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            )),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: isPhoneScreen ? 80 : 150,
                                ),
                                child: Text(
                                  item['note'] ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: isPhoneScreen ? 11 : 13),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                      color: Colors.blue,
                                      size: isPhoneScreen ? 18 : 20,
                                    ),
                                    onPressed: () => _showEditItemDialog(item),
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                      color: Colors.red,
                                      size: isPhoneScreen ? 18 : 20,
                                    ),
                                    onPressed: () async {
                                      await ItemService.deleteItem(id);
                                      _loadItems();
                                    },
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
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