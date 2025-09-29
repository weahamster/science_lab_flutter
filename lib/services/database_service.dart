import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase_item.dart';

class DatabaseService {
  static final supabase = Supabase.instance.client;
  
  // 물품 목록 가져오기
  static Future<List<PurchaseItem>> getPurchaseItems() async {
    try {
      final response = await supabase
          .from('teacher_purchase_materials')
          .select('*')
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
      final data = {
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'price': item.price,
        'link': item.link.isEmpty ? null : item.link,
      };
      
      print('Inserting data: $data');
      
      final response = await supabase
          .from('teacher_purchase_materials')
          .insert(data)
          .select()
          .single();
      
      print('Insert response: $response');
      
      return PurchaseItem.fromJson(response);
    } catch (e) {
      print('Error adding purchase item: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }
  
  // 물품 삭제
  static Future<bool> deletePurchaseItem(String id) async {
    try {
      await supabase
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