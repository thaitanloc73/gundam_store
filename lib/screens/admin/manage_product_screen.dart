import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/gundam.dart';
import '../../providers/gundam_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';

class ManageProductScreen extends StatefulWidget {
  const ManageProductScreen({super.key});

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GundamProvider>(context, listen: false).fetchGundams();
    });
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

  void _showProductDialog({Gundam? gundam}) {
    final isEditing = gundam != null;
    final nameCtrl = TextEditingController(text: gundam?.name ?? '');
    final gradeCtrl = TextEditingController(text: gundam?.grade ?? 'HG');
    final scaleCtrl = TextEditingController(text: gundam?.scale ?? '1/144');
    final seriesCtrl = TextEditingController(text: gundam?.series ?? '');
    final priceCtrl = TextEditingController(text: gundam?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: gundam?.stock.toString() ?? '');
    final imageCtrl = TextEditingController(text: gundam?.imageUrl ?? '');
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
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: gradeCtrl.text,
                  decoration: const InputDecoration(labelText: 'Grade'),
                  items: ['SD', 'HG', 'RG', 'MG', 'PG']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      gradeCtrl.text = v;
                    }
                  },
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: gradeCtrl,
                  builder: (context, value, _) {
                    final grade = value.text;
                    if (grade.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getGradeExplanation(grade),
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: scaleCtrl,
                  decoration: const InputDecoration(labelText: 'Tỷ lệ (VD: 1/144)'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: seriesCtrl,
                  decoration: const InputDecoration(labelText: 'Series'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Không được để trống';
                    final price = double.tryParse(v);
                    if (price == null || price <= 0) return 'Giá phải lớn hơn 0';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Tồn kho'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Không được để trống';
                    final stock = int.tryParse(v);
                    if (stock == null || stock < 0) return 'Tồn kho phải >= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'URL Hình ảnh'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final provider = Provider.of<GundamProvider>(context, listen: false);
              final newGundam = Gundam(
                id: isEditing ? gundam.id : null,
                name: nameCtrl.text.trim(),
                grade: gradeCtrl.text.trim(),
                scale: scaleCtrl.text.trim(),
                series: seriesCtrl.text.trim(),
                price: double.parse(priceCtrl.text.trim()),
                stock: int.parse(stockCtrl.text.trim()),
                imageUrl: imageCtrl.text.trim(),
              );

              String? error;
              if (isEditing) {
                error = await provider.updateGundam(newGundam);
              } else {
                error = await provider.addGundam(newGundam);
              }

              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.gundamRed,
                ));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              final error = await Provider.of<GundamProvider>(context, listen: false)
                  .deleteGundam(id);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.gundamRed,
                ));
              }
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: Consumer<GundamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gundamRed));
          }

          if (provider.gundams.isEmpty) {
            return const Center(child: Text('Không có sản phẩm nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.gundams.length,
            itemBuilder: (context, index) {
              final gundam = provider.gundams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      gundam.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      headers: const {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                      },
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(gundam.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${gundam.grade} · ${gundam.scale} · ${formatPrice(gundam.price)} · Kho: ${gundam.stock}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductDialog(gundam: gundam),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(gundam.id!),
                      ),
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
