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
  
  // 토글 상태
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

  // 강의 레벨에서 하위 모든 항목 선택
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

  // 실험 레벨에서 하위 모든 항목 선택
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

  Future<void> _updateStatus(String requestId, String status) async {
    // 먼저 UI를 즉시 업데이트 (낙관적 업데이트)
    setState(() {
      // 로컬 데이터에서 해당 항목 찾아서 상태 변경
      final requestIndex = _allRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        _allRequests[requestIndex] = MaterialRequest(
          id: _allRequests[requestIndex].id,
          experimentId: _allRequests[requestIndex].experimentId,
          quantity: _allRequests[requestIndex].quantity,
          price: _allRequests[requestIndex].price,
          createdAt: _allRequests[requestIndex].createdAt,
          deliveryStatus: status,  // 상태만 변경
          link: _allRequests[requestIndex].link,
          name: _allRequests[requestIndex].name,
          status: _allRequests[requestIndex].status,
          unit: _allRequests[requestIndex].unit,
        );
      }
      _applyFilters();  // 필터 재적용
    });

    // 백그라운드에서 서버 업데이트
    final success = await MaterialService.updateStatus(requestId, status);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상태가 "$status"로 변경되었습니다')),
      );
    } else {
      // 실패하면 다시 로드
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
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
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
              DropdownButton<String>(
                value: _selectedCourse,
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
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedStatus,
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
                  const Text('선택: '),
                  Text('${_selectedIds.length}개 / 총 ${_filteredRequests.length}개'),
                ],
              ),
              Row(
                children: [
                  Text(
                    '총 금액: ${_numberFormat.format(totalAmount)}원',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadRequests,
                  ),
                  if (_selectedIds.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteSelected,
                    ),
                ],
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
                  
                  // 강의별 선택 상태 확인
                  final courseRequests = experiments.values.expand((r) => r).toList();
                  final courseAllSelected = courseRequests.isNotEmpty &&
                      courseRequests.every((r) => _selectedIds.contains(r.id));
                  
                  return Column(
                    children: [
                      // 강의 헤더
                      Container(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: courseAllSelected,
                                onChanged: (_) => _toggleCourseSelection(courseTitle, experiments),
                              ),
                              Icon(courseExpanded ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                          title: Text(
                            '📚 $courseTitle (${experiments.length}개 실험)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                        
                        // 실험별 선택 상태
                        final experimentAllSelected = requests.isNotEmpty &&
                            requests.every((r) => _selectedIds.contains(r.id));
                        
                        return Column(
                          children: [
                            // 실험 헤더
                            Container(
                              color: Colors.green.shade50,
                              padding: const EdgeInsets.only(left: 20),
                              child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: experimentAllSelected,
                                      onChanged: (_) => _toggleExperimentSelection(requests),
                                    ),
                                    Icon(
                                      experimentExpanded ? Icons.expand_less : Icons.expand_more,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                title: Text(
                                  '🧪 $experimentTitle (${requests.length}개)',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
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
                                padding: const EdgeInsets.only(left: 40),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: _selectedIds.contains(request.id),
                                    onChanged: (_) => _toggleSelect(request.id),
                                  ),
                                  title: Text(request.name),
                                  subtitle: Text(
                                    '${request.quantity}${request.unit ?? 'EA'} | '
                                    '${_numberFormat.format(request.price)}원 | '
                                    '합계: ${_numberFormat.format(request.quantity * request.price)}원',
                                  ),
                                  trailing: DropdownButton<String>(
                                    value: request.deliveryStatus ?? '확인요청',
                                    underline: const SizedBox(),
                                    items: _statusOptions.map((status) {
                                      return DropdownMenuItem<String>(
                                        value: status,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, 
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
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