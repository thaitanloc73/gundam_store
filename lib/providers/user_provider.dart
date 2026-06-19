import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _phone = '';

  String get name => _name;
  String get email => _email;
  String get phone => _phone;

  void setUserInfo(String name, String email, String phone) {
    _name = name;
    _email = email;
    _phone = phone;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        _name = data['Name'] ?? '';
        _phone = data['Phone'] ?? '';
        _email = user.email ?? '';
        notifyListeners();
      }
    }
  }

  void logout() {
    _name = '';
    _email = '';
    _phone = '';
    notifyListeners();
  }
}