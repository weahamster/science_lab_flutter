import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/purchase_item.dart';

class PurchaseService {
  static final _supabase = Supabase.instance.client;
  static const _materialsTable = 'teacher_purchase_materials';
  static const _requestsTable = 'teacher_purchase_requests';
  
  // 현재 활성 요청 ID 가져오기 또는 생성
  static Future<String> _getOrCreateRequestId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // 현재 사용자의 'draft' 상태 요청 찾기
      final existingRequests = await _supabase
          .from(_requestsTable)
          .select()
          .eq('teacher_id', user.id)
          .eq('status', 'draft')
          .order('created_at', ascending: false)
          .limit(1);
      
      if (existingRequests.isNotEmpty) {
        return existingRequests[0]['id'];
      }
      
      // 없으면 새 요청 생성
      final newRequest = await _supabase
          .from(_requestsTable)
          .insert({
            'teacher_id': user.id,
            'school_id': user.userMetadata?['school_id'],
            'status': 'draft',
            'purpose': '물품 구입',
            'total_amount': 0,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      return newRequest['id'];
    } catch (e) {
      print('Error getting/creating request: $e');
      throw e;
    }
  }
  
  // 물품 목록 가져오기
  static Future<List<PurchaseItem>> getPurchaseItems() async {
    try {
      final requestId = await _getOrCreateRequestId();
      
      final response = await _supabase
          .from(_materialsTable)
          .select()
          .eq('purchase_request_id', requestId)
          .order('created_at', ascending: false);
      
      if (response == null) return [];
      
      return (response as List)
          .map((item) => PurchaseItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting purchase items: $e');
      return [];
    }
  }
  
  // 물품 추가
  static Future<PurchaseItem?> addPurchaseItem(PurchaseItem item) async {
    try {
      final requestId = await _getOrCreateRequestId();
      
      final data = {
        'purchase_request_id': requestId,  // 중요: request_id 연결
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'price': item.price,
        'link': item.link.isEmpty ? null : item.link,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from(_materialsTable)
          .insert(data)
          .select()
          .single();
      
      // 총액 업데이트
      await _updateTotalAmount(requestId);
      
      return PurchaseItem.fromJson(response);
    } catch (e) {
      print('Error adding purchase item: $e');
      return null;
    }
  }
  
  // 물품 수정
  static Future<void> updatePurchaseItem(PurchaseItem item) async {
    try {
      await _supabase
          .from(_materialsTable)
          .update({
            'name': item.name,
            'quantity': item.quantity,
            'unit': item.unit,
            'price': item.price,
            'link': item.link.isEmpty ? null : item.link,
          })
          .eq('id', item.id);
      
      // 총액 재계산
      final requestIdResult = await _supabase
          .from(_materialsTable)
          .select('purchase_request_id')
          .eq('id', item.id)
          .single();
      
      if (requestIdResult != null) {
        await _updateTotalAmount(requestIdResult['purchase_request_id']);
      }
    } catch (e) {
      print('Error updating purchase item: $e');
      throw e;
    }
  }
  
  // 물품 삭제
  static Future<bool> deletePurchaseItem(String id) async {
    try {
      // request_id 먼저 가져오기
      final itemResult = await _supabase
          .from(_materialsTable)
          .select('purchase_request_id')
          .eq('id', id)
          .single();
      
      await _supabase
          .from(_materialsTable)
          .delete()
          .eq('id', id);
      
      // 총액 재계산
      if (itemResult != null) {
        await _updateTotalAmount(itemResult['purchase_request_id']);
      }
      
      return true;
    } catch (e) {
      print('Error deleting purchase item: $e');
      return false;
    }
  }
  
  // 총액 업데이트 (내부 헬퍼 메서드)
  static Future<void> _updateTotalAmount(String requestId) async {
    try {
      // 해당 요청의 모든 물품 총액 계산
      final items = await _supabase
          .from(_materialsTable)
          .select('quantity, price')
          .eq('purchase_request_id', requestId);
      
      int total = 0;
      for (var item in items) {
        total += (item['quantity'] as int) * (item['price'] as int);
      }
      
      // 요청 테이블 업데이트
      await _supabase
          .from(_requestsTable)
          .update({
            'total_amount': total,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);
    } catch (e) {
      print('Error updating total amount: $e');
    }
  }
  
  // 요청 상태 변경 (제출, 승인 등)
  static Future<bool> submitRequest() async {
    try {
      final requestId = await _getOrCreateRequestId();
      
      await _supabase
          .from(_requestsTable)
          .update({
            'status': 'submitted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);
      
      return true;
    } catch (e) {
      print('Error submitting request: $e');
      return false;
    }
  }
}