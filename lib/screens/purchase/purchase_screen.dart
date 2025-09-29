import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/purchase_item.dart';
import '../../services/purchase_service.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final List<PurchaseItem> _items = [];
  bool _isLoading = false;
  
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
                    // 물품명 - 한글 입력 수정
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '물품명',
                          hintText: '예: 비커 1000ml',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        onChanged: (value) {
                          setDialogState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 수량과 단위
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
                    
                    // 단가
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
                    
                    // 총금액
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총금액'),
                          Text(
                            '$totalPrice원',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 링크
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
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
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
                  setState(() => _isLoading = true);
                  
                  try {
                    await _addItem(
                      nameController.text.trim(),
                      int.tryParse(quantityController.text) ?? 1,
                      selectedUnit,
                      int.tryParse(priceController.text) ?? 0,
                      linkController.text.trim(),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('물품이 추가되었습니다')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('추가 실패: $e')),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('추가', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _addItem(String name, int quantity, String unit, int price, String link) async {
    final newItem = PurchaseItem(
      id: '',
      name: name,
      quantity: quantity,
      unit: unit,
      price: price,
      link: link,
    );
    
    final savedItem = await PurchaseService.addPurchaseItem(newItem);
    if (savedItem != null && mounted) {
      setState(() {
        _items.insert(0, savedItem);
      });
    } else {
      throw Exception('저장 실패');
    }
  }
  
  Future<void> _deleteItem(String itemId) async {
    final success = await PurchaseService.deletePurchaseItem(itemId);
    if (success) {
      setState(() {
        _items.removeWhere((item) => item.id == itemId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    '물품 구입 신청',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '구입 목록: ${_items.length}개',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '총액: ${_items.fold(0, (sum, item) => sum + item.totalPrice).toString()}원',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _items.isEmpty
                ? const Center(
                    child: Text('물품을 추가해주세요', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('수량: ${item.quantity} ${item.unit}'),
                              Text('단가: ${item.price}원 | 총액: ${item.totalPrice}원'),
                              if (item.link.isNotEmpty)
                                Text(
                                  '링크: ${item.link}',
                                  style: const TextStyle(color: Colors.blue),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteItem(item.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text('물품 추가'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}