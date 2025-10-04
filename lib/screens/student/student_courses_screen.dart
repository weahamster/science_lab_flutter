import 'package:flutter/material.dart';
import '../../services/student/course_service.dart';
import '../../services/student/material_request_service.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _myRequests = [];
  bool _isLoading = true;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCourses();
    await _loadMyRequests();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await StudentCourseService.getEnrolledCourses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      _showError('강의 목록을 불러올 수 없습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMyRequests() async {
    try {
      final requests = await StudentMaterialRequestService.getMyRequests();
      double total = 0;
      for (var request in requests) {
        if (request['status'] == 'pending' || request['status'] == 'approved') {
          total += (request['quantity'] ?? 0) * (request['price'] ?? 0);
        }
      }
      setState(() {
        _myRequests = requests;
        _totalPrice = total;
      });
    } catch (e) {
      // 요청 목록은 없어도 화면 표시
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showRequestMaterialDialog(Map<String, dynamic> course) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    String selectedUnit = 'EA';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재료 신청'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '재료명',
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
                      items: ['EA', 'ml', 'g', 'L', 'kg']
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
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '예상 단가 (원)',
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
              if (nameController.text.trim().isEmpty || 
                  quantityController.text.trim().isEmpty) {
                _showError('모든 필수 항목을 입력해주세요');
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await StudentMaterialRequestService.requestMaterial({
                  'name': nameController.text.trim(),
                  'quantity': int.parse(quantityController.text),
                  'unit': selectedUnit,
                  'price': int.tryParse(priceController.text) ?? 0,
                });
                
                _showError('재료 신청이 완료되었습니다');
                _loadMyRequests();
              } catch (e) {
                _showError('신청 실패: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('신청', style: TextStyle(color: Colors.white)),
          ),
        ],
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
        // 상단 정보 바
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${_courses.length}개의 강의가 있습니다',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: '새로고침',
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
                columnSpacing: isPhoneScreen ? 20 : 40,
                columns: [
                  DataColumn(label: Text('강의명', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('담당 교사', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('반', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('상태', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('실험 관리', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                ],
                rows: _courses.map((course) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.arrow_drop_up, color: Colors.grey, size: 20),
                            Text(
                              course['name'] ?? '강의명 없음',
                              style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            course['teacher_name'] ?? '교사 미정',
                            style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                          ),
                        ],
                      )),
                      DataCell(Text(
                        course['class'] ?? '-',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '참여중',
                            style: TextStyle(
                              fontSize: isPhoneScreen ? 11 : 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () => _showRequestMaterialDialog(course),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            '재료 신청',
                            style: TextStyle(
                              fontSize: isPhoneScreen ? 11 : 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        // 하단 신청 정보
        if (_myRequests.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '신청한 재료',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._myRequests.take(3).map((request) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${request['name']} ${request['quantity']}${request['unit']} × ${request['price'] ?? 0}원',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: request['status'] == 'approved' 
                              ? Colors.green[50] 
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          request['status'] == 'approved' ? '승인됨' : '확인요청',
                          style: TextStyle(
                            color: request['status'] == 'approved' 
                                ? Colors.green[700] 
                                : Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                if (_myRequests.length > 3)
                  Text(
                    '외 ${_myRequests.length - 3}개',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '총 ${_totalPrice.toStringAsFixed(0)}원',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}