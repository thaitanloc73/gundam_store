import 'package:flutter/material.dart';
import '../../database/firebase_service.dart';
import '../../models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  void _showProductDialog({Product? product}) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? '');
    final imageCtrl = TextEditingController(text: product?.image ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Tồn kho'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'URL Hình ảnh'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newProduct = Product(
                  id: isEditing ? product.id : '',
                  name: nameCtrl.text.trim(),
                  price: double.parse(priceCtrl.text.trim()),
                  stock: int.parse(stockCtrl.text.trim()),
                  category: categoryCtrl.text.trim(),
                  image: imageCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                
                if (isEditing) {
                  await _firebaseService.updateProduct(newProduct);
                } else {
                  await _firebaseService.addProduct(newProduct);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await _firebaseService.deleteProduct(productId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showProductDialog()),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào.'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                  title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Giá: ${product.price} - Kho: ${product.stock}\nDanh mục: ${product.category}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showProductDialog(product: product)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(product.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}