import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_section.dart';
import '../widgets/product_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? role;
  int _selectedTab = 0;

  final List<Widget> _pages = [
    // Halaman utama dashboard (kamu bisa sesuaikan)
    DashboardContent(),

    // Kalau role 'pembeli', bisa isi halaman Merch atau placeholder
    Center(child: Text('Merch Page (Coming soon)')),

    // Profile placeholder
    Center(child: Text('Profile Page (Coming soon)')),
  ];

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50B794),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: role == null
          ? const Center(child: CircularProgressIndicator())
          : _pages[_selectedTab >= _pages.length ? 0 : _selectedTab],
      bottomNavigationBar: role == null
          ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
          : BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF50B794),
              unselectedItemColor: Colors.grey,
              currentIndex: _selectedTab,
              onTap: onTabTapped,
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard), label: 'Dashboard'),
                if (role == 'pembeli')
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.store), label: 'Merch'),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
    );
  }
}

// Extract widget untuk isi halaman Dashboard (biar bersih)
class DashboardContent extends StatelessWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 180,
          child: PageView(
            children: [
              Image.asset('assets/images/hero1.png', fit: BoxFit.cover),
              Image.asset('assets/images/hero2.png', fit: BoxFit.cover),
              Image.asset('assets/images/hero3.png', fit: BoxFit.cover),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CategorySection(),
        const SizedBox(height: 16),
        ProductList(),
      ],
    );
  }
}
