import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gundam.dart';

class GundamProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Gundam> _gundams = [];
  bool _isLoading = false;

  List<Gundam> get gundams => _gundams;
  bool get isLoading => _isLoading;

  Future<void> fetchGundams() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Tự động thêm 8 sản phẩm cũ nếu collection trống
      await _seedDummyDataIfNeeded();

      final snapshot = await _firestore.collection('gundams').get();
      _gundams = snapshot.docs.map((doc) => Gundam.fromMap(doc.data(), id: doc.id)).toList();
    } catch (e) {
      print('Error fetching gundams: $e');
      _gundams = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedDummyDataIfNeeded() async {
    try {
      final snapshot = await _firestore.collection('gundams').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final dummyData = [
          Gundam(name: 'RX-78-2 Gundam (Revive)', grade: 'HG', scale: '1/144', series: 'Mobile Suit Gundam', price: 350000, stock: 10, imageUrl: 'https://i.ebayimg.com/images/g/3rQAAeSwNyhoZPwp/s-l1600.webp'),
          Gundam(name: 'Unicorn Gundam', grade: 'RG', scale: '1/144', series: 'Gundam Unicorn', price: 850000, stock: 5, imageUrl: 'https://i.ebayimg.com/images/g/7jIAAeSw3ltoaOef/s-l1600.webp'),
          Gundam(name: 'Wing Gundam Zero Custom EW', grade: 'MG', scale: '1/100', series: 'Gundam Wing', price: 1250000, stock: 3, imageUrl: 'https://i.ebayimg.com/images/g/9UcAAeSwp8JqIGRW/s-l960.webp'),
          Gundam(name: 'Gundam Aerial', grade: 'HG', scale: '1/144', series: 'Witch from Mercury', price: 450000, stock: 12, imageUrl: 'https://i.ebayimg.com/images/g/K-8AAeSwwatp3ftS/s-l1600.webp'),
          Gundam(name: 'SD RX-78-2', grade: 'SD', scale: 'Non-scale', series: 'Mobile Suit Gundam', price: 200000, stock: 20, imageUrl: 'https://i.ebayimg.com/images/g/XXQAAeSweJZqFBiH/s-l1600.webp'),
          Gundam(name: 'Strike Freedom', grade: 'PG', scale: '1/60', series: 'Gundam SEED Destiny', price: 5500000, stock: 2, imageUrl: 'https://i.ebayimg.com/images/g/AKMAAOSwGM9m4aPv/s-l1600.webp'),
          Gundam(name: 'Sazabi', grade: 'RG', scale: '1/144', series: "Char's Counterattack", price: 1150000, stock: 4, imageUrl: 'https://i.ebayimg.com/images/g/KuYAAeSw6bxouBKL/s-l1600.webp'),
          Gundam(name: 'Barbatos Lupus Rex', grade: 'HG', scale: '1/144', series: 'Iron-Blooded Orphans', price: 480000, stock: 8, imageUrl: 'https://i.ebayimg.com/images/g/8LwAAeSw9JZqL8n0/s-l500.webp'),
        ];
        
        final batch = _firestore.batch();
        for (final g in dummyData) {
          final docRef = _firestore.collection('gundams').doc();
          batch.set(docRef, g.toMap());
        }
        await batch.commit();
        print('Đã tự động tạo 8 sản phẩm Gundam mẫu vào Firebase!');
      }
    } catch (e) {
      print('Lỗi tạo dữ liệu mẫu: $e');
    }
  }

  Future<Gundam?> getGundamById(String id) async {
    try {
      final doc = await _firestore.collection('gundams').doc(id).get();
      if (doc.exists) {
        return Gundam.fromMap(doc.data()!, id: doc.id);
      }
    } catch (e) {
      print('Error getting gundam: $e');
    }
    return null;
  }

  Future<String?> addGundam(Gundam gundam) async {
    try {
      await _firestore.collection('gundams').add(gundam.toMap());
      await fetchGundams();
      return null;
    } catch (e) {
      return 'Lỗi khi thêm sản phẩm: $e';
    }
  }

  Future<String?> updateGundam(Gundam gundam) async {
    if (gundam.id == null) return 'ID sản phẩm không hợp lệ';
    try {
      await _firestore.collection('gundams').doc(gundam.id).update(gundam.toMap());
      await fetchGundams();
      return null;
    } catch (e) {
      return 'Lỗi khi cập nhật sản phẩm: $e';
    }
  }

  Future<String?> deleteGundam(String id) async {
    try {
      await _firestore.collection('gundams').doc(id).delete();
      await fetchGundams();
      return null;
    } catch (e) {
      return 'Lỗi khi xóa sản phẩm: $e';
    }
  }
}
