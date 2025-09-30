class MaterialRequest {
  final String id;
  final String experimentId;
  final int quantity;
  final int price;
  final DateTime createdAt;
  final String? deliveryStatus;
  final String? link;
  final String name;
  final String? status;
  final String? unit;
  
  MaterialRequest({
    required this.id,
    required this.experimentId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    this.deliveryStatus,
    this.link,
    required this.name,
    this.status,
    this.unit,
  });
  
  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      id: json['id'],
      experimentId: json['experiment_id'],
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      deliveryStatus: json['delivery_status'],
      link: json['link'],
      name: json['name'] ?? '',
      status: json['status'],
      unit: json['unit'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'experiment_id': experimentId,
    'quantity': quantity,
    'price': price,
    'created_at': createdAt.toIso8601String(),
    'delivery_status': deliveryStatus,
    'link': link,
    'name': name,
    'status': status,
    'unit': unit,
  };
  
  // copyWith 메서드 추가
  MaterialRequest copyWith({
    String? id,
    String? experimentId,
    int? quantity,
    int? price,
    DateTime? createdAt,
    String? deliveryStatus,
    String? link,
    String? name,
    String? status,
    String? unit,
  }) {
    return MaterialRequest(
      id: id ?? this.id,
      experimentId: experimentId ?? this.experimentId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      link: link ?? this.link,
      name: name ?? this.name,
      status: status ?? this.status,
      unit: unit ?? this.unit,
    );
  }
}