import 'package:supabase_flutter/supabase_flutter.dart';

class StudentFeedbackService {
  static final _supabase = Supabase.instance.client;
  
  // 피드백 목록 조회
  static Future<List<Map<String, dynamic>>> getFeedbacks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final response = await _supabase
          .from('feedbacks')
          .select('*, courses(*)')
          .eq('student_id', userId ?? '')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load feedbacks: $e');
    }
  }
  
  // 피드백 읽음 처리
  static Future<void> markAsRead(String feedbackId) async {
    try {
      await _supabase
          .from('feedbacks')
          .update({'is_read': true})
          .eq('id', feedbackId);
    } catch (e) {
      throw Exception('Failed to mark feedback as read: $e');
    }
  }
  
  // 피드백에 대한 응답 작성
  static Future<void> respondToFeedback(String feedbackId, String response) async {
    try {
      await _supabase
          .from('feedbacks')
          .update({
            'student_response': response,
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', feedbackId);
    } catch (e) {
      throw Exception('Failed to respond to feedback: $e');
    }
  }
}