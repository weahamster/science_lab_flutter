// lib/services/teacher/class_service.dart (이름 변경)
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/course.dart';

class ClassService {
  static final _supabase = Supabase.instance.client;

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

  static Future<void> addCourse(Map<String, dynamic> course) async {
    try {
      await _supabase.from('courses').insert(course);
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }

  static Future<void> updateCourse(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('courses')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      print('Error updating course: $e');
      throw e;
    }
  }

  static Future<void> deleteCourse(String id) async {
    try {
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