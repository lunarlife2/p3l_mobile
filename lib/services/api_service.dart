import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

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

          // Save token and user info locally using SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', result['access_token']);
          await prefs.setString('user', jsonEncode(result['user']));
          await prefs.setString('role', route['role']!);

          // Return the result + role info
          return {
            'message': result['message'],
            'user': result['user'],
            'token': result['access_token'],
            'token_type': result['token_type'],
            'role': route['role']
          };
        }
      } catch (e) {
        print("Login error at ${route['path']}: $e");
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

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('role');

    print("User logged out successfully.");
  }
}
