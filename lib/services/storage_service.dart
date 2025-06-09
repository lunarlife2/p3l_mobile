// import 'package:shared_preferences/shared_preferences.dart';

// class StorageService {
//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('authToken', token);
//   }

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('authToken');
//   }

//   static Future<void> clearToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('authToken');
//   }

//   static Future<void> saveRole(String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('authRole', role);
//   }

//   static Future<String?> getRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('authRole');
//   }

//   static Future<void> clearRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('authRole');
//   }
// }
