/// Supabase 테이블 스키마 문서
/// 웹과 앱이 공유하는 데이터베이스 구조
/// 
/// 용도:
/// 1. 개발 중 테이블 구조 참조
/// 2. 웹 개발팀과 스키마 공유
/// 3. 타입 검증 및 문서화

class DatabaseSchema {
  // school_inventory 테이블 컬럼
  static const schoolInventoryColumns = [
    'remarks', 
    'created_at', 
    'updated_at', 
    'quantity', 
    'unit', 
    'location', 
    'max_loan', 
    'id', 
    'school_id', 
    'name'
  ];
  
  // material_requests 테이블 컬럼
  static const materialRequestsColumns = [
    'experiment_id',
    'price', 
    'unit',
    'quantity',
    'name',
    'id',
    'delivery_status',
    'created_at',
    'status',
    'link'
  ];
  
  // courses 테이블 컬럼
  static const coursesColumns = [
    'id',
    'description',
    'created_at',
    'is_active',
    'class',
    'school_id',
    'teacher_id',
    'title'
  ];
}