import 'package:supabase_flutter/supabase_flutter.dart';

class ItemService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'school_inventory';
  
  // 학교 물품 목록 가져오기
  static Future<List<Map<String, dynamic>>> getSchoolItems() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  // 물품 추가
  static Future<void> addItem(Map<String, dynamic> item) async {
    try {
      await _supabase.from(_table).insert({
        'name': item['name'],
        'quantity': item['quantity'],
        'unit': item['unit'],
        'location': item['location'],
        'remarks': item['note'],  // UI의 note를 DB의 remarks로
        'max_loan': 1,
        'school_id': 'placeholder_school_id', // 실제 school_id로 변경 필요
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding item: $e');
      throw e;
    }
  }

  // 물품 수정
  static Future<void> updateItem(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'name': updates['name'],
            'quantity': updates['quantity'],
            'unit': updates['unit'],
            'location': updates['location'],
            'remarks': updates['note'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('Error updating item: $e');
      throw e;
    }
  }

  // 물품 삭제
  static Future<void> deleteItem(String id) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting item: $e');
      throw e;
    }
  }
}