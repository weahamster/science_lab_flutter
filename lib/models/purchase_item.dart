class PurchaseItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final int price;
  final String link;
  
  PurchaseItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    this.link = '',
  });
  
  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '개',
      price: json['price'] ?? 0,
      link: json['link'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'link': link.isEmpty ? null : link,
    };
  }
  
  int get totalPrice => quantity * price;
}