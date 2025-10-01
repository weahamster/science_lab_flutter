import 'package:flutter/material.dart';
import '../../services/teacher/class_service.dart';
import '../../models/course.dart';  // 세미콜론 추가!

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  Set<String> _selectedIds = {};
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await ClassService.getCourses();
      setState(() {
        _courses = courses;
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('강의 목록 로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredCourses = _courses;
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredCourses = _courses.where((course) {
          final title = course.title.toLowerCase();
          final className = (course.className ?? '').toLowerCase();
          final description = (course.description ?? '').toLowerCase();
          
          return title.contains(query) ||
                 className.contains(query) ||
                 description.contains(query);
        }).toList();
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

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedIds = _filteredCourses
            .map((c) => c.id)
            .toSet();
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
        content: Text('선택한 ${_selectedIds.length}개 강의를 삭제하시겠습니까?\n관련된 모든 데이터가 삭제됩니다.'),
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
      try {
        for (String id in _selectedIds) {
          await ClassService.deleteCourse(id);
        }
        setState(() {
          _selectedIds.clear();
        });
        await _loadCourses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택한 강의가 삭제되었습니다')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('새 강의 만들기'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '강의명 *',
                  hintText: '예: 고등학교 화학 실험',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: '반 (선택)',
                  hintText: '예: 2학년 3반',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  hintText: '강의에 대한 간단한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                  const SnackBar(content: Text('강의명을 입력해주세요')),
                );
                return;
              }

              Navigator.pop(context);
              await _addCourse(
                nameController.text.trim(),
                gradeController.text.trim(),
                descriptionController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('강의 생성', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addCourse(String name, String grade, String description) async {
    setState(() => _isLoading = true);
    try {
      await ClassService.addCourse(name, grade, description);
      await _loadCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('강의가 생성되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('강의 생성 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditCourseDialog(Course course) {
    final nameController = TextEditingController(text: course.title);
    final gradeController = TextEditingController(text: course.className ?? '');
    final descriptionController = TextEditingController(text: course.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('강의 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '강의명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: '반',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              await _updateCourse(
                course.id,
                nameController.text.trim(),
                gradeController.text.trim(),
                descriptionController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('수정', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCourse(String id, String name, String grade, String description) async {
    try {
      await ClassService.updateCourse(id, name, grade, description);
      await _loadCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('강의가 수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteCourse(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('강의 삭제'),
        content: const Text('정말 이 강의를 삭제하시겠습니까?\n강의와 관련된 모든 데이터가 삭제됩니다.'),
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
      try {
        await ClassService.deleteCourse(id);
        await _loadCourses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('강의가 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
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

    return Column(
      children: [
        // 상단 검색 바
        Container(
          padding: EdgeInsets.all(isPhoneScreen ? 8 : 16),
          color: Colors.white,
          child: isPhoneScreen
              ? Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '검색...',
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showAddCourseDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('새 강의'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '강의명, 반, 설명으로 검색...',
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
                    ElevatedButton.icon(
                      onPressed: _showAddCourseDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('새 강의 만들기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: isPhoneScreen ? 0.8 : 1.0,
                    child: Checkbox(
                      value: _selectedIds.length == _filteredCourses.length && 
                             _filteredCourses.isNotEmpty,
                      onChanged: _toggleSelectAll,
                    ),
                  ),
                  Text(
                    isPhoneScreen 
                      ? '${_selectedIds.length}/${_filteredCourses.length}'
                      : '전체 선택 (${_selectedIds.length}/${_filteredCourses.length})',
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPhoneScreen)
                    Text(
                      '전체: ${_filteredCourses.length}개',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _loadCourses,
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
          child: _filteredCourses.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty 
                      ? '등록된 강의가 없습니다\n새 강의를 만들어보세요'
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
                        DataColumn(label: Text('강의명', 
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('반', 
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('설명', 
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                        DataColumn(label: Text('작업', 
                          style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                      ],
                      rows: _filteredCourses.map((course) {
                        return DataRow(
                          selected: _selectedIds.contains(course.id),
                          cells: [
                            DataCell(
                              Transform.scale(
                                scale: isPhoneScreen ? 0.8 : 1.0,
                                child: Checkbox(
                                  value: _selectedIds.contains(course.id),
                                  onChanged: (_) => _toggleSelect(course.id),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                course.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isPhoneScreen ? 12 : 14,
                                ),
                              ),
                            ),
                            DataCell(Text(
                              course.className ?? '',
                              style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                            )),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: isPhoneScreen ? 100 : 200,
                                ),
                                child: Text(
                                  course.description ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
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
                                    onPressed: () => _showEditCourseDialog(course),
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, 
                                      color: Colors.red,
                                      size: isPhoneScreen ? 18 : 20,
                                    ),
                                    onPressed: () => _deleteCourse(course.id),
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