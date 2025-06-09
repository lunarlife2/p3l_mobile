import 'package:flutter/material.dart';
import 'package:mobile_p3l/services/api_category.dart';
import 'package:mobile_p3l/screens/product_by_category.dart'; // sesuaikan path import

class CategorySection extends StatefulWidget {
  final Function(String?)? onCategorySelected;  // Ganti int? jadi String?

  CategorySection({this.onCategorySelected});

  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String error = '';

  int page = 0;
  int itemsPerPage = 7;

  final Map<String, String> categoryDisplayLabels = {
    'Elektronik-&-Gadget': 'Elektronik & Gadget',
    'Pakaian-&-Aksesori': 'Pakaian & Aksesori',
    'Perabotan-Rumah-Tangga': 'Perabotan Rumah Tangga',
    'Buku,-Alat-Tulis,-&-Peralatan Sekolah': 'Buku, Alat Tulis, & Peralatan Sekolah',
    'Hobi,-Mainan,-&-Koleksi': 'Hobi, Mainan, & Koleksi',
    'Perlengkapan-Bayi-&-Anak': 'Perlengkapan Bayi & Anak',
    'Perlengkapan-Taman-&-Outdoor': 'Perlengkapan Taman & Outdoor',
    'Otomotif-&-Aksesori': 'Otomotif & Aksesori',
    'Peralatan-Kantor-&-Industri': 'Peralatan Kantor & Industri',
    'Kosmetik-&-Perawatan Diri': 'Kosmetik & Perawatan Diri',
  };

  final Map<String, String> categoryIcons = {
    'Elektronik & Gadget': '📱',
    'Pakaian & Aksesori': '👕',
    'Perabotan Rumah Tangga': '🛋️',
    'Buku, Alat Tulis, & Peralatan Sekolah': '📚',
    'Hobi, Mainan, & Koleksi': '🧸',
    'Perlengkapan Bayi & Anak': '🍼',
    'Perlengkapan Taman & Outdoor': '🌳',
    'Otomotif & Aksesori': '🚗',
    'Peralatan Kantor & Industri': '💻',
    'Kosmetik & Perawatan Diri': '💄',
  };

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await ApiCategory.getCategories();
      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void updateItemsPerPage() {
    final width = MediaQuery.of(context).size.width;
    int newItemsPerPage;
    if (width >= 1200) {
      newItemsPerPage = 7;
    } else if (width >= 992) {
      newItemsPerPage = 6;
    } else if (width >= 768) {
      newItemsPerPage = 4;
    } else {
      newItemsPerPage = 3;
    }
    if (newItemsPerPage != itemsPerPage) {
      setState(() {
        itemsPerPage = newItemsPerPage;
        page = 0;
      });
    }
  }

  /// Fungsi untuk encode nama kategori agar cocok di URL (ganti spasi jadi -)
  String encodeCategoryName(String input) {
    return input.replaceAll(' ', '-');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (error.isNotEmpty) {
      return Center(child: Text('Error: $error'));
    }

    updateItemsPerPage();

    final maxPage = (categories.length / itemsPerPage).ceil() - 1;
    final startIndex = page * itemsPerPage;
    final visibleCategories = categories.skip(startIndex).take(itemsPerPage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: page > 0 ? () => setState(() => page--) : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: page < maxPage ? () => setState(() => page++) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: visibleCategories.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final kategori = visibleCategories[index];
              final rawName = kategori['nama_kategori'] ?? 'Kategori';
              final displayName = categoryDisplayLabels[rawName] ?? rawName;
              final icon = categoryIcons[displayName] ?? '📦';

              return InkWell(
                onTap: () {
                  // Kirim id_kategori sebagai String ke callback (jika perlu)
                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(kategori['id_kategori'].toString());
                  }

                  // Navigasi ke halaman produk kategori berdasarkan nama kategori (encoded)
                  final encodedName = encodeCategoryName(displayName);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductByCategoryPage(categoryName: encodedName),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(icon, style: TextStyle(fontSize: 28)),
                      SizedBox(height: 6),
                      Text(
                        displayName,
                        style: TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}