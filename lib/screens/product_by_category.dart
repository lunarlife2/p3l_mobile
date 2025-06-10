import 'package:flutter/material.dart';
import 'package:mobile_p3l/services/api_category.dart';
import 'package:mobile_p3l/services/api_barang.dart';

class ProductByCategoryPage extends StatefulWidget {
  final String categoryName;

  ProductByCategoryPage({required this.categoryName});

  @override
  _ProductByCategoryPageState createState() => _ProductByCategoryPageState();
}

class _ProductByCategoryPageState extends State<ProductByCategoryPage> {
  List<dynamic> products = [];
  List<dynamic> categories = [];
  bool isLoading = true;
  String error = '';

  final String backendBaseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String decodeCategory(String input) {
    return input.replaceAll('-', ' ').replaceAll('&', '&').toLowerCase();
  }

  Future<void> fetchData() async {
    try {
      final fetchedProducts = await ApiBarang.getProducts();
      final fetchedCategories = await ApiCategory.getCategories();

      setState(() {
        products = fetchedProducts;
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal mengambil data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final decodedCategory = decodeCategory(widget.categoryName);

    final category = categories.firstWhere(
      (cat) =>
          (cat['nama_kategori'] as String)
              .replaceAll('-', ' ')
              .toLowerCase() ==
          decodedCategory,
      orElse: () => null,
    );

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF50B794),
          title: const Text('Produk', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF50B794),
          title: const Text('Produk', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(child: Text(error)),
      );
    }

    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF50B794),
          title: const Text('Produk', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: const Center(child: Text('Kategori tidak ditemukan.')),
      );
    }

    final filteredProducts = products.where((product) {
      final status = (product['status'] ?? '').toString().toLowerCase();
      return product['id_kategori'].toString() ==
              category['id_kategori'].toString() &&
          status == 'dijual';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50B794),
        title: Text(
          'Kategori: ${widget.categoryName.replaceAll('-', ' ')}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: filteredProducts.isEmpty
          ? const Center(child: Text('Tidak ada produk untuk kategori ini.'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];

                  final gallery = item['gallery'] as List<dynamic>? ?? [];
                  final photoUrl = gallery.isNotEmpty
                      ? '$backendBaseUrl/storage/FotoBarang/${gallery[0]['foto']}'
                      : (item['foto_barang'] ?? 'https://via.placeholder.com/150');

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/products/${item['id_barang']}');
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1, // Bikin gambar persegi
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_barang'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Rp ${item['harga_barang'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}