import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String gundamId;
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

  Map<String, dynamic> toMap() => {
    'gundamId': gundamId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    gundamId: map['gundamId'] ?? '',
    name: map['name'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    imageUrl: map['imageUrl'] ?? '',
    quantity: map['quantity'] ?? 1,
  );
}

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, CartItem> _items = {};
  String? _userId;

  Map<String, CartItem> get items => _items;
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  Future<void> loadCart(String userId) async {
    _userId = userId;
    try {
      final snapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
      _items.clear();
      for (var doc in snapshot.docs) {
        _items[doc.id] = CartItem.fromMap(doc.data());
      }
      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> _syncCartItem(String gundamId, CartItem? item) async {
    if (_userId == null) return;
    try {
      final docRef = _firestore.collection('users').doc(_userId).collection('cart').doc(gundamId);
      if (item == null) {
        await docRef.delete();
      } else {
        await docRef.set(item.toMap());
      }
    } catch (e) {
      print('Error syncing cart item: $e');
    }
  }

  void addItem(String gundamId, String name, double price, String imageUrl) {
    if (_items.containsKey(gundamId)) {
      _items[gundamId]!.quantity++;
      _syncCartItem(gundamId, _items[gundamId]);
    } else {
      final newItem = CartItem(
        gundamId: gundamId,
        name: name,
        price: price,
        imageUrl: imageUrl,
      );
      _items[gundamId] = newItem;
      _syncCartItem(gundamId, newItem);
    }
    notifyListeners();
  }

  void decreaseQty(String gundamId) {
    if (!_items.containsKey(gundamId)) return;
    if (_items[gundamId]!.quantity > 1) {
      _items[gundamId]!.quantity--;
      _syncCartItem(gundamId, _items[gundamId]);
    } else {
      _items.remove(gundamId);
      _syncCartItem(gundamId, null);
    }
    notifyListeners();
  }

  void removeItem(String gundamId) {
    _items.remove(gundamId);
    _syncCartItem(gundamId, null);
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    if (_userId != null) {
      try {
        final snapshot = await _firestore.collection('users').doc(_userId).collection('cart').get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error clearing cart: $e');
      }
    }
  }
}