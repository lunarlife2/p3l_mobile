// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiCategory {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<dynamic>> getCategories() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/KategoriBarang/all'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Pastikan data['data'] ada dan bertipe List
        if (data['data'] is List) {
          return data['data'];
        } else {
          throw Exception('Data kategori tidak valid');
        }
      } else {
        throw Exception('Gagal ambil kategori: Status code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error kategori: $e');
    }
  }
}