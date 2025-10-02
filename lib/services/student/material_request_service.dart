import 'package:supabase_flutter/supabase_flutter.dart';

class StudentMaterialRequestService {
  static final _supabase = Supabase.instance.client;
  
  // 재료 신청
  static Future<void> requestMaterial(Map<String, dynamic> requestData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      await _supabase.from('material_requests').insert({
        ...requestData,
        'student_id': userId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to request material: $e');
    }
  }
  
  // 내 신청 목록 조회
  static Future<List<Map<String, dynamic>>> getMyRequests() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final response = await _supabase
          .from('material_requests')
          .select('*, courses(*)')
          .eq('student_id', userId ?? '')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load requests: $e');
    }
  }
  
  // 신청 수정
  static Future<void> updateRequest(String requestId, Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      await _supabase
          .from('material_requests')
          .update(data)
          .eq('id', requestId)
          .eq('student_id', userId ?? '')
          .eq('status', 'pending'); // pending 상태만 수정 가능
    } catch (e) {
      throw Exception('Failed to update request: $e');
    }
  }
  
  // 신청 취소
  static Future<void> cancelRequest(String requestId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      await _supabase
          .from('material_requests')
          .update({'status': 'cancelled'})
          .eq('id', requestId)
          .eq('student_id', userId ?? '')
          .eq('status', 'pending'); // pending 상태만 취소 가능
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }
}