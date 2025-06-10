import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPenitipanPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> kategori;
  final List<Map<String, dynamic>> pegawai;

  final List<Map<String, dynamic>>?
      gallery; // tambahkan ini sebagai optional param

  const DetailPenitipanPage({
    super.key,
    required this.data,
    required this.kategori,
    required this.pegawai,
    this.gallery,
  });

  @override
  Widget build(BuildContext context) {
    // final filteredPegawai =
    //     pegawai.where((p) => p['id_jabatan'] == 'J-1166').toList();

    final bool isKadaluarsa = data['status'] == 'Kadaluarsa';
    final bool isDiKembalikan = data['status'] == 'DiKembalikan';

    Widget buildDisplayRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                "$label:",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            Expanded(
              child: Text(value),
            ),
          ],
        ),
      );
    }

    Widget buildYesNoRow(String label, bool value) {
      return buildDisplayRow(label, value ? "Ya" : "Tidak");
    }

    // String getPegawaiName(dynamic id) {
    //   final peg = filteredPegawai.firstWhere((p) => p['id_pegawai'] == id,
    //       orElse: () => {});
    //   return peg['name'] ?? '-';
    // }

    String getKategoriName(dynamic id) {
      final kat =
          kategori.firstWhere((k) => k['id_kategori'] == id, orElse: () => {});
      return kat['nama_kategori'] ?? '-';
    }

    Widget buildCarousel() {
      final images = gallery ?? [];

      if (images.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('Tidak ada foto produk.'),
        );
      }

      return SizedBox(
        height: 300,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final fotoItem = images[index];
            final fotoUrl = fotoItem['foto'] ?? '';

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'http://10.0.2.2:8000/storage/FotoBarang/$fotoUrl',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            );
          },
        ),
      );
    }

    String formatDate(String? dateString) {
      if (dateString == null) return '-';
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('yyyy-MM-dd').format(date); // atau 'dd MMM yyyy'
      } catch (e) {
        return '-';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF50B794),
        title: const Text('Penitipan Barang',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCarousel(),
            const SizedBox(height: 16),
            buildDisplayRow("Nama Barang", data['nama_barang'] ?? '-'),
            if (isKadaluarsa)
              buildYesNoRow("Di Perpanjang", data['di_perpanjang'] == true),
            buildYesNoRow("Diliver Here", data['diliver_here'] == true),
            buildYesNoRow("Hunter", data['hunter'] == true),
            buildDisplayRow("Status", data['status'] ?? '-'),
            buildDisplayRow("Rating", data['rating']?.toString() ?? '-'),
            buildDisplayRow("Harga", data['harga_barang']?.toString() ?? '-'),
            buildDisplayRow("Kategori", getKategoriName(data['id_kategori'])),
            buildDisplayRow("Deskripsi", data['deskripsi'] ?? '-'),
            buildDisplayRow(
                "Tanggal Penitipan", formatDate(data['tanggal_penitipan'])),
            buildDisplayRow(
                "Tanggal Kadaluarsa", formatDate(data['tanggal_kadaluarsa'])),
            buildDisplayRow("Batas Ambil", formatDate(data['batas_ambil'])),
            buildDisplayRow(
              (isKadaluarsa || isDiKembalikan)
                  ? "Tanggal Diambil"
                  : "Tanggal Laku",
              formatDate(data['tanggal_laku']),
            ),
            buildDisplayRow(
                "Tanggal Rating", formatDate(data['tanggal_rating'])),
            buildDisplayRow("Garansi", formatDate(data['garansi'])),
          ],
        ),
      ),
    );
  }
}
