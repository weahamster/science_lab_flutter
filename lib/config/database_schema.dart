class DatabaseSchema {
  // school_inventory 테이블 (물품관리) ✅
  static const schoolInventoryColumns = [
    'id',
    'school_id',
    'name',
    'quantity',
    'unit',
    'location',
    'remarks',
    'max_loan',
    'created_at',
    'updated_at'
  ];
  
  // material_requests 테이블 (재료신청관리) ✅
  static const materialRequestsColumns = [
    'id',
    'experiment_id',
    'name',
    'quantity',
    'unit',
    'price',
    'link',
    'status',
    'delivery_status',
    'created_at'
  ];
  
  // courses 테이블 (강의관리)
  static const coursesColumns = [
    'id',
    'school_id',
    'teacher_id',
    'title',
    'class',
    'description',
    'is_active',
    'created_at'
  ];
  
  // ⭐ 추가 필요
  // teacher_purchase_materials 테이블 (구매 자재)
  static const teacherPurchaseMaterialsColumns = [
    'id',
    'purchase_request_id',  // ⭐ 중요: 요청 ID 연결
    'name',
    'quantity',
    'unit',
    'price',
    'link',
    'created_at'
  ];
  
  // teacher_purchase_requests 테이블 (구매 요청)
  static const teacherPurchaseRequestsColumns = [
    'id',
    'teacher_id',
    'school_id',
    'purpose',
    'status',
    'total_amount',
    'created_at',
    'updated_at'
  ];
}