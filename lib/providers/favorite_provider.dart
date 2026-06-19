import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  final Map<String, Product> _favoriteItems = {};

  Map<String, Product> get favoriteItems => _favoriteItems;

  bool isFavorite(String productId) => _favoriteItems.containsKey(productId);

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Favorites').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final productsData = data['products'] as List<dynamic>? ?? [];
      
      _favoriteItems.clear();
      for (var item in productsData) {
        final product = Product.fromMap(item as Map<String, dynamic>, item['id'] ?? '');
        _favoriteItems[product.id] = product;
      }
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Product product) async {
    if (_favoriteItems.containsKey(product.id)) {
      _favoriteItems.remove(product.id);
    } else {
      _favoriteItems[product.id] = product;
    }
    notifyListeners();

    // Sync to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final List<Map<String, dynamic>> productsList = _favoriteItems.values.map((p) {
        var map = p.toMap();
        map['id'] = p.id;
        return map;
      }).toList();
      
      await FirebaseFirestore.instance.collection('Favorites').doc(user.uid).set({
        'products': productsList,
      });
    }
  }

  void clear() {
    _favoriteItems.clear();
    notifyListeners();
  }
}