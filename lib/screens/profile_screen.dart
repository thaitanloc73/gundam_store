import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import 'settings_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showUpdateInfoDialog(BuildContext context, UserProvider userProvider) {
    final nameCtrl = TextEditingController(text: userProvider.name);
    final phoneCtrl = TextEditingController(text: userProvider.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật thông tin'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập SĐT' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
                    'Name': nameCtrl.text.trim(),
                    'Phone': phoneCtrl.text.trim(),
                  });
                  // Update local provider
                  if (ctx.mounted) {
                    Provider.of<UserProvider>(ctx, listen: false).loadUserData();
                  }
                }
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật thành công!'))
                  );
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    String currentAddress = '';
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      currentAddress = doc.data()?['Address'] ?? '';
    }

    if (!context.mounted) return;

    final addressCtrl = TextEditingController(text: currentAddress);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Địa chỉ giao hàng'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: addressCtrl,
            decoration: const InputDecoration(labelText: 'Địa chỉ hiện tại'),
            maxLines: 3,
            validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (user != null) {
                  await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
                    'Address': addressCtrl.text.trim(),
                  });
                }
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật địa chỉ thành công!'))
                  );
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hỗ trợ & Liên hệ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Nếu bạn cần hỗ trợ, vui lòng liên hệ:'),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: Text('Hotline: 1900 1234'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.red),
              title: Text('Email: support@gundamstore.vn'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.location_city, color: Colors.green),
              title: Text('Cửa hàng: Quận 1, TP. HCM'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<UserProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final favorites = Provider.of<FavoriteProvider>(context);
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;

    final isGuest = FirebaseAuth.instance.currentUser == null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5),
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isGuest ? Colors.grey : null,
                    gradient: isGuest ? null : const LinearGradient(
                      colors: [Color(0xFFE8002D), Color(0xFF8B0019)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isGuest ? 'K' : (user.name.isNotEmpty ? user.name[0].toUpperCase() : 'G'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGuest ? 'Khách tham quan' : (user.name.isNotEmpty ? user.name : 'Người dùng'),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0D0D0F)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGuest ? 'Đăng nhập để trải nghiệm đầy đủ tính năng' : (user.email.isNotEmpty
                            ? user.email
                            : 'email@example.com'),
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                      if (!isGuest && user.phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(user.phone,
                            style: TextStyle(fontSize: 13, color: textSecondary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!isGuest)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('${cart.items.length}', 'Giỏ hàng',
                      Icons.shopping_cart_outlined, cardColor, borderColor, isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      '${favorites.favoriteItems.length}',
                      'Yêu thích',
                      Icons.favorite_border,
                      cardColor,
                      borderColor,
                      isDark),
                ),
              ],
            ),
          if (!isGuest) const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                if (!isGuest) ...[
                  _buildMenuItem(
                    icon: Icons.history_outlined,
                    label: 'Lịch sử đơn hàng',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.edit_outlined,
                    label: 'Cập nhật thông tin',
                    onTap: () => _showUpdateInfoDialog(context, user),
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ giao hàng',
                    onTap: () => _showAddressDialog(context),
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ],
                _buildMenuItem(
                  icon: Icons.help_outline,
                  label: 'Hỗ trợ & Liên hệ',
                  onTap: () => _showSupportDialog(context),
                  borderColor: borderColor,
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon,
      Color cardColor, Color borderColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8002D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFE8002D), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0D0D0F))),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF888890)
                          : Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color borderColor,
    required bool isDark,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
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
          trailing: Icon(Icons.chevron_right,
              color: isDark
                  ? const Color(0xFF444450)
                  : Colors.grey.shade400,
              size: 20),
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (!isLast) Divider(height: 1, indent: 68, color: borderColor),
      ],
    );
  }
}