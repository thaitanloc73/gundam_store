import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({required this.id, required this.name, required this.price, this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  Future<void> loadCartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Carts').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final itemsData = data['items'] as List<dynamic>? ?? [];
      
      _items.clear();
      for (var item in itemsData) {
        final cartItem = CartItem.fromMap(item as Map<String, dynamic>);
        _items[cartItem.id] = cartItem;
      }
      notifyListeners();
    }
  }

  Future<void> _syncToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final List<Map<String, dynamic>> itemsList = _items.values.map((item) => item.toMap()).toList();
      await FirebaseFirestore.instance.collection('Carts').doc(user.uid).set({
        'items': itemsList,
      });
    }
  }

  void addItem(String productId, String name, double price) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
    } else {
      _items[productId] = CartItem(id: productId, name: name, price: price);
    }
    notifyListeners();
    _syncToFirestore();
  }

  void decreaseQty(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
    _syncToFirestore();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    _syncToFirestore();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _syncToFirestore();
  }
}