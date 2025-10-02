import 'package:supabase_flutter/supabase_flutter.dart';

class StudentSearchService {
  static final _supabase = Supabase.instance.client;
  
  // 물품 검색 (읽기 전용)
  static Future<List<Map<String, dynamic>>> searchInventory({
    String? searchQuery,
    String? location,
  }) async {
    try {
      var query = _supabase
          .from('school_inventory')
          .select('*');
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,location.ilike.%$searchQuery%');
      }
      
      if (location != null && location != '전체') {
        query = query.eq('location', location);
      }
      
      final response = await query.order('name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search inventory: $e');
    }
  }
  
  // 기자재 검색 (읽기 전용)
  static Future<List<Map<String, dynamic>>> searchEquipment({
    String? searchQuery,
    String? category,
    String? location,
  }) async {
    try {
      var query = _supabase
          .from('equipment')
          .select('*');
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,model.ilike.%$searchQuery%');
      }
      
      if (category != null && category != '전체') {
        query = query.eq('category', category);
      }
      
      if (location != null && location != '전체') {
        query = query.eq('location', location);
      }
      
      final response = await query.order('name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search equipment: $e');
    }
  }
  
  // 기자재 상태별 통계
  static Future<Map<String, int>> getEquipmentStatistics() async {
    try {
      final response = await _supabase
          .from('equipment')
          .select('status');
      
      final equipment = List<Map<String, dynamic>>.from(response);
      
      return {
        'total': equipment.length,
        'normal': equipment.where((e) => e['status'] == 'normal').length,
        'repair': equipment.where((e) => e['status'] == 'repair').length,
        'broken': equipment.where((e) => e['status'] == 'broken').length,
        'lost': equipment.where((e) => e['status'] == 'lost').length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}