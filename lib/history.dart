import 'package:flutter/material.dart';
import 'package:mobile_p3l/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_p3l/merch.dart';
import 'package:mobile_p3l/profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_p3l/detail_pesanan.dart';
import 'package:mobile_p3l/detail_penitipan.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String? role;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    setState(() {});
  }

  List<Widget> get _pages {
    List<Widget> pages = [const HistoryPage()];
    if (role == 'pembeli') {
      pages.add(MerchScreen());
      pages.add(const DashboardContent());
    }
    pages.add(ProfileScreen());
    return pages;
  }

  List<String> get _titles {
    List<String> titles = ['History'];
    if (role == 'pembeli') {
      titles.add('Merch');
      titles.add('Home');
    }
    titles.add('Profile');
    return titles;
  }

  List<BottomNavigationBarItem> get _navItems {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.history), label: 'History'),
    ];
    if (role == 'pembeli') {
      items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.store), label: 'Merch'));
      items.add(
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'));
    }
    items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.person), label: 'Profile'));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == null ? '' : _titles[_selectedIndex]),
        backgroundColor: const Color(0xFF50B794),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: role == null
          ? const Center(child: CircularProgressIndicator())
          : _pages[_selectedIndex],
      bottomNavigationBar: role == null
          ? const SizedBox.shrink()
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF50B794),
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: _navItems,
            ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> statuses = [];
  int _selectedTab = 0;
  List<dynamic> _orders = [];
  String? role;
  int? userId;
  String? token;
  bool _loading = true;
  List<Map<String, dynamic>> _kategori = [];
  List<Map<String, dynamic>> _pegawai = [];

  final String backendBaseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchData();
  }

  Future<void> _loadUserAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    token = prefs.getString('token');
    userId = role == 'pembeli'
        ? prefs.getInt('id_pembeli')
        : prefs.getInt('id_penitip');

    statuses = role == 'pembeli'
        ? ['Proses', 'Selesai', 'Batal']
        : ['DiJual', 'DiDonasikan', 'DiKembalikan', 'DiBeli', 'Kadaluarsa'];

    await _fetchOrders();
    print('Role: $role, Token: $token, UserId: $userId');
  }

  String formatTanggal(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(isoDate));
    } catch (_) {
      return '-';
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
    });

    final url = role == 'pembeli'
        ? '$backendBaseUrl/api/Pembelian/Pembeli/$userId'
        : '$backendBaseUrl/api/PenitipanBarang/Penitip/$userId';

    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      if (role != 'pembeli') {
        // Fetch kategori
        final kategoriRes = await http.get(
          Uri.parse('$backendBaseUrl/api/Kategori'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (kategoriRes.statusCode == 200) {
          final kategoriData = jsonDecode(kategoriRes.body)['data'];
          if (kategoriData is List) {
            _kategori = List<Map<String, dynamic>>.from(kategoriData);
          } else if (kategoriData is Map) {
            _kategori = [Map<String, dynamic>.from(kategoriData)];
          }
        }

        // Fetch pegawai
        final pegawaiRes = await http.get(
          Uri.parse('$backendBaseUrl/api/Pegawai'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (pegawaiRes.statusCode == 200) {
          final pegawaiData = jsonDecode(pegawaiRes.body)['data'];
          if (pegawaiData is List) {
            _pegawai = List<Map<String, dynamic>>.from(pegawaiData);
          } else if (pegawaiData is Map) {
            _pegawai = [Map<String, dynamic>.from(pegawaiData)];
          }
        }
      }

      setState(() {
        _orders = data;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStatus = statuses.isNotEmpty ? statuses[_selectedTab] : '';
    final filteredOrders = _orders.where((order) {
      if (role == 'pembeli') {
        return order['status'] == activeStatus;
      } else {
        return order['status'] == activeStatus;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(statuses.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTab = index;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTab == index
                                  ? const Color(0xFF50B794)
                                  : Colors.white,
                              foregroundColor: _selectedTab == index
                                  ? Colors.white
                                  : const Color(0xFF50B794),
                              side: const BorderSide(color: Color(0xFF50B794)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(statuses[index]),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final detailItems = order['detail__pembelians'] ?? [];
                      String imageUrl = '';

                      if (role == 'pembeli') {
                        if (detailItems.isNotEmpty &&
                            detailItems[0]['gallery'] != null &&
                            detailItems[0]['gallery'] is List &&
                            detailItems[0]['gallery'].isNotEmpty &&
                            detailItems[0]['gallery'][0]['foto'] != null) {
                          final foto = detailItems[0]['gallery'][0]['foto'];
                          imageUrl = '$backendBaseUrl/storage/FotoBarang/$foto';
                        }
                      } else {
                        // final foto = order['gallery'];
                        // print('foto_barang penitip: ${order['gallery']}');
                        if (order['gallery'] != null &&
                            order['gallery'] is List &&
                            order['gallery'].isNotEmpty) {
                          final foto = order['gallery'][0]['foto'];
                          if (foto != null && foto.toString().isNotEmpty) {
                            imageUrl =
                                '$backendBaseUrl/storage/FotoBarang/$foto';
                          }
                        }
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFF50B794)),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(role == 'pembeli'
                                  ? 'Tanggal Pembelian: ${formatTanggal(order['tanggal_pembelian'])}'
                                  : 'Tanggal Penitipan: ${formatTanggal(order['tanggal_penitipan'])}'),
                              const SizedBox(height: 4),
                              Text(role == 'pembeli'
                                  ? 'Tanggal Selesai: ${formatTanggal((order as Map<String, dynamic>)['tanggal_pengiriman-pengambilan'])}'
                                  : 'Kadaluarsa: ${formatTanggal(order['tanggal_kadaluarsa'])}'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.image),
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                                Icons.image_not_supported),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role == 'pembeli'
                                              ? detailItems.isNotEmpty
                                                  ? detailItems[0]
                                                          ['nama_barang'] ??
                                                      '-'
                                                  : '-'
                                              : order['nama_barang'] ?? '-',
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${(role == 'pembeli' ? (detailItems.isNotEmpty ? detailItems[0]['harga_barang'] ?? 0 : 0) : order['harga_barang'] ?? 0)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (role == 'pembeli' &&
                                            detailItems.length > 1)
                                          Text(
                                              '+ ${detailItems.length - 1} produk lainnya'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (role == 'pembeli') ...[
                                const Divider(height: 20, thickness: 1),
                                const Text("Total Belanja",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                Text(
                                  'Rp ${detailItems.fold(0, (sum, item) => sum + (item['harga_barang'] ?? 0))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                              ],
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (role == 'pembeli') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderDetailPage(
                                            orderId: order['id_pembelian']
                                                .toString(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPenitipanPage(
                                            data: order,
                                            kategori: _kategori,
                                            pegawai: _pegawai,
                                            gallery: (order['gallery']
                                                        as List<dynamic>?)
                                                    ?.map((e) => Map<String,
                                                        dynamic>.from(e))
                                                    .toList() ??
                                                [],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF50B794),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(role == 'pembeli'
                                      ? 'Detail Pesanan'
                                      : 'Detail Penitipan'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
