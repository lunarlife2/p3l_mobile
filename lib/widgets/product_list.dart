import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_p3l/services/api_barang.dart';
import 'package:mobile_p3l/screens/product_detail.dart';  // import halaman detail

class ProductList extends StatefulWidget {
  final String? search;
  final String? categoryId;

  ProductList({this.search, this.categoryId});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<dynamic> products = [];
  bool isLoading = true;
  String error = '';
  String? role;

  final String backendBaseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    loadRole();
    fetchProducts();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  Future<void> fetchProducts() async {
    try {
      final data = await ApiBarang.getProducts();
      setState(() {
        if (widget.categoryId != null) {
          products = data
              .where((p) => p['kategori_barang_id'] == widget.categoryId)
              .toList();
        } else {
          products = data;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) return Center(child: Text('Error: $error'));
    if (products.isEmpty) return Center(child: Text('Tidak ada produk'));

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = products[index];
          final gallery = item['gallery'] as List<dynamic>?;
          String? foto;
          if (gallery != null && gallery.isNotEmpty) {
            foto = gallery[0]['foto'];
          }

          final imageUrl = (foto != null && foto.isNotEmpty)
              ? '$backendBaseUrl/storage/FotoBarang/$foto'
              : null;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(productId: item['id_barang']),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(blurRadius: 4, color: Colors.grey.shade300)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey[600]),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported,
                                  size: 50, color: Colors.grey[600]),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                    child: Text(
                      item['nama_barang'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Rp ${item['harga_barang'] ?? 0}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Spacer(),
                  if (role == 'pembeli')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Add to Cart action
                        },
                        child: Text("Add to Cart"),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}