import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/purchase_item.dart';

class PurchaseService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'teacher_purchase_materials'; // 테이블명 상수화
  
  static Future<List<PurchaseItem>> getPurchaseItems() async {
    try {
      final response = await _supabase
          .from(_table)
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
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from(_table)
          .insert(data)
          .select()
          .single();
      
      return PurchaseItem.fromJson(response);
    } catch (e) {
      print('Error adding purchase item: $e');
      return null;
    }
  }
  
  static Future<void> updatePurchaseItem(PurchaseItem item) async {
    try {
      await _supabase
          .from(_table)  // ✅ 올바른 테이블명
          .update({
            'name': item.name,
            'quantity': item.quantity,
            'unit': item.unit,
            'price': item.price,
            'link': item.link.isEmpty ? null : item.link,
          })
          .eq('id', item.id);
    } catch (e) {
      print('Error updating purchase item: $e');
      throw e;
    }
  }
  
  static Future<bool> deletePurchaseItem(String id) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting purchase item: $e');
      return false;
    }
  }
}