import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MerchService {
  final String baseUrl = 'https://yourdomain.com/api';

  Future<bool> claimMerch({
    required String itemName,
    required int quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("User not logged in.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/merch/claim'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'item_name': itemName,
        'quantity': quantity,
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
