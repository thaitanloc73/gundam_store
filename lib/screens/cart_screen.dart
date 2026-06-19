import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../database/firebase_service.dart';
import '../models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;

    final isGuest = FirebaseAuth.instance.currentUser == null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Giỏ hàng'),
            if (!isGuest && cart.items.isNotEmpty)
              Text('${cart.items.length} sản phẩm',
                  style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          if (!isGuest && cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, cart),
              child: const Text('Xóa tất cả',
                  style: TextStyle(color: Color(0xFFE8002D), fontSize: 13)),
            ),
        ],
      ),
      body: isGuest
          ? _buildGuestCart(context, isDark, textSecondary)
          : cart.items.isEmpty
              ? _buildEmptyCart(isDark, textSecondary)
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<Product>>(
                        stream: FirebaseService().getProductsStream(),
                        builder: (context, snapshot) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final entry =
                                  cart.items.entries.elementAt(index);
                              final cartItem = entry.value;
                              final product = snapshot.data?.firstWhere(
                                (p) => p.id == cartItem.id,
                                orElse: () => Product(
                                  id: cartItem.id,
                                  name: cartItem.name,
                                  image: '',
                                  description: '',
                                  price: cartItem.price,
                                  stock: 99,
                                  category: '',
                                ),
                              );
                              return _buildCartItem(context, cartItem, product,
                                  cart, cardColor, borderColor, isDark);
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(top: BorderSide(color: borderColor)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tạm tính',
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 14)),
                                Text(_formatPrice(cart.totalAmount),
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Phí vận chuyển',
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 14)),
                                Text('Miễn phí',
                                    style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: borderColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tổng cộng',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0D0D0F))),
                                Text(
                                  _formatPrice(cart.totalAmount),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFE8002D)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CheckoutScreen()),
                                ),
                                child: const Text('TIẾN HÀNH THANH TOÁN',
                                    style: TextStyle(letterSpacing: 1)),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem, Product? product,
      CartProvider cart, Color cardColor, Color borderColor, bool isDark) {
    return Container(
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
            child: (product?.image ?? '').isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product!.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 80,
                        height: 80,
                        color: isDark
                            ? const Color(0xFF242428)
                            : Colors.grey.shade100),
                    errorWidget: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: isDark
                            ? const Color(0xFF242428)
                            : Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_outlined,
                            color: Color(0xFF444450))),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF242428)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_outlined,
                        color: Color(0xFF444450)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                      height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(_formatPrice(cartItem.price),
                    style: const TextStyle(
                        color: Color(0xFFE8002D),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _qtyButton(
                      icon: Icons.remove,
                      onTap: () => cartItem.quantity > 1
                          ? cart.decreaseQty(cartItem.id)
                          : cart.removeItem(cartItem.id),
                      isDark: isDark,
                      borderColor: borderColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('${cartItem.quantity}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0D0D0F))),
                    ),
                    _qtyButton(
                      icon: Icons.add,
                      onTap: () =>
                          cart.addItem(cartItem.id, cartItem.name, cartItem.price),
                      isDark: isDark,
                      borderColor: borderColor,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => cart.removeItem(cartItem.id),
                      child: const Icon(Icons.delete_outline,
                          color: Color(0xFFE8002D), size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(
      {required IconData icon,
      required VoidCallback onTap,
      required bool isDark,
      required Color borderColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242428) : const Color(0xFFF0F0F5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon,
            size: 16,
            color: isDark ? Colors.white : const Color(0xFF0D0D0F)),
      ),
    );
  }

  Widget _buildGuestCart(BuildContext context, bool isDark, Color textSecondary) {
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
            child: const Icon(Icons.shopping_cart_outlined,
                size: 48, color: Color(0xFFE8002D)),
          ),
          const SizedBox(height: 20),
          Text('Vui lòng đăng nhập',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
          const SizedBox(height: 8),
          Text('Bạn cần đăng nhập để sử dụng Giỏ hàng',
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

  Widget _buildEmptyCart(bool isDark, Color textSecondary) {
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
            child: const Icon(Icons.shopping_cart_outlined,
                size: 48, color: Color(0xFFE8002D)),
          ),
          const SizedBox(height: 20),
          Text('Giỏ hàng trống',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
          const SizedBox(height: 8),
          Text('Thêm sản phẩm để bắt đầu mua sắm!',
              style: TextStyle(color: textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giỏ hàng?'),
        content: const Text(
            'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa',
                style: TextStyle(color: Color(0xFFE8002D))),
          ),
        ],
      ),
    );
  }
}