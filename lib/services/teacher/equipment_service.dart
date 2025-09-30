import 'package:supabase_flutter/supabase_flutter.dart';

class EquipmentService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'equipment';
  
  static Future<List<Map<String, dynamic>>> getEquipment() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('Error fetching equipment: $e');
      return [];
    }
  }

  static Future<void> addEquipment(Map<String, dynamic> equipment) async {
    try {
      await _supabase.from(_table).insert({
        ...equipment,
        'school_id': 'placeholder_school_id', // 실제 school_id로 변경
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding equipment: $e');
      throw e;
    }
  }

  static Future<void> deleteEquipment(String id) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting equipment: $e');
      throw e;
    }
  }
}