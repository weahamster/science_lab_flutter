import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryService {
  static final _supabase = Supabase.instance.client;
  
  static Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final response = await _supabase
          .from('school_inventory')
          .select()
          .order('name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting inventory: $e');
      return [];
    }
  }
  
  // 추가 메서드들...
}