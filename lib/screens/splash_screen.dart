import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import 'login_screen.dart';
import 'main_navigation.dart';
import 'admin/admin_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3200), () async {
      Widget nextScreen = const MainNavigation();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Tải dữ liệu profile, cart, favorites
        if (mounted) {
          await Provider.of<UserProvider>(context, listen: false).loadUserData();
          Provider.of<CartProvider>(context, listen: false).loadCartData();
          Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
        }
        
        // Kiểm tra Role Admin
        String role = 'Customer';
        final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          role = doc.data()!['Role'] ?? 'Customer';
        }
        
        if (role == 'Admin') {
          nextScreen = const AdminNavigation();
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => nextScreen,
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8002D).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8002D).withOpacity(0.04),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/splash.json',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8002D),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'GUNDAM STORE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mô hình cao cấp · Chính hãng',
                            style: TextStyle(
                              color: Color(0xFF666670),
                              fontSize: 13,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF444450), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}