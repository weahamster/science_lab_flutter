import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/course.dart';

class ClassService {
  static final _supabase = Supabase.instance.client;
  
  // Course 모델을 반환하도록 수정
  static Future<List<Course>> getCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Course.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }
  
  // 개별 매개변수를 받도록 수정
  static Future<void> addCourse(String name, String grade, String description) async {
    try {
      final user = _supabase.auth.currentUser;
      
      await _supabase.from('courses').insert({
        'title': name,
        'class': grade.isEmpty ? null : grade,
        'description': description.isEmpty ? null : description,
        'teacher_id': user?.id,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }
  
  // 개별 매개변수를 받도록 수정
  static Future<void> updateCourse(String id, String name, String grade, String description) async {
    try {
      await _supabase
          .from('courses')
          .update({
            'title': name,
            'class': grade.isEmpty ? null : grade,
            'description': description.isEmpty ? null : description,
          })
          .eq('id', id);
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
        throw Exception('이 강의에 등록된 실험이 있어 삭제할 수 없습니다.');
      }
      
      await _supabase
          .from('courses')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting course: $e');
      throw e;
    }
  }
}