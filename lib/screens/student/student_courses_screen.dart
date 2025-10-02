import 'package:flutter/material.dart';
import '../../services/student/course_service.dart';
import '../../services/student/material_request_service.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  // final _supabase = Supabase.instance.client; // 삭제!
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // 수정된 부분
  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      // Service 사용
      final courses = await StudentCourseService.getEnrolledCourses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRequestMaterialDialog(Map<String, dynamic> course) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 항목을 입력해주세요')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                // Service 사용!
                await StudentMaterialRequestService.requestMaterial({
                  'course_id': course['course_id'] ?? course['courses']?['id'],
                  'name': nameController.text.trim(),
                  'quantity': int.parse(quantityController.text),
                  'unit': selectedUnit,
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('재료 신청이 완료되었습니다')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('신청 실패: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('신청', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 나머지 코드는 동일...
  @override
  Widget build(BuildContext context) {
    // 기존 build 코드 그대로
  }
}