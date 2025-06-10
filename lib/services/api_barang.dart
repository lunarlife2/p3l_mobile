// lib/services/api_barang.dart
import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiBarang {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static final _storage = FlutterSecureStorage();

  // Helper untuk ambil token dari storage
  static Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Helper untuk headers JSON dengan auth token
  static Future<Map<String, String>> _headersJSON() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Ambil semua produk, bisa pakai search
  static Future<List<dynamic>> getProducts({String? search}) async {
    try {
      final queryParameters = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      final uri = Uri.parse('$baseUrl/PenitipanBarang/all').replace(queryParameters: queryParameters);

      final headers = await _headersJSON();

      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['data'] is List) {
          final products = data['data'] as List;

          // Filter produk dengan status 'dijual' (case insensitive)
          return products
              .where((item) =>
                  item['status'] != null &&
                  item['status'].toString().toLowerCase() == 'dijual')
              .toList();
        } else {
          throw Exception('Data produk tidak valid');
        }
      } else {
        throw Exception('Gagal ambil produk: Status code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error produk: $e');
    }
  }

  // Ambil produk berdasarkan id barang
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/PenitipanBarang/$id');
      final headers = await _headersJSON();
      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return null;
      } else {
        throw Exception('Gagal ambil produk: Status code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ambil produk by id: $e');
    }
  }

  // Tambah produk ke keranjang
  static Future<bool> addToCart(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl/Keranjang');
      final headers = await _headersJSON();

      final body = jsonEncode(data);

      final res = await http.post(uri, headers: headers, body: body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        throw Exception('Gagal tambah ke keranjang: Status code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error tambah ke keranjang: $e');
    }
  }

  // Contoh update produk
  static Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl/PenitipanBarang/$id');
      final headers = await _headersJSON();

      final body = jsonEncode(data);

      final res = await http.post(uri, headers: headers, body: body);

      if (res.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal update produk: Status code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error update produk: $e');
    }
  }

  // Contoh hapus produk
  static Future<bool> deleteProduct(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/PenitipanBarang/$id');
      final headers = await _headersJSON();

      final res = await http.delete(uri, headers: headers);

      if (res.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal hapus produk: Status code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error hapus produk: $e');
    }
  }

  // Contoh get produk berdasarkan penitip id
  static Future<List<dynamic>> getProductsByPenitip(String penitipId) async {
    try {
      final uri = Uri.parse('$baseUrl/PenitipanBarang/Penitip/$penitipId');
      final headers = await _headersJSON();

      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          return data['data'];
        }
        return [];
      } else {
        throw Exception('Gagal ambil produk berdasarkan penitip');
      }
    } catch (e) {
      throw Exception('Error ambil produk berdasarkan penitip: $e');
    }
  }

  Future<int?> countPenitipanBarangByHunter(int id) async {
  final url = Uri.parse('$baseUrl/PenitipanBarang/Hunter/count/$id');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final countData = data['data'];

      if (countData == null) {
        print('countData is null');
        return null;
      }

      return countData is int ? countData : int.tryParse(countData.toString());
    } else {
      print('Failed to fetch count: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching count: $e');
    return null;
  }
}

  Future<int?> countTotalKomisiHunter(int id) async {
  final url = Uri.parse('$baseUrl/Komisi/Pegawai/count/$id');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final countData = data['data'];

      if (countData == null) {
        print('countData is null');
        return null;
      }

      return countData is int ? countData : int.tryParse(countData.toString());
    } else {
      print('Failed to fetch count: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching count: $e');
    return null;
  }
}
}