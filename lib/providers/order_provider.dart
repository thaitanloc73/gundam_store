import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as model;
import '../models/order_item.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<model.Order> _orders = [];
  bool _isLoading = false;

  List<model.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('orders').orderBy('created_at', descending: true).get();
      _orders = snapshot.docs.map((doc) => model.Order.fromMap(doc.data(), id: doc.id)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrdersByUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      _orders = snapshot.docs.map((doc) => model.Order.fromMap(doc.data(), id: doc.id)).toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> placeOrder({
    required String userId,
    required String address,
    required String phone,
    required Map<String, CartItem> cartItems,
    required double totalAmount,
  }) async {
    try {
      // Create order document
      final orderRef = _firestore.collection('orders').doc();
      final orderItemsList = cartItems.values.map((item) => OrderItem(
        gundamId: item.gundamId,
        quantity: item.quantity,
        price: item.price,
        gundamName: item.name,
      )).toList();

      final order = model.Order(
        id: orderRef.id,
        userId: userId,
        totalAmount: totalAmount,
        address: address,
        phone: phone,
        status: 'Pending',
        createdAt: DateTime.now().toIso8601String(),
        items: orderItemsList,
      );

      // Perform batch write
      final batch = _firestore.batch();
      batch.set(orderRef, order.toMap());

      // Update stock
      for (final item in cartItems.values) {
        final gundamRef = _firestore.collection('gundams').doc(item.gundamId);
        final gundamDoc = await gundamRef.get();
        if (gundamDoc.exists) {
          final currentStock = gundamDoc.data()?['stock'] ?? 0;
          if (currentStock >= item.quantity) {
            batch.update(gundamRef, {'stock': currentStock - item.quantity});
          }
        }
      }

      // Clear cart
      final cartSnapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return null;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  Future<String?> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': status});
      await fetchOrders();
      return null;
    } catch (e) {
      return 'Lỗi khi cập nhật trạng thái: $e';
    }
  }

  Future<int> getOrderCount() async {
    try {
      final snapshot = await _firestore.collection('orders').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'Delivered') { // only count delivered orders?
          total += (data['total_amount'] as num).toDouble();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
