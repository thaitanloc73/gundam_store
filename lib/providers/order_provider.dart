import 'package:flutter/material.dart';
import '../models/order.dart' as model;
import '../models/order_item.dart';
import '../services/database_service.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<model.Order> _orders = [];
  bool _isLoading = false;

  List<model.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _db.getOrders();
    } catch (e) {
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrdersByUser(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _db.getOrdersByUserId(userId);
    } catch (e) {
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    return await _db.getOrderItems(orderId);
  }

  Future<String?> placeOrder({
    required int userId,
    required String address,
    required String phone,
    required Map<int, CartItem> cartItems,
    required double totalAmount,
  }) async {
    try {
      for (final item in cartItems.values) {
        final gundam = await _db.getGundamById(item.gundamId);
        if (gundam == null) {
          return 'Sản phẩm "${item.name}" không tồn tại.';
        }
        if (gundam.stock < item.quantity) {
          return 'Sản phẩm "${item.name}" chỉ còn ${gundam.stock} trong kho.';
        }
      }

      final order = model.Order(
        userId: userId,
        totalAmount: totalAmount,
        address: address,
        phone: phone,
        status: 'Pending',
        createdAt: DateTime.now().toIso8601String(),
      );

      final orderId = await _db.insertOrder(order);

      for (final item in cartItems.values) {
        await _db.insertOrderItem(OrderItem(
          orderId: orderId,
          gundamId: item.gundamId,
          quantity: item.quantity,
          price: item.price,
        ));
        await _db.updateGundamStock(item.gundamId, item.quantity);
      }

      return null;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  Future<String?> updateOrderStatus(int orderId, String status) async {
    try {
      await _db.updateOrderStatus(orderId, status);
      await fetchOrders();
      return null;
    } catch (e) {
      return 'Lỗi khi cập nhật trạng thái: $e';
    }
  }

  Future<int> getOrderCount() async {
    return await _db.getOrderCount();
  }

  Future<double> getTotalRevenue() async {
    return await _db.getTotalRevenue();
  }
}
