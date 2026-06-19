import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import 'register_screen.dart';
import 'main_navigation.dart';
import 'admin/admin_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());

        if (userCredential.user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userCredential.user!.uid)
              .get();

          String role = 'Customer';
          if (userDoc.exists && userDoc.data() != null) {
            final data = userDoc.data() as Map<String, dynamic>;
            role = data['Role'] ?? 'Customer';
            final name = data['Name'] ?? '';
            final phone = data['Phone'] ?? '';
            
            // Update UserProvider & other providers
            if (mounted) {
              Provider.of<UserProvider>(context, listen: false)
                  .setUserInfo(name, userCredential.user!.email ?? '', phone);
              Provider.of<CartProvider>(context, listen: false).loadCartData();
              Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
            }
          }

          if (!mounted) return;
          if (role == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminNavigation()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Có lỗi xảy ra.';
        if (e.code == 'user-not-found') message = 'Không tìm thấy tài khoản với email này.';
        if (e.code == 'wrong-password') message = 'Sai mật khẩu.';
        if (e.code == 'invalid-credential') message = 'Email hoặc mật khẩu không chính xác.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFE8002D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8002D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.rocket_launch, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'GUNDAM STORE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Color(0xFFE8002D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chào mừng trở lại, chỉ huy!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF888890) : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'example@email.com',
                      prefixIcon: Icon(Icons.mail_outline, size: 20),
                    ),
                    validator: (value) =>
                        value!.isEmpty || !value.contains('@') ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Mật khẩu'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Color(0xFFE8002D)))
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('ĐĂNG NHẬP',
                                style: TextStyle(letterSpacing: 1.5)),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF888890) : Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Color(0xFFE8002D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigation()),
                        );
                      },
                      child: const Text(
                        'Bỏ qua & Xem trước ứng dụng',
                        style: TextStyle(
                          color: Color(0xFF888890),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
  }
}