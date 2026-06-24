import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_item.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';

class ManageOrderScreen extends StatefulWidget {
  const ManageOrderScreen({super.key});

  @override
  State<ManageOrderScreen> createState() => _ManageOrderScreenState();
}

class _ManageOrderScreenState extends State<ManageOrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, theme, _) => Icon(
                theme.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gundamRed));
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              final statusColor = order.status == 'Pending'
                  ? Colors.orange
                  : order.status == 'Completed'
                      ? Colors.green
                      : Colors.blue;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ExpansionTile(
                  title: Text(
                    'Đơn hàng #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Tổng: ${formatPrice(order.totalAmount)}'),
                      Text('Ngày: ${order.createdAt.substring(0, 16)}'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: order.status == 'Pending'
                      ? ElevatedButton(
                          onPressed: () async {
                            final error = await orderProvider.updateOrderStatus(
                              order.id!,
                              'Completed',
                            );
                            if (!mounted) return;
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(error),
                                backgroundColor: AppColors.gundamRed,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text('Hoàn thành', style: TextStyle(fontSize: 12)),
                        )
                      : Icon(Icons.check_circle, color: Colors.green.shade400),
                  children: [
                    FutureBuilder<List<OrderItem>>(
                      future: orderProvider.getOrderItems(order.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }

                        final items = snapshot.data ?? [];
                        if (items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Không có sản phẩm'),
                          );
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ĐC: ${order.address}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF888890) : Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'SĐT: ${order.phone}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF888890) : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...items.map((item) => ListTile(
                              dense: true,
                              title: Text(item.gundamName ?? 'Gundam #${item.gundamId}'),
                              subtitle: Text('Số lượng: ${item.quantity}'),
                              trailing: Text(formatPrice(item.price * item.quantity)),
                            )),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
