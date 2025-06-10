import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static const String backendBaseUrl = 'http://10.0.2.2:8000';

  Map<String, dynamic>? order;
  File? selectedFile;
  Timer? countdownTimer;
  String timeLeft = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  Future<void> fetchOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = '$backendBaseUrl/api/Pembelian/${widget.orderId}';
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final dataList = body['data'];
        if (dataList == null || dataList.isEmpty) {
          setState(() => isLoading = false);
          return;
        }

        final data = dataList[0];
        setState(() {
          order = data;
          isLoading = false;
        });

        if (data['status'] == "Proses") {
          startCountdown(data['batas_waktu']);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void startCountdown(String deadlineString) {
    final deadline = DateTime.parse(deadlineString);
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = deadline.difference(now);
      if (diff.isNegative) {
        countdownTimer?.cancel();
        setState(() => timeLeft = "Waktu habis!");
        fetchOrder();
      } else {
        setState(() {
          timeLeft =
              "${diff.inHours} jam ${diff.inMinutes % 60} menit ${diff.inSeconds % 60} detik";
        });
      }
    });
  }

  Future<void> pickFile() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedFile = File(picked.path);
      });
    }
  }

  Future<void> uploadBukti() async {
    if (selectedFile == null) return;
    final req = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$backendBaseUrl/api/Pembelian/upload/${order!['id_pembelian']}'),
    );
    req.files
        .add(await http.MultipartFile.fromPath('bukti', selectedFile!.path));
    final res = await req.send();
    if (res.statusCode == 200) {
      fetchOrder();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload berhasil')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload gagal')));
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || order == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF50B794),
          title: const Text('Detail Pesanan',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = order!['detail__pembelians'] as List;
    final status = order!['status'];
    final total = (order!['harga_barang'] ?? 0) -
        (order!['potongan_harga'] ?? 0) +
        (order!['ongkir'] ?? 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF50B794),
        title:
            const Text('Detail Pesanan', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Delivery Address:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(order!['alamat']['alamat'] ?? ''),
            SizedBox(height: 16),
            Text('Orders:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) {
              final gallery = item['gallery'] as List<dynamic>?;
              String? foto;
              if (gallery != null && gallery.isNotEmpty) {
                foto = gallery[0]['foto'];
              }
              final imageUrl = (foto != null && foto.isNotEmpty)
                  ? '$backendBaseUrl/storage/FotoBarang/$foto'
                  : null;

              return Card(
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image);
                          },
                        )
                      : Icon(Icons.image),
                  title: Text(item['nama_barang']),
                  subtitle: Text(item['harga_barang'] != null
                      ? 'Rp ${item['harga_barang']}'
                      : '-'),
                  trailing: item['rating'] != null
                      ? Text("⭐ ${item['rating']}")
                      : status == "selesai"
                          ? ElevatedButton(
                              onPressed: () {
                                // TODO: open rating modal
                              },
                              child: Text("Beri Rating"))
                          : null,
                ),
              );
            }),
            SizedBox(height: 16),
            Text(
                'Shipping Method : ${order!['dilivery'] ? "Delivery" : "Pickup"}'),
            SizedBox(height: 16),
            Text('Order Summary',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Subtotal: ${order!['harga_barang'] != null ? 'Rp ${order!['harga_barang']}' : '-'}'),
            Text('Discount: ${order!['potongan_harga'] != null ? 'Rp ${order!['potongan_harga']}' : '-'}'),
            Text('Delivery Fee: ${order!['ongkir'] != null ? 'Rp ${order!['ongkir']}' : '-'}'),
            Text('Total: Rp $total'),
            SizedBox(height: 16),
            if (status == "Proses") ...[
              Text('Upload Bukti Pembayaran:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: pickFile, child: Text('Pilih File')),
              if (selectedFile != null)
                Text(selectedFile!.path.split('/').last),
            //   ElevatedButton(onPressed: uploadBukti, child: Text('Kirim')),
            // ] else if (order!['bukti_pembayaran'] != null &&
            //     order!['bukti_pembayaran']
            //         .toString()
            //         .startsWith('data:image')) ...[
            //   Text('Bukti pembayaran:'),
            //   Image.memory(
            //     base64Decode(
            //         order!['bukti_pembayaran'].toString().split(',').last),
            //     width: 100,
            //   ),
            // ] else if (order!['bukti_pembayaran'] != null) ...[
            //   Text('Bukti pembayaran (file path):'),
            //   Image.network(
            //     '$backendBaseUrl/storage/BuktiPembayaran/${order!['bukti_pembayaran']}',
            //     width: 100,
            //   ),
            //   Text(order!['bukti_pembayaran']),
            ],
          ],
        ),
      ),
    );
  }
}
