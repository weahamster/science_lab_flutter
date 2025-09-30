import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/material_request.dart';

class MaterialService {
  static final _supabase = Supabase.instance.client;
  
  // 모든 신청 목록 가져오기
  static Future<List<MaterialRequest>> getAllRequests() async {
    try {
      final response = await _supabase
          .from('material_requests')
          .select('*, experiments(title, courses(title))')
          .order('created_at', ascending: false);
      
      if (response == null) return [];
      
      return (response as List)
          .map((json) => MaterialRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting requests: $e');
      return [];
    }
  }
  
  // 관계 포함한 원시 데이터 가져오기
  static Future<List<Map<String, dynamic>>> getAllRequestsWithRelations() async {
    try {
      final response = await _supabase
          .from('material_requests')
          .select('*, experiments(title, courses(title))')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('Error getting requests with relations: $e');
      return [];
    }
  }
  
  // 진행 상태 업데이트
  static Future<bool> updateStatus(String requestId, String status) async {
    try {
      await _supabase
          .from('material_requests')
          .update({'delivery_status': status})
          .eq('id', requestId);
      return true;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }
  
  // 신청 삭제
  static Future<bool> deleteRequest(String requestId) async {
    try {
      await _supabase
          .from('material_requests')
          .delete()
          .eq('id', requestId);
      return true;
    } catch (e) {
      print('Error deleting request: $e');
      return false;
    }
  }
  
  // 여러 개 삭제
  static Future<bool> deleteMultipleRequests(List<String> requestIds) async {
    try {
      await _supabase
          .from('material_requests')
          .delete()
          .inFilter('id', requestIds);
      return true;
    } catch (e) {
      print('Error deleting multiple requests: $e');
      return false;
    }
  }
}  // 클래스 중괄호 닫기