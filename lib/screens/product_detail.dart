import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- import ini wajib

import 'package:mobile_p3l/services/api_barang.dart';
import 'package:mobile_p3l/services/api_category.dart';
import 'package:mobile_p3l/services/api_penitip.dart';
import 'package:mobile_p3l/services/api_gallery.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({required this.productId, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? product;
  List<dynamic> categories = [];
  List<dynamic> gallery = [];
  Map<String, dynamic>? penitip;
  bool loading = true;
  bool isLoggedIn = false;

  int currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndData();
  }

  Future<void> _initializeLocaleAndData() async {
    await initializeDateFormatting('id_ID', null);  // Inisialisasi locale ID
    _checkLogin();
    await _fetchProductData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkLogin() {
    // TODO: Implementasi cek token shared_preferences atau secure_storage
    setState(() {
      isLoggedIn = true; // sementara true supaya tombol Add to Cart muncul
    });
  }

  Future<void> _fetchProductData() async {
    setState(() {
      loading = true;
    });

    try {
      final allProducts = await ApiBarang.getProducts();

      final selectedProduct = allProducts.firstWhere(
        (p) => p['id_barang'] == widget.productId,
        orElse: () => null,
      );

      if (selectedProduct == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final categoryData = await ApiCategory.getCategories();

      final galleryData = await ApiGallery.getGalleryByBarangId(selectedProduct['id_barang'].toString());

      Map<String, dynamic>? penitipData;
      if (selectedProduct['id_penitip'] != null) {
        int? idPenitipInt;

        if (selectedProduct['id_penitip'] is int) {
          idPenitipInt = selectedProduct['id_penitip'] as int;
        } else if (selectedProduct['id_penitip'] is String) {
          idPenitipInt = int.tryParse(selectedProduct['id_penitip']);
        }

        if (idPenitipInt != null && idPenitipInt > 0) {
          penitipData = await ApiPenitip.getPenitipById(idPenitipInt);
        }
      }

      setState(() {
        product = selectedProduct;
        categories = categoryData;
        gallery = galleryData;
        penitip = penitipData;
        loading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        loading = false;
      });
    }
  }

  String formatTanggalGaransi(String? tanggalString) {
    if (tanggalString == null || tanggalString.isEmpty) return "-";

    final tanggalGaransi = DateTime.tryParse(tanggalString);
    if (tanggalGaransi == null) return "-";

    final tanggalSekarang = DateTime.now();
    if (tanggalGaransi.isBefore(tanggalSekarang)) {
      return "-";
    }

    return DateFormat("dd MMMM yyyy", "id_ID").format(tanggalGaransi);
  }

  String formatHargaBarang(dynamic harga) {
    if (harga == null) return "-";
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(harga);
  }

  String getCategoryName(dynamic categoryId) {
    final cat = categories.firstWhere(
      (cat) => cat['id_kategori'] == categoryId,
      orElse: () => null,
    );
    if (cat != null) {
      return (cat['nama_kategori'] as String).replaceAll('-', ' ');
    }
    return "-";
  }

  Widget buildCarousel() {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,  // persegi sama sisi
          child: PageView.builder(
            controller: _pageController,
            itemCount: gallery.length,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final fotoItem = gallery[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'http://10.0.2.2:8000/storage/FotoBarang/${fotoItem['foto']}',
                  fit: BoxFit.cover,
                  width: 300,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            gallery.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentPageIndex == index ? 12 : 8,
              height: currentPageIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color:
                    currentPageIndex == index ? Colors.blue : Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product!['nama_barang'] ?? "Detail Produk")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gallery.isNotEmpty)
              buildCarousel()
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Tidak ada foto produk.'),
              ),
            const SizedBox(height: 20),
            Text(product!['nama_barang'] ?? '-',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              formatHargaBarang(product!['harga_barang']),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF50B794), // Warna hijau sesuai permintaan
              ),
            ),
            const SizedBox(height: 8),
            Text("Kategori : ${getCategoryName(product!['id_kategori'])}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text("Garansi : ${formatTanggalGaransi(product!['garansi'])}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text('Deskripsi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(product!['deskripsi'] ?? '-'),
            const SizedBox(height: 30),
            if (penitip != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Penitip',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          (penitip!['foto'] != null &&
                                  (penitip!['foto'] as String).isNotEmpty)
                              ? 'http://10.0.2.2:8000/storage/Profile/${penitip!['foto']}'
                              : 'http://10.0.2.2:8000/storage/Profile/default-profile.png',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            penitip!['name'] ?? penitip!['nama'] ?? '-',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                (penitip!['rata_rating'] != null)
                                    ? (penitip!['rata_rating'] as num)
                                        .toStringAsFixed(2)
                                    : '0',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.amber),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 30),
            // Placeholder ProductDiscussion (React punya, Flutter bisa implementasi nanti)
          ],
        ),
      ),
    );
  }
}