import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoading => _isLoading;

  Future<bool> tryAutoLogin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    return await _fetchUserData(user.uid, user.email!);
  }

  Future<bool> _fetchUserData(String uid, String email) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = User(
          id: uid,
          email: email,
          password: '', // Firebase handles password
          role: data['role'] ?? 'customer',
          name: data['name'] ?? '',
        );
      } else {
        // Fallback if doc doesn't exist (e.g. created via console)
        _currentUser = User(
          id: uid,
          email: email,
          password: '',
          role: 'customer',
          name: email.split('@')[0],
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      print('Error fetching user data: $e');
      return false;
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _fetchUserData(credential.user!.uid, credential.user!.email!);
        return null;
      }
      return 'Lỗi đăng nhập không xác định.';
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        return 'Không tìm thấy tài khoản với email này.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Mật khẩu không chính xác.';
      }
      return 'Lỗi: ${e.message}';
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await _fetchUserData(credential.user!.uid, email);
        return null;
      }
      return 'Lỗi đăng ký không xác định.';
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email này đã được sử dụng.';
      }
      return 'Lỗi: ${e.message}';
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
