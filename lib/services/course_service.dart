@'
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  static final _supabase = Supabase.instance.client;
  
  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }
  
  static Future<void> addCourse(String name, String grade, String description) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase.from('courses').insert({
        'name': name,
        'grade': grade.isEmpty ? null : grade,
        'description': description.isEmpty ? null : description,
        'teacher_id': user?.id,
      });
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }
  
  static Future<void> updateCourse(String id, String name, String grade, String description) async {
    try {
      await _supabase.from('courses').update({
        'name': name,
        'grade': grade.isEmpty ? null : grade,
        'description': description.isEmpty ? null : description,
      }).eq('id', id);
    } catch (e) {
      print('Error updating course: $e');
      throw e;
    }
  }
  
  static Future<void> deleteCourse(String id) async {
    try {
      await _supabase.from('courses').delete().eq('id', id);
    } catch (e) {
      print('Error deleting course: $e');
      throw e;
    }
  }
}
'@ | Out-File -FilePath "lib\services\course_service.dart" -Encoding UTF8