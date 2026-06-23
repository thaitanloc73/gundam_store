class Order {
  final int? id;
  final int userId;
  final double totalAmount;
  final String address;
  final String phone;
  final String status;
  final String createdAt;

  Order({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.address,
    required this.phone,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'address': address,
      'phone': phone,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      totalAmount: (map['total_amount'] as num).toDouble(),
      address: map['address'] as String,
      phone: map['phone'] as String,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
