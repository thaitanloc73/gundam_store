import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String phone;
  final String address;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final List<Map<String, dynamic>> items; // Chứa {productId, name, price, quantity}

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['UserId'] ?? '',
      customerName: data['CustomerName'] ?? '',
      phone: data['Phone'] ?? '',
      address: data['Address'] ?? '',
      totalAmount: (data['TotalAmount'] ?? 0).toDouble(),
      status: data['Status'] ?? 'Pending',
      orderDate: (data['OrderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: List<Map<String, dynamic>>.from(data['Items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'CustomerName': customerName,
      'Phone': phone,
      'Address': address,
      'TotalAmount': totalAmount,
      'Status': status,
      'OrderDate': FieldValue.serverTimestamp(),
      'Items': items,
    };
  }
}
