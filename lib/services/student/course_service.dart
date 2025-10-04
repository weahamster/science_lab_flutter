import 'package:supabase_flutter/supabase_flutter.dart';

class StudentCourseService {
  static final _supabase = Supabase.instance.client;
  
  // 학생이 참여 중인 강의 조회 - 웹과 동일하게 수정
  static Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    try {
      // 웹처럼 courses 테이블 직접 조회
      final response = await _supabase
          .from('courses')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      // 화면 코드와 호환되도록 형태 변경
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load enrolled courses: $e');
    }
  }
  
  // 전체 강의 목록 조회 (변경 없음)
  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('*')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }
  
  // 강의 참여 - 실제로는 저장하지 않음 (course_students 테이블이 없으므로)
  static Future<void> enrollCourse(String courseId) async {
    try {
      // 임시: 아무 작업도 하지 않음
      print('Enrolling in course: $courseId');
      // 나중에 course_students 테이블 생성 후 구현
    } catch (e) {
      throw Exception('Failed to enroll course: $e');
    }
  }
  
  // 강의 탈퇴
  static Future<void> leaveCourse(String courseId) async {
    try {
      // 임시: 아무 작업도 하지 않음
      print('Leaving course: $courseId');
    } catch (e) {
      throw Exception('Failed to leave course: $e');
    }
  }
}