import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch sử đơn hàng')),
        body: const Center(child: Text('Vui lòng đăng nhập để xem lịch sử.')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5),
      appBar: AppBar(title: const Text('Lịch sử đơn hàng')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('UserId', isEqualTo: user.uid)
            .orderBy('OrderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Bạn chưa có đơn hàng nào.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final order = OrderModel.fromMap(data, doc.id);

              Color statusColor;
              switch (order.status) {
                case 'Pending':
                  statusColor = Colors.orange;
                  break;
                case 'Processing':
                case 'Shipping':
                  statusColor = Colors.blue;
                  break;
                case 'Completed':
                  statusColor = Colors.green;
                  break;
                case 'Cancelled':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ExpansionTile(
                  title: Text('Mã đơn: ${order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  subtitle: Text(
                      'Ngày đặt: ${order.orderDate.toString().substring(0, 16)}\nTổng tiền: ${_formatPrice(order.totalAmount)}',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  children: order.items.map((item) {
                    return ListTile(
                      dense: true,
                      title: Text(item['name'], style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      subtitle: Text('Số lượng: ${item['quantity']}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                      trailing: Text(_formatPrice((item['price'] as num).toDouble()),
                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}