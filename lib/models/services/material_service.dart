import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialService {
  static final _supabase = Supabase.instance.client;
  
  static Future<List<Map<String, dynamic>>> getMaterialRequests() async {
    try {
      final response = await _supabase
          .from('material_requests')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting material requests: $e');
      return [];
    }
  }
  
  // 추가 메서드들...
}