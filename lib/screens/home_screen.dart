import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gundam_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

import '../widgets/gundam_card.dart';
import '../widgets/loading_widget.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGrade = 'Tất cả';
  String _sortOption = 'Mặc định';

  final List<String> _grades = ['Tất cả', 'SD', 'HG', 'RG', 'MG', 'PG'];
  final List<String> _sortOptions = ['Mặc định', 'Giá tăng', 'Giá giảm'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GundamProvider>(context, listen: false).fetchGundams();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGradeExplanation(String grade) {
    switch (grade) {
      case 'SD':
        return 'Mô hình đầu to, thân nhỏ.';
      case 'HG':
        return 'Chi tiết cơ bản, tỉ lệ thường 1/144.';
      case 'RG':
        return 'Tỉ lệ 1/144 nhưng chi tiết cao hơn HG.';
      case 'MG':
        return 'Tỉ lệ 1/100, nhiều chi tiết và khung xương bên trong.';
      case 'PG':
        return 'Tỉ lệ 1/60, cao cấp nhất, kích thước lớn và rất chi tiết.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textSecondary = isDark ? const Color(0xFF888890) : Colors.grey.shade600;
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.landscape
        ? (screenWidth > 900 ? 4 : 3)
        : 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: surfaceColor,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.gundamRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                  ),
                  tooltip: 'Yêu thích',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.favorites),
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
                    if (!mounted) return;
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),
          if (_searchQuery.isEmpty)
            SliverToBoxAdapter(child: _buildHeroBanner()),
          // Grade filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _grades.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final grade = _grades[index];
                    final isSelected = _selectedGrade == grade;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGrade = grade),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gundamRed
                              : (isDark ? AppColors.darkCard : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.gundamRed
                                : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          grade,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey.shade700),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_selectedGrade != 'Tất cả')
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: isDark ? const Color(0xFF888890) : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getGradeExplanation(_selectedGrade),
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDark ? const Color(0xFF888890) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Sort options
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.gundamRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedGrade == 'Tất cả' ? 'Tất cả sản phẩm' : 'Grade $_selectedGrade',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortOption,
                        icon: Icon(Icons.sort, size: 16, color: isDark ? Colors.white70 : Colors.grey.shade600),
                        isDense: true,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                        items: _sortOptions.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        )).toList(),
                        onChanged: (v) => setState(() => _sortOption = v ?? 'Mặc định'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          Consumer<GundamProvider>(
            builder: (context, gundamProvider, _) {
              if (gundamProvider.isLoading) {
                return const SliverFillRemaining(
                  child: LoadingWidget(),
                );
              }

              var products = gundamProvider.gundams.where((g) {
                final matchesSearch = _searchQuery.isEmpty ||
                    g.name.toLowerCase().contains(_searchQuery);
                final matchesGrade = _selectedGrade == 'Tất cả' ||
                    g.grade == _selectedGrade;
                return matchesSearch && matchesGrade;
              }).toList();

              if (_sortOption == 'Giá tăng') {
                products.sort((a, b) => a.price.compareTo(b.price));
              } else if (_sortOption == 'Giá giảm') {
                products.sort((a, b) => b.price.compareTo(a.price));
              }

              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: textSecondary),
                        const SizedBox(height: 12),
                        Text('Không có sản phẩm nào',
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
                    (context, index) => GundamCard(
                      gundam: products[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productDetail,
                          arguments: products[index].id,
                        );
                      },
                    ),
                    childCount: products.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
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
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0005), Color(0xFF3D0010), AppColors.gundamRed],
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
                color: Colors.white.withValues(alpha: 0.05),
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
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BỘ SƯU TẬP 2025',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mô hình\nchính hãng Bandai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SD · HG · RG · MG · PG',
                      style: TextStyle(
                        color: AppColors.gundamRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}