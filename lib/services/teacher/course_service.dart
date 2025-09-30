import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  static final _supabase = Supabase.instance.client;
  
  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }
  
  static Future<void> addCourse(String name, String grade, String description) async {
    try {
      final user = _supabase.auth.currentUser;
      
      await _supabase.from('courses').insert({
        'title': name,
        'class': grade.isEmpty ? null : grade,
        'description': description.isEmpty ? null : description,
        'teacher_id': user?.id,
        'school_id': user?.userMetadata?['school_id'],
      });
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }
  
  static Future<void> updateCourse(String id, String name, String grade, String description) async {
    try {
      await _supabase.from('courses').update({
        'title': name,
        'class': grade.isEmpty ? null : grade,
        'description': description.isEmpty ? null : description,
      }).eq('id', id);
    } catch (e) {
      print('Error updating course: $e');
      throw e;
    }
  }
  
  static Future<void> deleteCourse(String id) async {
    try {
      // 연결된 실험 확인
      final experiments = await _supabase
          .from('experiments')
          .select('id')
          .eq('course_id', id);
      
      if (experiments != null && experiments.isNotEmpty) {
        throw Exception('이 강의에 등록된 실험이 있어 삭제할 수 없습니다. 먼저 실험을 삭제해주세요.');
      }
      
      // 실험이 없으면 강의 삭제
      await _supabase.from('courses').delete().eq('id', id);
      
    } catch (e) {
      print('Error deleting course: $e');
      
      // 외래키 제약 오류 처리
      if (e.toString().contains('violates foreign key')) {
        throw Exception('이 강의를 사용하는 데이터가 있어 삭제할 수 없습니다.');
      }
      throw e;
    }
  }
}