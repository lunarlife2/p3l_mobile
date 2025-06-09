import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // untuk contentType di multipart
import 'package:mime/mime.dart'; // untuk deteksi tipe file dari extension
import 'package:shared_preferences/shared_preferences.dart';

class ApiGallery {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // sesuaikan

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeadersJson() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, String>> _getHeadersFormData() async {
    final token = await _getToken();
    return {
      "Content-Type": "multipart/form-data",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Upload foto barang (POST multipart/form-data)
  static Future<dynamic> uploadFotoBarang(File file, String idBarang) async {
    final token = await _getToken();
    final uri = Uri.parse("$baseUrl/Gallery");
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final mimeSplit = mimeType.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        file.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ),
    );
    request.fields['id_barang'] = idBarang;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal upload foto: ${response.body}");
    }
  }

  // Update foto gallery (POST multipart/form-data)
  static Future<dynamic> updateFotoBarang(int id, File file) async {
    final token = await _getToken();
    final uri = Uri.parse("$baseUrl/Gallery/$id");
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final mimeSplit = mimeType.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        file.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal update foto: ${response.body}");
    }
  }

  // Ambil semua foto dari 1 barang
  static Future<List<dynamic>> getGalleryByBarangId(String idBarang) async {
    final headers = await _getHeadersJson();
    final uri = Uri.parse("$baseUrl/Gallery/Barang/$idBarang");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      if (data is List) {
        return data;
      }
      return [];
    } else {
      return []; // kembalikan list kosong jika gagal
    }
  }

  // Hapus foto gallery
  static Future<dynamic> deleteFotoBarang(int id) async {
    final headers = await _getHeadersJson();
    final uri = Uri.parse("$baseUrl/Gallery/$id");
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal hapus foto: ${response.body}");
    }
  }
}