import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gundam.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<String> _favoriteIds = {};
  List<Gundam> _favorites = [];
  String? _userId;

  Set<String> get favoriteIds => _favoriteIds;
  List<Gundam> get favorites => _favorites;

  bool isFavorite(String gundamId) => _favoriteIds.contains(gundamId);

  Future<void> loadFavorites(String userId) async {
    _userId = userId;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      _favoriteIds.clear();
      _favorites.clear();

      for (final doc in snapshot.docs) {
        final gundamId = doc.id;
        _favoriteIds.add(gundamId);
        
        // Fetch the gundam details
        final gundamDoc = await _firestore.collection('gundams').doc(gundamId).get();
        if (gundamDoc.exists) {
          _favorites.add(Gundam.fromMap(gundamDoc.data()!, id: gundamDoc.id));
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String gundamId) async {
    if (_userId == null) return;

    final favoriteRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(gundamId);

    try {
      if (_favoriteIds.contains(gundamId)) {
        await favoriteRef.delete();
        _favoriteIds.remove(gundamId);
        _favorites.removeWhere((g) => g.id == gundamId);
      } else {
        await favoriteRef.set({'addedAt': FieldValue.serverTimestamp()});
        _favoriteIds.add(gundamId);
        
        final gundamDoc = await _firestore.collection('gundams').doc(gundamId).get();
        if (gundamDoc.exists) {
          _favorites.insert(0, Gundam.fromMap(gundamDoc.data()!, id: gundamDoc.id));
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  void clear() {
    _userId = null;
    _favoriteIds.clear();
    _favorites.clear();
    notifyListeners();
  }
}
