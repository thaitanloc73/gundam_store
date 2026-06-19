import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lấy danh sách sản phẩm dạng Stream (Real-time)
  Stream<List<Product>> getProductsStream() {
    return _db.collection('Products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Lấy danh sách các danh mục (Categories) không trùng lặp từ Products
  Stream<List<String>> getCategoriesStream() {
    return _db.collection('Products').snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => doc.data()['Category'] as String? ?? 'Khác')
          .toSet()
          .toList();
      categories.sort();
      return categories;
    });
  }

  Future<void> addProduct(Product product) async {
    await _db.collection('Products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection('Products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('Products').doc(productId).delete();
  }

  // Tự động đẩy dữ liệu mẫu lên Firebase nếu DB trống
  Future<void> seedInitialData() async {
    final snapshot = await _db.collection('Products').limit(1).get();
    
    // Nếu chưa có dữ liệu nào trong bảng Products
    if (snapshot.docs.isEmpty) {
      List<Product> sampleProducts = [
        Product(
          id: '', // Firebase sẽ tự generate
          name: 'Gundam RX-78-2',
          image: 'https://images.unsplash.com/photo-1608889175250-c3b0c1667d3a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          description: 'Mô hình Gundam RX-78-2 tỷ lệ 1/144 cực kỳ chi tiết, phù hợp cho người mới chơi.',
          price: 500000,
          stock: 10,
          category: 'Gundam',
        ),
        Product(
          id: '',
          name: 'Gundam Barbatos Lupus Rex',
          image: 'https://images.unsplash.com/photo-1632283032338-7bb4324f9e42?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          description: 'Mô hình Barbatos với thiết kế ngầu và vũ khí siêu to khổng lồ.',
          price: 650000,
          stock: 5,
          category: 'Gundam',
        ),
        Product(
          id: '',
          name: 'Iron Man Mark 85',
          image: 'https://images.unsplash.com/photo-1608889825103-eb5ed706fc64?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          description: 'Figure Iron Man Mark 85 với các khớp nối linh hoạt.',
          price: 1200000,
          stock: 3,
          category: 'Marvel Figure',
        ),
        Product(
          id: '',
          name: 'Gojo Satoru Figure',
          image: 'https://images.unsplash.com/photo-1606663889134-b1dedb5ed8b7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          description: 'Figure nhân vật Gojo Satoru trong Jujutsu Kaisen.',
          price: 850000,
          stock: 8,
          category: 'Anime Figure',
        ),
      ];

      for (var product in sampleProducts) {
        await _db.collection('Products').add(product.toMap());
      }
      print('✅ Đã thêm dữ liệu mẫu vào Firebase thành công!');
    }
  }
}
