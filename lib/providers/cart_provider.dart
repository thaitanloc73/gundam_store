import 'package:flutter/material.dart';

class CartItem {
  final int gundamId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.gundamId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(int gundamId, String name, double price, String imageUrl) {
    if (_items.containsKey(gundamId)) {
      _items[gundamId]!.quantity++;
    } else {
      _items[gundamId] = CartItem(
        gundamId: gundamId,
        name: name,
        price: price,
        imageUrl: imageUrl,
      );
    }
    notifyListeners();
  }

  void decreaseQty(int gundamId) {
    if (!_items.containsKey(gundamId)) return;
    if (_items[gundamId]!.quantity > 1) {
      _items[gundamId]!.quantity--;
    } else {
      _items.remove(gundamId);
    }
    notifyListeners();
  }

  void removeItem(int gundamId) {
    _items.remove(gundamId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}