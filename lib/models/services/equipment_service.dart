import 'package:supabase_flutter/supabase_flutter.dart';

class EquipmentService {
  static final _supabase = Supabase.instance.client;
  
  static Future<List<Map<String, dynamic>>> getEquipment() async {
    try {
      final response = await _supabase
          .from('equipment')
          .select()
          .order('name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting equipment: $e');
      return [];
    }
  }
  
  // 추가 메서드들...
}