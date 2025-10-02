import 'package:supabase_flutter/supabase_flutter.dart';

class StudentCourseService {
  static final _supabase = Supabase.instance.client;
  
  // 학생이 참여 중인 강의 조회
  static Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('course_students')
          .select('*, courses(*)')
          .eq('student_id', userId ?? '');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load enrolled courses: $e');
    }
  }
  
  // 전체 강의 목록 조회
  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }
  
  // 강의 참여
  static Future<void> enrollCourse(String courseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      // 이미 참여 중인지 확인
      final existing = await _supabase
          .from('course_students')
          .select()
          .eq('course_id', courseId)
          .eq('student_id', userId ?? '')
          .maybeSingle();
      
      if (existing != null) {
        throw Exception('이미 참여 중인 강의입니다');
      }
      
      // 강의 참여
      await _supabase.from('course_students').insert({
        'course_id': courseId,
        'student_id': userId,
        'enrolled_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to enroll course: $e');
    }
  }
  
  // 강의 탈퇴
  static Future<void> leaveCourse(String courseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      await _supabase
          .from('course_students')
          .delete()
          .eq('course_id', courseId)
          .eq('student_id', userId ?? '');
    } catch (e) {
      throw Exception('Failed to leave course: $e');
    }
  }
}