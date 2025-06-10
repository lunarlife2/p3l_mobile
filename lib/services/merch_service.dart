import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MerchService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getAllMerchandise() async {
    final response = await http.get(Uri.parse('$baseUrl/Merchandise/all'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      throw Exception('Failed to fetch merchandise');
    }
  }

  Future<bool> claimMerch({
    required String itemId,
    required int quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("User not logged in.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/KlaimMerchandise'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_merchandise': itemId,
        'jumlah': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed: ${response.body}");
      return false;
    }
  }
}
