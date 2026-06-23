import 'package:flutter/material.dart';
import '../models/gundam.dart';
import '../services/database_service.dart';

class GundamProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Gundam> _gundams = [];
  bool _isLoading = false;

  List<Gundam> get gundams => _gundams;
  bool get isLoading => _isLoading;

  Future<void> fetchGundams() async {
    _isLoading = true;
    notifyListeners();
    try {
      _gundams = await _db.getGundams();
    } catch (e) {
      _gundams = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Gundam?> getGundamById(int id) async {
    return await _db.getGundamById(id);
  }

  Future<String?> addGundam(Gundam gundam) async {
    try {
      await _db.insertGundam(gundam);
      await fetchGundams();
      return null;
    } catch (e) {
      return 'Lỗi khi thêm sản phẩm: $e';
    }
  }

  Future<String?> updateGundam(Gundam gundam) async {
    try {
      await _db.updateGundam(gundam);
      await fetchGundams();
      return null;
    } catch (e) {
      return 'Lỗi khi cập nhật sản phẩm: $e';
    }
  }

  Future<String?> deleteGundam(int id) async {
    try {
      await _db.deleteGundam(id);
      await fetchGundams();
      return null;
    } catch (e) {
      return 'Lỗi khi xóa sản phẩm: $e';
    }
  }
}
