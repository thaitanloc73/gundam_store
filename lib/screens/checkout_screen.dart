import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String _paymentMethod = 'COD'; // Mặc định là Thanh toán khi nhận hàng

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['Name'] ?? '';
          _phoneController.text = data['Phone'] ?? '';
          _addressController.text = data['Address'] ?? '';
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final cart = Provider.of<CartProvider>(context, listen: false);
      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giỏ hàng đang trống!')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid ?? 'guest';

        final List<Map<String, dynamic>> orderItems = cart.items.values.map((item) {
          return {
            'productId': item.id,
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
          };
        }).toList();

        final order = OrderModel(
          id: '',
          userId: userId,
          customerName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          totalAmount: cart.totalAmount,
          status: 'Pending',
          orderDate: DateTime.now(),
          items: orderItems,
        );

        // Lưu đơn hàng vào Firestore
        await FirebaseFirestore.instance.collection('Orders').add(order.toMap());

        // Trừ tồn kho (Stock) của từng sản phẩm
        for (var item in orderItems) {
          final productId = item['productId'];
          final quantity = item['quantity'];
          
          await FirebaseFirestore.instance.collection('Products').doc(productId).update({
            'Stock': FieldValue.increment(-quantity)
          });
        }

        cart.clear(); // Xóa giỏ hàng sau khi đặt thành công
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt hàng thành công!')));
        Navigator.pop(context); // Quay về giỏ hàng
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt hàng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin giao hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên người nhận'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ nhận hàng'),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 24),
              Text('Phương thức thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<String>(
                  title: const Text('Thanh toán khi nhận hàng (COD)'),
                  value: 'COD',
                  groupValue: _paymentMethod,
                  activeColor: const Color(0xFFE8002D),
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFFE8002D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('XÁC NHẬN ĐẶT HÀNG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    )
            ],
          ),
        ),
      ),
    );
  }
}