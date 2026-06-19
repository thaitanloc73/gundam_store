import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Điều khoản sử dụng'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Chấp nhận điều khoản\n'
            'Bằng việc sử dụng ứng dụng này, bạn đồng ý với các điều khoản của chúng tôi.\n\n'
            '2. Quyền sở hữu\n'
            'Mọi hình ảnh và nội dung mô hình thuộc bản quyền của Bandai Namco và Gundam Store.\n\n'
            '3. Thay đổi nội dung\n'
            'Chúng tôi có quyền thay đổi thông tin sản phẩm và giá cả mà không cần thông báo trước.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Thu thập dữ liệu\n'
            'Chúng tôi chỉ thu thập thông tin cơ bản (Tên, SĐT, Địa chỉ) để phục vụ giao hàng.\n\n'
            '2. Bảo vệ dữ liệu\n'
            'Thông tin của bạn được mã hóa và lưu trữ an toàn trên máy chủ của Google Firebase.\n\n'
            '3. Chia sẻ thông tin\n'
            'Tuyệt đối không bán hay chia sẻ thông tin cho bên thứ 3.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;

    final isGuest = FirebaseAuth.instance.currentUser == null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5),
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionLabel('Giao diện', textSecondary),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: SwitchListTile(
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF242428)
                      : const Color(0xFFF0F0F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  size: 18,
                  color: isDark
                      ? const Color(0xFFFFB800)
                      : Colors.grey.shade600,
                ),
              ),
              title: Text('Chế độ tối (Dark Mode)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
              subtitle: Text(isDark ? 'Đang bật' : 'Đang tắt',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
              value: isDark,
              activeColor: const Color(0xFFE8002D),
              onChanged: (_) => themeProvider.toggleTheme(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('Thông tin ứng dụng', textSecondary),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildInfoTile('Phiên bản', 'v1.0.0', Icons.info_outline,
                    isDark, borderColor),
                _buildInfoTile('Điều khoản sử dụng', '',
                    Icons.article_outlined, isDark, borderColor,
                    hasArrow: true, onTap: () => _showTermsDialog(context)),
                _buildInfoTile('Chính sách bảo mật', '',
                    Icons.privacy_tip_outlined, isDark, borderColor,
                    hasArrow: true, isLast: true, onTap: () => _showPrivacyDialog(context)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('Tài khoản', textSecondary),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8002D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(isGuest ? Icons.login : Icons.logout,
                    size: 18, color: const Color(0xFFE8002D)),
              ),
              title: Text(isGuest ? 'Đăng nhập / Đăng ký' : 'Đăng xuất',
                  style: const TextStyle(
                      color: Color(0xFFE8002D),
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              onTap: () {
                if (isGuest) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                } else {
                  _showLogoutDialog(context);
                }
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text('GUNDAM STORE © 2025',
                style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF444450)
                        : Colors.grey.shade400,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: 1)),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, bool isDark,
      Color borderColor,
      {bool hasArrow = false, bool isLast = false, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242428) : const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 18,
                color: isDark
                    ? const Color(0xFF888890)
                    : Colors.grey.shade600),
          ),
          title: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
          trailing: hasArrow
              ? Icon(Icons.chevron_right,
                  color: isDark
                      ? const Color(0xFF444450)
                      : Colors.grey.shade400,
                  size: 20)
              : value.isNotEmpty
                  ? Text(value,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF888890)
                              : Colors.grey.shade600))
                  : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (!isLast) Divider(height: 1, indent: 68, color: borderColor),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content:
            const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (ctx.mounted) {
                Provider.of<CartProvider>(ctx, listen: false).clear();
                Provider.of<FavoriteProvider>(ctx, listen: false).clear();
                Provider.of<UserProvider>(ctx, listen: false).logout();
                Navigator.pushAndRemoveUntil(
                  ctx,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Đăng xuất',
                style: TextStyle(color: Color(0xFFE8002D))),
          ),
        ],
      ),
    );
  }
}