import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiPenitip {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // sesuaikan base URL API kamu

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<dynamic> getPenitip({String search = '', int page = 1, int perPage = 7}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse("$baseUrl/Penitip").replace(queryParameters: {
      "search": search,
      "page": page.toString(),
      "per_page": perPage.toString(),
    });
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch Penitip: ${response.body}");
    }
  }

  static Future<dynamic> getPenitipById(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse("$baseUrl/Penitip/$id");
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch Penitip by ID: ${response.body}");
    }
  }

  static Future<dynamic> getAllPenitip() async {
    final headers = await _getHeaders();
    final uri = Uri.parse("$baseUrl/Penitip/all");
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch all Penitip: ${response.body}");
    }
  }

  static Future<dynamic> createPenitip(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final uri = Uri.parse("$baseUrl/Penitip");
    final response = await http.post(uri, headers: headers, body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create Penitip: ${response.body}");
    }
  }

  static Future<dynamic> updatePenitip(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final uri = Uri.parse("$baseUrl/Penitip/$id");
    final response = await http.post(uri, headers: headers, body: jsonEncode(data));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update Penitip: ${response.body}");
    }
  }

  static Future<dynamic> deletePenitip(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse("$baseUrl/Penitip/$id");
    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to delete Penitip: ${response.body}");
    }
  }
}