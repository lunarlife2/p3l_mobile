import 'package:flutter/material.dart';
import 'package:mobile_p3l/login.dart';
import 'package:mobile_p3l/screens/dashboard_screen.dart';
import 'package:mobile_p3l/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  int _selectedTab = 0;
  String? role;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadRole();
  }

  Future<void> loadUser() async {
    final prefs = await ApiService.showLoggedInUser();
    final userData = prefs['data'];
    if (userData != null) {
      setState(() {
        user = userData;
        print('user data: $user');
      });
    }
  }

  String getProfileImage(String? role, String? idJabatan) {
    if (role == 'pembeli' || role == 'penitip') {
      return 'assets/images/$role.jpeg';
    } else {
      if (idJabatan == "J-7671") {
      return 'assets/images/kurir.jpeg';
    } else if (idJabatan == "J-6697") {
      return 'assets/images/hunter.jpeg';
    } else {
      return 'assets/images/default_profile.png'; // fallback
    }
  }
    }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F4),
      body: SafeArea(
        child: user == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      getProfileImage(role, user?['id_jabatan']),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    user!['name'] ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  (role == 'pembeli' || role == 'penitip')
                      ? Text(
                          'Poin : ${user!['poin'] ?? 0}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF51B995),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileDetail('Name', user!['name'] ?? ''),
                        buildProfileDetail('Email', user!['email'] ?? ''),
                        buildProfileDetail('Phone', user!['no_telp'] ?? ''),
                        buildProfileDetail('Username', user!['username'] ?? ''),
                        SizedBox(height: 20),
                        Divider(),
                        InkWell(
                          customBorder: Border.all(),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          onTap: () async {
                            await ApiService.logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Logout Successful')),
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const DashboardScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
