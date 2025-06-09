import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> signIn(Map<String, dynamic> data) async {
    final List<Map<String, String>> routes = [
      { 'path': '/loginPembeli', 'role': 'pembeli' },
      { 'path': '/loginPenitip', 'role': 'penitip' },
      { 'path': '/loginOrganisasi', 'role': 'organisasi' },
      { 'path': '/loginPegawai', 'role': 'pegawai' },
    ];

    for (final route in routes) {
      try {
        final response = await http.post(
          Uri.parse('${baseUrl}${route['path']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          return { ...result, 'role': route['role'] };
        }
      } catch (e) {
        // handle per-request errors if needed
      }
    }

    // If none succeeded, throw an error
    throw Exception('Login failed: User not found or wrong credentials.');
  }

  static Future<Map<String, dynamic>> register(String username, String password, String email, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }
}
