import 'package:supabase_flutter/supabase_flutter.dart';

class EquipmentService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'equipment';
  
  // 사용자의 실제 school_id 가져오기
  static Future<String?> _getUserSchoolId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return null;
      }
      
      // CSV 데이터를 보면 school_id는 UUID 형식
      // users 테이블이나 schools 테이블에서 가져오기
      final response = await _supabase
          .from('users')
          .select('school_id')
          .eq('id', user.id)
          .single();
      
      return response['school_id'];
    } catch (e) {
      print('Error getting school_id: $e');
      
      // 대안: schools 테이블에서 첫 번째 학교 ID 사용 (임시)
      try {
        final schools = await _supabase
            .from('schools')
            .select('id')
            .limit(1);
        
        if (schools.isNotEmpty) {
          return schools[0]['id'];
        }
      } catch (e2) {
        print('Error getting default school: $e2');
      }
      
      return null;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getEquipment() async {
    try {
      final schoolId = await _getUserSchoolId();
      
      final response = await _supabase
          .from(_table)
          .select()
          .eq('school_id', schoolId ?? '')  // school_id로 필터링
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('Error fetching equipment: $e');
      return [];
    }
  }

  static Future<void> addEquipment(Map<String, dynamic> equipment) async {
    try {
      final schoolId = await _getUserSchoolId();
      
      if (schoolId == null) {
        throw Exception('사용자의 학교 정보를 찾을 수 없습니다');
      }
      
      final dataToInsert = {
        'name': equipment['name'],
        'category': equipment['category'],
        'quantity': equipment['quantity'] ?? 1,
        'location': equipment['location'],
        'status': equipment['status'] ?? '정상',
        'model': equipment['model'],
        'serial_number': equipment['serial_number'],
        'notes': equipment['notes'],
        'image_url': equipment['image_url'],
        'description': equipment['description'],
        'school_id': schoolId,  // 실제 school_id 사용
        'created_at': DateTime.now().toIso8601String(),
      };
      
      print('Inserting equipment: $dataToInsert');  // 디버깅
      
      await _supabase
          .from(_table)
          .insert(dataToInsert);
      
      print('Equipment added successfully');
      
    } catch (e) {
      print('Error adding equipment: $e');
      print('Equipment data was: $equipment');
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
  
  // 수정 기능 추가
  static Future<void> updateEquipment(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from(_table)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      print('Error updating equipment: $e');
      throw e;
    }
  }
}