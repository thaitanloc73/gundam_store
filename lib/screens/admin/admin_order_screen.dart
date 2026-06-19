import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order.dart';

class AdminOrderScreen extends StatelessWidget {
  const AdminOrderScreen({super.key});

  void _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'Status': newStatus,
    });
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .orderBy('OrderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final order = OrderModel.fromMap(data, doc.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ExpansionTile(
                  title: Text('Mã đơn: ${order.id.substring(0, 8).toUpperCase()}'),
                  subtitle: Text(
                      'Khách: ${order.customerName}\nTổng tiền: ${_formatPrice(order.totalAmount)}\nNgày đặt: ${order.orderDate.toString().substring(0, 16)}'),
                  trailing: DropdownButton<String>(
                    value: ['Pending', 'Processing', 'Shipping', 'Completed', 'Cancelled']
                            .contains(order.status)
                        ? order.status
                        : 'Pending',
                    items: <String>[
                      'Pending',
                      'Processing',
                      'Shipping',
                      'Completed',
                      'Cancelled'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(
                              color: value == 'Pending'
                                  ? Colors.orange
                                  : value == 'Completed'
                                      ? Colors.green
                                      : value == 'Cancelled'
                                          ? Colors.red
                                          : Colors.blue,
                            )),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != order.status) {
                        _updateOrderStatus(order.id, newValue);
                      }
                    },
                  ),
                  children: order.items.map((item) {
                    return ListTile(
                      dense: true,
                      title: Text(item['name']),
                      subtitle: Text('Số lượng: ${item['quantity']}'),
                      trailing: Text(_formatPrice((item['price'] as num).toDouble())),
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