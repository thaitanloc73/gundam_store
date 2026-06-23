class OrderItem {
  final int? id;
  final int orderId;
  final int gundamId;
  final int quantity;
  final double price;
  final String? gundamName;

  OrderItem({
    this.id,
    required this.orderId,
    required this.gundamId,
    required this.quantity,
    required this.price,
    this.gundamName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'gundam_id': gundamId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      gundamId: map['gundam_id'] as int,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      gundamName: map['gundamName'] as String?,
    );
  }
}
