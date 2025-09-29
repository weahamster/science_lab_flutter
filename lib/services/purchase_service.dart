# 파일 생성 및 내용 추가
@'
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase_item.dart';

class PurchaseService {
  static final _supabase = Supabase.instance.client;
  
  static Future<List<PurchaseItem>> getPurchaseItems() async {
    try {
      final response = await _supabase
          .from('teacher_purchase_materials')
          .select()
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
  
  static Future<PurchaseItem?> addPurchaseItem(PurchaseItem item) async {
    try {
      final data = {
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'price': item.price,
        'link': item.link.isEmpty ? null : item.link,
      };
      
      final response = await _supabase
          .from('teacher_purchase_materials')
          .insert(data)
          .select()
          .single();
      
      return PurchaseItem.fromJson(response);
    } catch (e) {
      print('Error adding purchase item: $e');
      return null;
    }
  }
  
  static Future<bool> deletePurchaseItem(String id) async {
    try {
      await _supabase
          .from('teacher_purchase_materials')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting purchase item: $e');
      return false;
    }
  }
}
'@ | Out-File -FilePath "lib\services\purchase_service.dart" -Encoding UTF8