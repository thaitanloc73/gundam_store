class Product {
  final String id;
  final String name;
  final String image;
  final String description;
  final double price;
  final int stock;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      description: data['Description'] ?? '',
      price: (data['Price'] ?? 0).toDouble(),
      stock: data['Stock'] ?? 0,
      category: data['Category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Image': image,
      'Description': description,
      'Price': price,
      'Stock': stock,
      'Category': category,
    };
  }
}
