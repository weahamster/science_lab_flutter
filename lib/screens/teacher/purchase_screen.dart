import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/purchase_item.dart';
import '../../services/teacher/purchase_service.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final List<PurchaseItem> _items = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = false;
  bool _selectAll = false;
  final _numberFormat = NumberFormat('#,###');
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await PurchaseService.getPurchaseItems();
      setState(() {
        _items.clear();
        _items.addAll(items);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedIds.addAll(_items.map((item) => item.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectAll = _selectedIds.length == _items.length;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('선택한 ${_selectedIds.length}개 항목을 삭제하시겠습니까?'),
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
        await PurchaseService.deletePurchaseItem(id);
      }
      setState(() {
        _items.removeWhere((item) => _selectedIds.contains(item.id));
        _selectedIds.clear();
        _selectAll = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 항목이 삭제되었습니다')),
      );
    }
  }
  
  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');
    final linkController = TextEditingController();
    String selectedUnit = '개';
    int totalPrice = 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          void calculateTotal() {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            final price = int.tryParse(priceController.text) ?? 0;
            setDialogState(() {
              totalPrice = quantity * price;
            });
          }
          
          return AlertDialog(
            title: const Text('물품 추가'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '물품명',
                        hintText: '예: 비커 1000ml',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: '수량',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => calculateTotal(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: '단위',
                              border: OutlineInputBorder(),
                            ),
                            items: ['개', '박스', 'kg', 'L', 'mL', 'g', '세트']
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedUnit = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: '단가 (원)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => calculateTotal(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총금액'),
                          Text(
                            '${_numberFormat.format(totalPrice)}원',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: '구매 링크 (선택사항)',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
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
                  
                  Navigator.of(dialogContext).pop();
                  
                  final newItem = PurchaseItem(
                    id: '',
                    name: nameController.text.trim(),
                    quantity: int.tryParse(quantityController.text) ?? 1,
                    unit: selectedUnit,
                    price: int.tryParse(priceController.text) ?? 0,
                    link: linkController.text.trim(),
                  );
                  
                  final savedItem = await PurchaseService.addPurchaseItem(newItem);
                  if (savedItem != null) {
                    setState(() {
                      _items.insert(0, savedItem);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('물품이 추가되었습니다')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('추가', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // 수정 다이얼로그 메서드 추가
  void _showEditItemDialog(PurchaseItem item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.price.toString());
    final linkController = TextEditingController(text: item.link);
    String selectedUnit = item.unit;
    int totalPrice = item.totalPrice;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          void calculateTotal() {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            final price = int.tryParse(priceController.text) ?? 0;
            setDialogState(() {
              totalPrice = quantity * price;
            });
          }
          
          return AlertDialog(
            title: const Text('물품 수정'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
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
                          flex: 2,
                          child: TextField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: '수량',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => calculateTotal(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: '단위',
                              border: OutlineInputBorder(),
                            ),
                            items: ['개', '박스', 'kg', 'L', 'mL', 'g', '세트']
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedUnit = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: '단가 (원)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => calculateTotal(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총금액'),
                          Text(
                            '${_numberFormat.format(totalPrice)}원',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: '구매 링크 (선택사항)',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
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
                  
                  Navigator.of(dialogContext).pop();
                  
                  final updatedItem = PurchaseItem(
                    id: item.id,
                    name: nameController.text.trim(),
                    quantity: int.tryParse(quantityController.text) ?? 1,
                    unit: selectedUnit,
                    price: int.tryParse(priceController.text) ?? 0,
                    link: linkController.text.trim(),
                  );
                  
                  await PurchaseService.updatePurchaseItem(updatedItem);
                  _loadItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('물품이 수정되었습니다')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('수정', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final totalAmount = _items.fold(0, (sum, item) => sum + item.totalPrice);
    
    return Column(
      children: [
        // 상단 요약 정보
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '물품 구입 신청',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '총 금액: ${_numberFormat.format(totalAmount)}원',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        
        // 액션 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: _toggleSelectAll,
                  ),
                  Text('전체 선택 (${_selectedIds.length}/${_items.length})'),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('물품 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedIds.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _deleteSelected,
                      icon: const Icon(Icons.delete),
                      label: Text('선택 삭제 (${_selectedIds.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // 테이블
        Expanded(
          child: Container(
            color: Colors.white,
            child: _items.isEmpty
                ? const Center(
                    child: Text('물품을 추가해주세요', style: TextStyle(color: Colors.grey)),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                        columns: const [
                          DataColumn(label: Text('')),
                          DataColumn(label: Text('물품명')),
                          DataColumn(label: Text('수량')),
                          DataColumn(label: Text('단가')),
                          DataColumn(label: Text('총액')),
                          DataColumn(label: Text('링크')),
                          DataColumn(label: Text('작업')),
                        ],
                        rows: _items.map((item) {
                          return DataRow(
                            selected: _selectedIds.contains(item.id),
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: _selectedIds.contains(item.id),
                                  onChanged: (_) => _toggleSelect(item.id),
                                ),
                              ),
                              DataCell(Text(item.name)),
                              DataCell(Text('${item.quantity} ${item.unit}')),
                              DataCell(Text('${_numberFormat.format(item.price)}원')),
                              DataCell(
                                Text(
                                  '${_numberFormat.format(item.totalPrice)}원',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                item.link.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.link, color: Colors.blue),
                                        onPressed: () {
                                          // 링크 열기 기능
                                        },
                                      )
                                    : const Text('-'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditItemDialog(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () async {
                                        await PurchaseService.deletePurchaseItem(item.id);
                                        setState(() {
                                          _items.removeWhere((i) => i.id == item.id);
                                        });
                                      },
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
        ),
      ],
    );
  }
}