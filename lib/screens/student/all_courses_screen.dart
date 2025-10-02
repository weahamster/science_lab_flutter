import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student/course_service.dart';

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllCourses();
  }

  Future<void> _loadAllCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await StudentCourseService.getAllCourses();

      setState(() {
        _allCourses = List<Map<String, dynamic>>.from(response);
        _applyFilter();
      });
    } catch (e) {
      print('Error loading courses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        return _searchQuery.isEmpty ||
            course['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course['teacher_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _enrollCourse(String courseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      // 이미 참여 중인지 확인
      final existing = await _supabase
          .from('course_students')
          .select()
          .eq('course_id', courseId)
          .eq('student_id', userId ?? '')
          .single();
      
      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 참여 중인 강의입니다')),
        );
        return;
      }
      
      // 강의 참여
      await _supabase.from('course_students').insert({
        'course_id': courseId,
        'student_id': userId,
        'enrolled_at': DateTime.now().toIso8601String(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('강의 참여가 완료되었습니다')),
      );
      
      _loadAllCourses();
    } catch (e) {
      print('Error enrolling course: $e');
    }
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
        // 검색 바
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
              hintText: '강의명 또는 선생님 이름으로 검색...',
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
        
        // 강의 수 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Text(
                '총 ${_filteredCourses.length}개의 강의가 있습니다',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                  DataColumn(label: Text('생성일', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('상태', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                  DataColumn(label: Text('입장', 
                    style: TextStyle(fontSize: isPhoneScreen ? 12 : 14))),
                ],
                rows: _filteredCourses.map((course) {
                  final createdDate = DateTime.parse(course['created_at'] ?? DateTime.now().toIso8601String());
                  final formattedDate = '${createdDate.year}. ${createdDate.month}. ${createdDate.day}.';
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        course['name'] ?? 'ggg',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            course['teacher_name'] ?? '선생님1 선생님',
                            style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                          ),
                        ],
                      )),
                      DataCell(Text(
                        course['class'] ?? '-',
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(Text(
                        formattedDate,
                        style: TextStyle(fontSize: isPhoneScreen ? 12 : 14),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '참여중',
                            style: TextStyle(
                              fontSize: isPhoneScreen ? 11 : 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () => _enrollCourse(course['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            '강의 입장',
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
      ],
    );
  }
}