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
}