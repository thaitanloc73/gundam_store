import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database/firebase_service.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _firebaseService.seedInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final bgColor = isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF0F0F5);
    final surfaceColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final cardColor = isDark ? const Color(0xFF242428) : const Color(0xFFF8F8FC);
    final borderColor = isDark ? const Color(0xFF2E2E34) : Colors.grey.shade200;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: surfaceColor,
            floating: true,
            snap: true,
            elevation: 0,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8002D),
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
                    color: Color(0xFFE8002D),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: isDark ? Colors.white : const Color(0xFF0D0D0F)),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: surfaceColor,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm mô hình...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_searchQuery.isEmpty) _buildHeroBanner(),
                const SizedBox(height: 24),
                _buildSectionHeader('Danh mục', isDark),
                const SizedBox(height: 12),
                _buildCategories(borderColor, isDark),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == 'Tất cả'
                            ? 'Tất cả sản phẩm'
                            : _selectedCategory,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                        ),
                      ),
                      StreamBuilder<List<Product>>(
                        stream: _firebaseService.getProductsStream(),
                        builder: (context, snap) {
                          final count = snap.data
                                  ?.where((p) =>
                                      (_selectedCategory == 'Tất cả' ||
                                          p.category == _selectedCategory) &&
                                      (_searchQuery.isEmpty ||
                                          p.name
                                              .toLowerCase()
                                              .contains(_searchQuery)))
                                  .length ??
                              0;
                          return Text('$count sản phẩm',
                              style: TextStyle(fontSize: 13, color: textSecondary));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          StreamBuilder<List<Product>>(
            stream: _firebaseService.getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFE8002D))),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                    child: Center(child: Text('Lỗi: ${snapshot.error}')));
              }

              final products = (snapshot.data ?? []).where((p) {
                final matchCat = _selectedCategory == 'Tất cả' ||
                    p.category == _selectedCategory;
                final matchSearch = _searchQuery.isEmpty ||
                    p.name.toLowerCase().contains(_searchQuery);
                return matchCat && matchSearch;
              }).toList();

              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: textSecondary),
                        const SizedBox(height: 12),
                        Text('Không tìm thấy sản phẩm',
                            style: TextStyle(color: textSecondary)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildProductCard(products[index], cardColor, borderColor, isDark),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0005), Color(0xFF3D0010), Color(0xFFE8002D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MỚI NHẤT 2025',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mô hình\nchính hãng Bandai',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Khám phá ngay',
                    style: TextStyle(
                        color: Color(0xFFE8002D),
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFE8002D),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0D0D0F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(Color borderColor, bool isDark) {
    return StreamBuilder<List<String>>(
      stream: _firebaseService.getCategoriesStream(),
      builder: (context, snapshot) {
        final cats = ['Tất cả', ...(snapshot.data ?? [])];
        return SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = cats[i];
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFE8002D)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFE8002D)
                          : borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFF888890)
                              : Colors.grey.shade600),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
      Product product, Color cardColor, Color borderColor, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark
                            ? const Color(0xFF1A1A1E)
                            : Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE8002D), strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark
                            ? const Color(0xFF1A1A1E)
                            : Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_outlined,
                            color: Color(0xFF444450)),
                      ),
                    ),
                    if (product.stock <= 3)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8002D),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SẮP HẾT',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(product.price),
                    style: const TextStyle(
                      color: Color(0xFFE8002D),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}