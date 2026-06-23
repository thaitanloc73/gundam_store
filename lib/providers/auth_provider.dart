import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoading => _isLoading;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email == null) return false;

    final user = await _db.getUserByEmail(email);
    if (user == null) return false;

    _currentUser = user;
    notifyListeners();
    return true;
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        return 'Không tìm thấy tài khoản với email này.';
      }
      if (user.password != password) {
        return 'Mật khẩu không chính xác.';
      }

      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        return 'Email này đã được sử dụng.';
      }

      final user = User(
        email: email,
        password: password,
        role: 'customer',
        name: name,
      );

      await _db.insertUser(user);
      return null;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    notifyListeners();
  }
}
