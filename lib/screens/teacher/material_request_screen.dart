import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/material_request.dart';
import '../../services/teacher/material_service.dart';

class MaterialRequestScreen extends StatefulWidget {
  const MaterialRequestScreen({super.key});

  @override
  State<MaterialRequestScreen> createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  List<MaterialRequest> _allRequests = [];
  List<MaterialRequest> _filteredRequests = [];
  Set<String> _selectedIds = {};
  bool _isLoading = false;
  bool _selectAll = false;
  String _searchQuery = '';
  String _selectedCourse = '모든 강의';
  String _selectedStatus = '모든 상태';
  
  Map<String, Map<String, dynamic>> _experimentsData = {};
  
  Set<String> _expandedCourses = {};
  Set<String> _expandedExperiments = {};
  
  final _statusOptions = ['확인요청', '주문예정', '도착완료', '교내물품활용'];
  final _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await MaterialService.getAllRequestsWithRelations();
      
      setState(() {
        _allRequests = [];
        _experimentsData = {};
        
        for (var item in response) {
          _allRequests.add(MaterialRequest.fromJson(item));
          
          if (item['experiments'] != null) {
            _experimentsData[item['id']] = item['experiments'];
          }
        }
        _applyFilters();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRequests = _allRequests.where((request) {
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final materialName = request.name.toLowerCase();
          final experimentData = _experimentsData[request.id];
          final experimentTitle = (experimentData?['title'] ?? '').toLowerCase();
          
          if (!materialName.contains(query) && !experimentTitle.contains(query)) {
            return false;
          }
        }
        
        if (_selectedCourse != '모든 강의') {
          final experimentData = _experimentsData[request.id];
          if (experimentData?['courses']?['title'] != _selectedCourse) {
            return false;
          }
        }
        
        if (_selectedStatus != '모든 상태') {
          if (request.deliveryStatus != _selectedStatus) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  Map<String, Map<String, List<MaterialRequest>>> _getGroupedData() {
    final grouped = <String, Map<String, List<MaterialRequest>>>{};
    
    for (var request in _filteredRequests) {
      final experimentData = _experimentsData[request.id];
      final courseTitle = experimentData?['courses']?['title'] ?? '미분류';
      final experimentTitle = experimentData?['title'] ?? '미분류';
      
      grouped.putIfAbsent(courseTitle, () => {});
      grouped[courseTitle]!.putIfAbsent(experimentTitle, () => []);
      grouped[courseTitle]![experimentTitle]!.add(request);
    }
    
    return grouped;
  }

  void _toggleCourseSelection(String courseTitle, Map<String, List<MaterialRequest>> experiments) {
    final allRequests = experiments.values.expand((requests) => requests).toList();
    final allIds = allRequests.map((r) => r.id).toSet();
    final allSelected = allIds.every((id) => _selectedIds.contains(id));
    
    setState(() {
      if (allSelected) {
        _selectedIds.removeAll(allIds);
      } else {
        _selectedIds.addAll(allIds);
      }
    });
  }

  void _toggleExperimentSelection(List<MaterialRequest> requests) {
    final allIds = requests.map((r) => r.id).toSet();
    final allSelected = allIds.every((id) => _selectedIds.contains(id));
    
    setState(() {
      if (allSelected) {
        _selectedIds.removeAll(allIds);
      } else {
        _selectedIds.addAll(allIds);
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
    });
  }

  // 수정 다이얼로그 메서드 추가
  void _showEditRequestDialog(MaterialRequest request) {
    final nameController = TextEditingController(text: request.name);
    final quantityController = TextEditingController(text: request.quantity.toString());
    final priceController = TextEditingController(text: request.price.toString());
    final unitController = TextEditingController(text: request.unit ?? 'EA');
    final linkController = TextEditingController(text: request.link ?? '');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('재료 신청 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '품목명',
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
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: '단위',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '단가 (원)',
                  border: OutlineInputBorder(),
                ),
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
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(milliseconds: 100)),
                      builder: (context, snapshot) {
                        final quantity = int.tryParse(quantityController.text) ?? 0;
                        final price = int.tryParse(priceController.text) ?? 0;
                        final total = quantity * price;
                        return Text(
                          '${_numberFormat.format(total)}원',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: '구매 링크 (선택)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
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
                  const SnackBar(content: Text('품목명을 입력해주세요')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              await MaterialService.updateRequest(
                request.id,
                name: nameController.text.trim(),
                quantity: int.tryParse(quantityController.text) ?? 1,
                price: int.tryParse(priceController.text) ?? 0,
                unit: unitController.text.trim(),
                link: linkController.text.trim(),
              );
              
              _loadRequests();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신청이 수정되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('수정', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String requestId, String status) async {
    setState(() {
      final index = _allRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _allRequests[index] = _allRequests[index].copyWith(deliveryStatus: status);
      }
      _applyFilters();
    });

    final success = await MaterialService.updateStatus(requestId, status);
    if (!success) {
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('상태 변경 실패. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      final success = await MaterialService.deleteMultipleRequests(_selectedIds.toList());
      if (success) {
        setState(() {
          _selectedIds.clear();
          _selectAll = false;
        });
        _loadRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택한 항목이 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhoneScreen = screenWidth < 600;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalAmount = _filteredRequests.fold<int>(
      0, 
      (sum, request) => sum + (request.quantity * request.price),
    );

    final courseList = <String>['모든 강의'];
    final uniqueCourses = _experimentsData.values
        .map((exp) => exp['courses']?['title'] as String?)
        .where((title) => title != null)
        .cast<String>()
        .toSet();
    courseList.addAll(uniqueCourses);

    final groupedData = _getGroupedData();

    return Column(
      children: [
        // 상단 필터 바
        Container(
          padding: EdgeInsets.all(isPhoneScreen ? 8 : 16),
          color: Colors.white,
          child: isPhoneScreen
              ? Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '품목명, 실험명으로 검색...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedCourse,
                            isExpanded: true,
                            items: courseList.map<DropdownMenuItem<String>>(
                              (course) => DropdownMenuItem<String>(
                                value: course,
                                child: Text(
                                  course,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _selectedCourse = value;
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: ['모든 상태', ..._statusOptions]
                                .map((status) => DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(
                                        status,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _selectedStatus = value;
                                _applyFilters();
                              }
                            },
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
                          hintText: '품목명, 실험명으로 검색...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 2,
                      child: DropdownButton<String>(
                        value: _selectedCourse,
                        isExpanded: true,
                        items: courseList.map<DropdownMenuItem<String>>(
                          (course) => DropdownMenuItem<String>(
                            value: course,
                            child: Text(course),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _selectedCourse = value;
                            _applyFilters();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 2,
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: ['모든 상태', ..._statusOptions]
                            .map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _selectedStatus = value;
                            _applyFilters();
                          }
                        },
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
              Flexible(
                child: Text(
                  '선택: ${_selectedIds.length}/${_filteredRequests.length}',
                  style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isPhoneScreen)
                      Text(
                        '총: ${_numberFormat.format(totalAmount)}원',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadRequests,
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
              ),
            ],
          ),
        ),
        
        // 토글 테이블
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                children: groupedData.entries.map((courseEntry) {
                  final courseTitle = courseEntry.key;
                  final experiments = courseEntry.value;
                  final courseExpanded = _expandedCourses.contains(courseTitle);
                  
                  final courseRequests = experiments.values.expand((r) => r).toList();
                  final courseAllSelected = courseRequests.isNotEmpty &&
                      courseRequests.every((r) => _selectedIds.contains(r.id));
                  
                  return Column(
                    children: [
                      Container(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          dense: isPhoneScreen,
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: isPhoneScreen ? 0.8 : 1.0,
                                child: Checkbox(
                                  value: courseAllSelected,
                                  onChanged: (_) => _toggleCourseSelection(courseTitle, experiments),
                                ),
                              ),
                              Icon(
                                courseExpanded ? Icons.expand_less : Icons.expand_more,
                                size: isPhoneScreen ? 20 : 24,
                              ),
                            ],
                          ),
                          title: Text(
                            '📚 $courseTitle (${experiments.length}개)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isPhoneScreen ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              if (courseExpanded) {
                                _expandedCourses.remove(courseTitle);
                              } else {
                                _expandedCourses.add(courseTitle);
                              }
                            });
                          },
                        ),
                      ),
                      
                      if (courseExpanded) ...experiments.entries.map((experimentEntry) {
                        final experimentTitle = experimentEntry.key;
                        final requests = experimentEntry.value;
                        final experimentKey = '$courseTitle-$experimentTitle';
                        final experimentExpanded = _expandedExperiments.contains(experimentKey);
                        
                        final experimentAllSelected = requests.isNotEmpty &&
                            requests.every((r) => _selectedIds.contains(r.id));
                        
                        return Column(
                          children: [
                            Container(
                              color: Colors.green.shade50,
                              padding: EdgeInsets.only(left: isPhoneScreen ? 10 : 20),
                              child: ListTile(
                                dense: isPhoneScreen,
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.scale(
                                      scale: isPhoneScreen ? 0.8 : 1.0,
                                      child: Checkbox(
                                        value: experimentAllSelected,
                                        onChanged: (_) => _toggleExperimentSelection(requests),
                                      ),
                                    ),
                                    Icon(
                                      experimentExpanded ? Icons.expand_less : Icons.expand_more,
                                      size: isPhoneScreen ? 18 : 20,
                                    ),
                                  ],
                                ),
                                title: Text(
                                  '🧪 $experimentTitle (${requests.length}개)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isPhoneScreen ? 13 : 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (experimentExpanded) {
                                      _expandedExperiments.remove(experimentKey);
                                    } else {
                                      _expandedExperiments.add(experimentKey);
                                    }
                                  });
                                },
                              ),
                            ),
                            
                            if (experimentExpanded) ...requests.map((request) {
                              return Container(
                                padding: EdgeInsets.only(left: isPhoneScreen ? 20 : 40),
                                child: ListTile(
                                  dense: isPhoneScreen,
                                  leading: Transform.scale(
                                    scale: isPhoneScreen ? 0.8 : 1.0,
                                    child: Checkbox(
                                      value: _selectedIds.contains(request.id),
                                      onChanged: (_) => _toggleSelect(request.id),
                                    ),
                                  ),
                                  title: Text(
                                    request.name,
                                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${request.quantity}${request.unit ?? 'EA'} | '
                                    '${_numberFormat.format(request.price)}원',
                                    style: TextStyle(fontSize: isPhoneScreen ? 10 : 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: isPhoneScreen ? 18 : 20,
                                        ),
                                        onPressed: () => _showEditRequestDialog(request),
                                        padding: const EdgeInsets.all(2),
                                        constraints: const BoxConstraints(),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(maxWidth: isPhoneScreen ? 100 : 120),
                                        child: DropdownButton<String>(
                                          value: request.deliveryStatus ?? '확인요청',
                                          isExpanded: true,
                                          isDense: isPhoneScreen,
                                          underline: const SizedBox(),
                                          items: _statusOptions.map((status) {
                                            return DropdownMenuItem<String>(
                                              value: status,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: isPhoneScreen ? 4 : 8,
                                                  vertical: isPhoneScreen ? 2 : 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(status),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: isPhoneScreen ? 10 : 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              _updateStatus(request.id, value);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case '확인요청':
        return Colors.orange;
      case '주문예정':
        return Colors.blue;
      case '도착완료':
        return Colors.green;
      case '교내물품활용':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}