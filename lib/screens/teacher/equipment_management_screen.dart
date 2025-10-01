import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../services/teacher/equipment_service.dart';
import '../../config/database_schema.dart';

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

  static const List<String> webVisibleColumns = [
    'image_url',  // 사진
    'name',       // 기자재명  
    'model',      // 모델명
    'quantity',   // 수량
    'location',   // 위치
    'status',     // 상태
    'notes',      // 비고
  ];

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
    String selectedStatus = 'normal';  // 영어로 초기값
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
                  'status': 'normal',  // 영어로 저장
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

  void _showEditEquipmentDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final modelController = TextEditingController(text: item['model'] ?? '');
    final serialController = TextEditingController(text: item['serial_number'] ?? '');
    final quantityController = TextEditingController(text: (item['quantity'] ?? 1).toString());
    String selectedCategory = item['category'] ?? '실험기구';
    String selectedLocation = item['location'] ?? '화학실';
    String selectedStatus = item['status'] ?? 'normal';  // 영어 상태값
    final notesController = TextEditingController(text: item['notes'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('기자재 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
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
                    if (value != null) {
                      setDialogState(() {
                        selectedLocation = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '상태',
                    border: OutlineInputBorder(),
                  ),
                  items: ['normal', 'repair', 'broken', 'lost']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusDisplayName(status)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
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
                
                await EquipmentService.updateEquipment(
                  item['id'],
                  {
                    'name': nameController.text.trim(),
                    'model': modelController.text.trim(),
                    'serial_number': serialController.text.trim(),
                    'category': selectedCategory,
                    'quantity': int.parse(quantityController.text),
                    'location': selectedLocation,
                    'status': selectedStatus,  // 영어로 저장
                    'notes': notesController.text.trim(),
                  },
                );
                
                _loadEquipment();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('기자재가 수정되었습니다')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('수정', style: TextStyle(color: Colors.white)),
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
        
        // 테이블 위의 액션 바 (새로고침 버튼)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPhoneScreen ? 8 : 16,
            vertical: 8,
          ),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체: ${_filteredEquipment.length}개',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _loadEquipment,
                tooltip: '새로고침',
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
                  DataColumn(label: Text('작업',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                ],
                rows: _filteredEquipment.map((item) {
                  return DataRow(
                    cells: [
                      // 사진
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            if (item['image_url'] != null) {
                              _showImageDialog(item['image_url'], item['name'] ?? '기자재');
                            }
                          },
                          child: Container(
                            width: isPhoneScreen ? 40 : 60,
                            height: isPhoneScreen ? 40 : 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                              border: item['image_url'] != null 
                                  ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                if (item['image_url'] != null)
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
                                  )
                                else
                                  const Center(
                                    child: Icon(Icons.precision_manufacturing, color: Colors.grey),
                                  ),
                                // 확대 가능 표시
                                if (item['image_url'] != null)
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
                            ),
                          ),
                        ),
                      ),
                      // 기자재명
                      DataCell(Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isPhoneScreen ? 12 : 14,
                        ),
                      )),
                      // 모델명
                      DataCell(Text(
                        item['model'] ?? '-',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      // 수량
                      DataCell(Text(
                        '${item['quantity'] ?? 0}',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      // 위치  
                      DataCell(Text(
                        item['location'] ?? '',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      // 상태 (드롭다운으로 수정 가능)
                      DataCell(
                        DropdownButton<String>(
                          value: item['status'] ?? 'normal',
                          underline: const SizedBox(),
                          isDense: true,
                          items: ['normal', 'repair', 'broken', 'lost']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getStatusDisplayName(status),
                                        style: TextStyle(
                                          fontSize: isPhoneScreen ? 11 : 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (newStatus) async {
                            if (newStatus != null) {
                              // 화면만 즉시 업데이트 (새로고침 없음)
                              setState(() {
                                item['status'] = newStatus;
                              });
                              
                              // DB 업데이트는 백그라운드에서
                              try {
                                await EquipmentService.updateEquipment(
                                  item['id'],
                                  {'status': newStatus},
                                );
                              } catch (e) {
                                // 실패 시 원래 상태로 복원
                                setState(() {
                                  // 원래 상태 찾기
                                  final originalItem = _equipment.firstWhere(
                                    (eq) => eq['id'] == item['id'],
                                    orElse: () => item,
                                  );
                                  item['status'] = originalItem['status'];
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('상태 업데이트 실패: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      // 비고
                      DataCell(Text(
                        item['notes'] ?? '-',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      // 작업
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                              color: Colors.blue,
                              size: isPhoneScreen ? 18 : 20),
                            onPressed: () => _showEditEquipmentDialog(item),
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                              color: Colors.red,
                              size: isPhoneScreen ? 18 : 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('삭제 확인'),
                                  content: const Text('이 기자재를 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('삭제', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true) {
                                await EquipmentService.deleteEquipment(item['id']);
                                _loadEquipment();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('기자재가 삭제되었습니다')),
                                );
                              }
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
  
  // 영어 상태를 색상으로 매핑
  Color _getStatusColor(String status) {
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
  
  // 영어 상태를 한글로 표시
  String _getStatusDisplayName(String status) {
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
        return status;
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
            // 배경 터치로 닫기
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black54),
            ),
            // 이미지
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
            // 닫기 버튼
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
}