class SchoolInventory {
  final String id;
  final String schoolId;
  final String name;
  final int quantity;
  final String unit;
  final String? location;
  final String? remarks;
  final int? maxLoan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SchoolInventory({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.location,
    this.remarks,
    this.maxLoan,
    required this.createdAt,
    this.updatedAt,
  });

  factory SchoolInventory.fromJson(Map<String, dynamic> json) {
    return SchoolInventory(
      id: json['id'],
      schoolId: json['school_id'],
      name: json['name'],
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'EA',
      location: json['location'],
      remarks: json['remarks'],
      maxLoan: json['max_loan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'school_id': schoolId,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'location': location,
    'remarks': remarks,
    'max_loan': maxLoan,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  SchoolInventory copyWith({
    int? quantity,
    String? location,
    String? remarks,
    DateTime? updatedAt,
  }) {
    return SchoolInventory(
      id: id,
      schoolId: schoolId,
      name: name,
      quantity: quantity ?? this.quantity,
      unit: unit,
      location: location ?? this.location,
      remarks: remarks ?? this.remarks,
      maxLoan: maxLoan,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}