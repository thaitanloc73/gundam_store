import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = Provider.of<FavoriteProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;
    final items = favorites.favoriteItems.values.toList();

    final isGuest = FirebaseAuth.instance.currentUser == null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yêu thích'),
            if (!isGuest && items.isNotEmpty)
              Text('${items.length} sản phẩm',
                  style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: isGuest
          ? _buildGuestFavorite(context, isDark, textSecondary)
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8002D).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border,
                            size: 48, color: Color(0xFFE8002D)),
                      ),
                      const SizedBox(height: 20),
                      Text('Chưa có sản phẩm yêu thích',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
                      const SizedBox(height: 8),
                      Text('Nhấn ♥ để lưu sản phẩm bạn thích',
                          style: TextStyle(color: textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.image.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: product.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                          width: 80,
                                          height: 80,
                                          color: isDark
                                              ? const Color(0xFF242428)
                                              : Colors.grey.shade100,
                                          child: const Icon(
                                              Icons.broken_image_outlined,
                                              color: Color(0xFF444450))),
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: isDark
                                          ? const Color(0xFF242428)
                                          : Colors.grey.shade100,
                                      child: const Icon(Icons.image_outlined,
                                          color: Color(0xFF444450))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0D0D0F),
                                          height: 1.3)),
                                  const SizedBox(height: 6),
                                  Text(_formatPrice(product.price),
                                      style: const TextStyle(
                                          color: Color(0xFFE8002D),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => favorites.toggleFavorite(product),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8002D).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.favorite,
                                        color: Color(0xFFE8002D), size: 18),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    cart.addItem(
                                        product.id, product.name, product.price);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text('Đã thêm vào giỏ hàng'),
                                      backgroundColor: Colors.green.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      duration: const Duration(seconds: 1),
                                    ));
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8002D),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                        size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildGuestFavorite(BuildContext context, bool isDark, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE8002D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border,
                size: 48, color: Color(0xFFE8002D)),
          ),
          const SizedBox(height: 20),
          Text('Vui lòng đăng nhập',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
          const SizedBox(height: 8),
          Text('Bạn cần đăng nhập để xem danh sách Yêu thích',
              style: TextStyle(color: textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('ĐĂNG NHẬP NGAY'),
          ),
        ],
      ),
    );
  }
}