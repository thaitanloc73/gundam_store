import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/gundam.dart';
import '../providers/gundam_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/constants.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gundamId = ModalRoute.of(context)!.settings.arguments as String;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    final borderColor = isDark ? AppColors.darkBorder : Colors.grey.shade200;

    return FutureBuilder<Gundam?>(
      future: Provider.of<GundamProvider>(context, listen: false).getGundamById(gundamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            body: Center(
              child: Lottie.asset(
                'assets/animations/splash.json',
                width: 100,
                height: 100,
              ),
            ),
          );
        }

        final gundam = snapshot.data;
        if (gundam == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: const Center(child: Text('Không tìm thấy sản phẩm')),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: surfaceColor,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.gundamRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'GUNDAM STORE',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: AppColors.gundamRed,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Consumer<ThemeProvider>(
                      builder: (context, theme, _) => Icon(
                        theme.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                  if (Provider.of<AuthProvider>(context).isLoggedIn) ...[
                    Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final isFav = favProvider.isFavorite(gundam.id!);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.gundamRed : (isDark ? Colors.white : const Color(0xFF0D0D0F)),
                          ),
                          tooltip: 'Yêu thích',
                          onPressed: () => favProvider.toggleFavorite(gundam.id!),
                        );
                      },
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                          ),
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, _) {
                            if (cart.totalItems == 0) return const SizedBox.shrink();
                            return Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.gundamRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  '${cart.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                      ),
                      onPressed: () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                    ),
                  ] else ...[
                    IconButton(
                      icon: Icon(
                        Icons.login,
                        color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                      ),
                      tooltip: 'Đăng nhập',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person_add_outlined,
                        color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                      ),
                      tooltip: 'Đăng ký',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    ),
                  ],
                ],
              ),
              SliverToBoxAdapter(
                child: Image.network(
                  gundam.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  headers: const {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: Lottie.asset(
                          'assets/animations/splash.json',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_outlined,
                        size: 60, color: Color(0xFF444450)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gundamRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.gundamRed.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              gundam.grade,
                              style: const TextStyle(
                                color: AppColors.gundamRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            gundam.name,
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
                                formatPrice(gundam.price),
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: AppColors.gundamRed,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: gundam.stock > 0
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : AppColors.gundamRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: gundam.stock > 0
                                        ? Colors.green.withValues(alpha: 0.3)
                                        : AppColors.gundamRed.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: gundam.stock > 0
                                            ? Colors.green
                                            : AppColors.gundamRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      gundam.stock > 0
                                          ? 'Còn ${gundam.stock} SP'
                                          : 'Hết hàng',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: gundam.stock > 0
                                            ? Colors.green
                                            : AppColors.gundamRed,
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
                          _buildDetailHeader('Thông số kỹ thuật', isDark),
                          const SizedBox(height: 16),
                          _buildSpecRow('Grade', gundam.grade, isDark, borderColor),
                          _buildSpecRow('Tỷ lệ', gundam.scale, isDark, borderColor),
                          _buildSpecRow('Series', gundam.series, isDark, borderColor),
                          _buildSpecRow(
                            'Tình trạng',
                            gundam.stock > 0 ? 'Còn hàng' : 'Hết hàng',
                            isDark,
                            borderColor,
                          ),
                          _buildSpecRow(
                            'Tồn kho',
                            '${gundam.stock} sản phẩm',
                            isDark,
                            borderColor,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: gundam.stock > 0
                      ? () {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          if (!auth.isLoggedIn) {
                            Navigator.pushNamed(context, AppRoutes.login);
                            return;
                          }
                          Provider.of<CartProvider>(context, listen: false).addItem(
                            gundam.id!,
                            gundam.name,
                            gundam.price,
                            gundam.imageUrl,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Đã thêm vào giỏ hàng'),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            duration: const Duration(seconds: 1),
                          ));
                        }
                      : null,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: Text(
                    gundam.stock > 0
                        ? (Provider.of<AuthProvider>(context).isLoggedIn
                            ? 'THÊM VÀO GIỎ'
                            : 'ĐĂNG NHẬP ĐỂ MUA')
                        : 'HẾT HÀNG',
                    style: const TextStyle(letterSpacing: 1),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.gundamRed,
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
                    color: isDark ? const Color(0xFF888890) : Colors.grey.shade600)),
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