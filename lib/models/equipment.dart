class Equipment {
  final String id;
  final String schoolId;
  final String name;
  final String? category;
  final String? description;
  final int quantity;
  final String? location;
  final String? status;
  final String? serialNumber;
  final String? model;
  final String? notes;
  final String? qrCode;
  final String? imageUrl;
  final DateTime createdAt;

  Equipment({
    required this.id,
    required this.schoolId,
    required this.name,
    this.category,
    this.description,
    required this.quantity,
    this.location,
    this.status,
    this.serialNumber,
    this.model,
    this.notes,
    this.qrCode,
    this.imageUrl,
    required this.createdAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      schoolId: json['school_id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      location: json['location'],
      status: json['status'],
      serialNumber: json['serial_number'],
      model: json['model'],
      notes: json['notes'],
      qrCode: json['qr_code'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'school_id': schoolId,
    'name': name,
    'category': category,
    'description': description,
    'quantity': quantity,
    'location': location,
    'status': status,
    'serial_number': serialNumber,
    'model': model,
    'notes': notes,
    'qr_code': qrCode,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
  };
}