import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> signIn(Map<String, dynamic> data) async {
    final List<Map<String, String>> routes = [
      {'path': '/loginPembeli', 'role': 'pembeli'},
      {'path': '/loginPenitip', 'role': 'penitip'},
      {'path': '/loginOrganisasi', 'role': 'organisasi'},
      {'path': '/loginPegawai', 'role': 'pegawai'},
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

  static Future<Map<String, dynamic>> register(
      String username, String password, String email, String phone) async {
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

  static Future<Map<String, dynamic>> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found.');
    }

    final List<Map<String, String>> routes = [
      {'path': '/logoutPembeli', 'role': 'pembeli'},
      {'path': '/logoutPenitip', 'role': 'penitip'},
      {'path': '/logoutOrganisasi', 'role': 'organisasi'},
      {'path': '/logoutPegawai', 'role': 'pegawai'},
    ];

    for (final route in routes) {
      try {
        final response = await http.post(
          Uri.parse('${baseUrl}${route['path']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);

          // Clear local storage after successful logout
          await prefs.remove('token');
          await prefs.remove('user');
          await prefs.remove('role');

          print("User logged out successfully.");
          return {
            'message': result['message'],
          };
        } else {
          print("Logout failed with status code ${response.statusCode}");
        }
      } catch (e) {
        print("Logout error: $e");
      }
    }
    throw Exception('Logout error.');
  }

  static Future<Map<String, dynamic>> showLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final token = prefs.getString('token');
    String path;

    if (role == null) {
      throw Exception('No role found.');
    } else if (role == 'pembeli') {
      path = '/PembeliData';
    } else if (role == 'penitip') {
      path = '/PenitipData';
    } else if (role == 'organisasi') {
      path = '/OrganisasiData';
    } else if (role == 'pegawai') {
      path = '/PegawaiData';
    } else {
      throw Exception('Invalid role.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        return {
          'message': result['message'],
          'data': result['data'],
        };
      } else {
        print("Get data failed with status code ${response.statusCode}");
        throw Exception('Failed to retrieve data.');
      }
    } catch (e) {
      print("Get user data error: $e");
      throw Exception('Ambil user data error.');
    }
  }
}
