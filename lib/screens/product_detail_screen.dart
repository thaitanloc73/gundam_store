import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  bool _isGuest() {
    return FirebaseAuth.instance.currentUser == null;
  }

  void _showGuestDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yêu cầu Đăng nhập'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Đăng nhập', style: TextStyle(color: Color(0xFFE8002D))),
          ),
        ],
      ),
    );
  }

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
    final cart = Provider.of<CartProvider>(context);
    final favorites = Provider.of<FavoriteProvider>(context);
    final isFav = favorites.isFavorite(product.id);
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;
    final borderColor = isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0D0D0F) : Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black54
                        : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF0D0D0F)),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    if (_isGuest()) {
                      _showGuestDialog(context, 'Bạn cần đăng nhập để thêm sản phẩm vào danh sách Yêu thích.');
                    } else {
                      favorites.toggleFavorite(product);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black54
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: const Color(0xFFE8002D),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: isDark
                        ? const Color(0xFF1A1A1E)
                        : Colors.grey.shade100,
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFE8002D), strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark
                        ? const Color(0xFF1A1A1E)
                        : Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_outlined,
                        size: 60, color: Color(0xFF444450)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8002D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color:
                                  const Color(0xFFE8002D).withOpacity(0.3)),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFFE8002D),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatPrice(product.price),
                            style: const TextStyle(
                                fontSize: 26,
                                color: Color(0xFFE8002D),
                                fontWeight: FontWeight.w900),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green.withOpacity(0.1)
                                  : const Color(0xFFE8002D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: product.stock > 0
                                    ? Colors.green.withOpacity(0.3)
                                    : const Color(0xFFE8002D).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: product.stock > 0
                                        ? Colors.green
                                        : const Color(0xFFE8002D),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product.stock > 0
                                      ? 'Còn ${product.stock} SP'
                                      : 'Hết hàng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: product.stock > 0
                                        ? Colors.green
                                        : const Color(0xFFE8002D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailHeader('Mô tả sản phẩm', isDark),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: TextStyle(
                            fontSize: 14, height: 1.7, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailHeader('Thông tin sản phẩm', isDark),
                      const SizedBox(height: 16),
                      _buildSpecRow('Danh mục', product.category, isDark, borderColor),
                      _buildSpecRow(
                          'Tình trạng',
                          product.stock > 0 ? 'Còn hàng' : 'Hết hàng',
                          isDark,
                          borderColor),
                      _buildSpecRow(
                          'Số lượng tồn',
                          '${product.stock} sản phẩm',
                          isDark,
                          borderColor,
                          isLast: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_isGuest()) {
                    _showGuestDialog(context, 'Bạn cần đăng nhập để thêm sản phẩm vào danh sách Yêu thích.');
                  } else {
                    favorites.toggleFavorite(product);
                  }
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF242428)
                        : const Color(0xFFF8F8FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFFE8002D),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: product.stock > 0
                        ? () {
                            if (_isGuest()) {
                              _showGuestDialog(context, 'Bạn cần đăng nhập để thêm sản phẩm vào Giỏ hàng.');
                            } else {
                              cart.addItem(
                                  product.id, product.name, product.price);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text('Đã thêm vào giỏ hàng'),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                duration: const Duration(seconds: 1),
                              ));
                            }
                          }
                        : null,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    label: const Text('THÊM VÀO GIỎ',
                        style: TextStyle(letterSpacing: 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFE8002D),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0D0D0F),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value, bool isDark, Color borderColor,
      {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF888890)
                        : Colors.grey.shade600)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}