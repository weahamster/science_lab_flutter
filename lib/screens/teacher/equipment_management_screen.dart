import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../services/teacher/equipment_service.dart';

class EquipmentManagementScreen extends StatefulWidget {
  const EquipmentManagementScreen({super.key});

  @override
  State<EquipmentManagementScreen> createState() => _EquipmentManagementScreenState();
}

class _EquipmentManagementScreenState extends State<EquipmentManagementScreen> {
  List<Map<String, dynamic>> _equipment = [];
  List<Map<String, dynamic>> _filteredEquipment = [];
  Set<String> _selectedIds = {};
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '전체';
  
  final _categories = ['전체', '실험기구', '측정장비', '안전장비', '전자기기', '기타'];
  final _numberFormat = NumberFormat('#,###');
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() => _isLoading = true);
    try {
      final equipment = await EquipmentService.getEquipment();
      setState(() {
        _equipment = equipment;
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기자재 목록 로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredEquipment = _equipment.where((item) {
        final matchesSearch = _searchQuery.isEmpty ||
            item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item['model'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesCategory = _selectedCategory == '전체' ||
            item['category'] == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final supabase = Supabase.instance.client;
      
      await supabase.storage
          .from('equipment-images')
          .upload(fileName, imageFile);
      
      final imageUrl = supabase.storage
          .from('equipment-images')
          .getPublicUrl(fileName);
      
      return imageUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  void _showAddEquipmentDialog() {
    final nameController = TextEditingController();
    final modelController = TextEditingController();
    final serialController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedCategory = '실험기구';
    String selectedLocation = '화학실';
    final notesController = TextEditingController();
    File? selectedImage;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('기자재 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 사진 선택 영역
                GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('카메라로 촬영'),
                              onTap: () async {
                                Navigator.pop(context);
                                final XFile? photo = await _picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (photo != null) {
                                  setDialogState(() {
                                    selectedImage = File(photo.path);
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('갤러리에서 선택'),
                              onTap: () async {
                                Navigator.pop(context);
                                final XFile? photo = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (photo != null) {
                                  setDialogState(() {
                                    selectedImage = File(photo.path);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('사진 추가', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '기자재명',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: modelController,
                        decoration: const InputDecoration(
                          labelText: '모델명',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: serialController,
                        decoration: const InputDecoration(
                          labelText: '시리얼번호',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '분류',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories
                            .where((c) => c != '전체')
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedCategory = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
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
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLocation,
                  decoration: const InputDecoration(
                    labelText: '위치',
                    border: OutlineInputBorder(),
                  ),
                  items: ['화학실', '생물실', '물리실', '지구과학실', '준비실']
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
                  controller: notesController,
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
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('기자재명을 입력해주세요')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                
                String? imageUrl;
                if (selectedImage != null) {
                  imageUrl = await _uploadImage(selectedImage!);
                }
                
                await EquipmentService.addEquipment({
                  'name': nameController.text.trim(),
                  'model': modelController.text.trim(),
                  'serial_number': serialController.text.trim(),
                  'category': selectedCategory,
                  'quantity': int.parse(quantityController.text),
                  'location': selectedLocation,
                  'notes': notesController.text.trim(),
                  'image_url': imageUrl,
                  'status': '정상',
                });
                
                _loadEquipment();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('기자재가 추가되었습니다')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('추가', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
                        hintText: '기자재명, 모델명 검색...',
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
                          onPressed: _showAddEquipmentDialog,
                          icon: const Icon(Icons.add_a_photo, size: 18),
                          label: const Text('추가'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
                          hintText: '기자재명, 모델명 검색...',
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
                      onPressed: _showAddEquipmentDialog,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('기자재 추가'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
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
                columnSpacing: isPhoneScreen ? 12 : 30,
                columns: [
                  DataColumn(label: Text('사진',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('기자재명',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('모델/시리얼',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('분류',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('수량',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('위치',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('상태',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('작업',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                ],
                rows: _filteredEquipment.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: isPhoneScreen ? 40 : 60,
                          height: isPhoneScreen ? 40 : 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: item['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    item['image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                )
                              : const Icon(Icons.precision_manufacturing, color: Colors.grey),
                        ),
                      ),
                      DataCell(Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isPhoneScreen ? 12 : 14,
                        ),
                      )),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (item['model'] != null && item['model'].isNotEmpty)
                            Text(item['model'],
                              style: TextStyle(fontSize: isPhoneScreen ? 11 : 13)),
                          if (item['serial_number'] != null && item['serial_number'].isNotEmpty)
                            Text(item['serial_number'],
                              style: TextStyle(fontSize: isPhoneScreen ? 10 : 12,
                                color: Colors.grey)),
                        ],
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['category'] ?? '',
                          style: TextStyle(
                            fontSize: isPhoneScreen ? 11 : 13,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      )),
                      DataCell(Text(
                        '${item['quantity'] ?? 0}',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(Text(
                        item['location'] ?? '',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item['status'] == '정상' 
                              ? Colors.green.shade50 
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status'] ?? '정상',
                          style: TextStyle(
                            fontSize: isPhoneScreen ? 11 : 13,
                            color: item['status'] == '정상'
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                              color: Colors.blue,
                              size: isPhoneScreen ? 18 : 20),
                            onPressed: () {
                              // 수정 기능
                            },
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                              color: Colors.red,
                              size: isPhoneScreen ? 18 : 20),
                            onPressed: () async {
                              await EquipmentService.deleteEquipment(item['id']);
                              _loadEquipment();
                            },
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                          ),
                        ],
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