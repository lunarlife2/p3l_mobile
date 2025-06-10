import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_section.dart';
import '../widgets/product_list.dart';
import 'package:mobile_p3l/login.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? role;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    clearPrefsThenLoad(); // Gunakan ini untuk testing
    // loadRole(); // Ganti ke ini jika tidak ingin clear
  }

  Future<void> clearPrefsThenLoad() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data SharedPreferences (testing)
    await loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRole = prefs.getString('role');
    print('DEBUG: Role dari SharedPreferences: $storedRole');

    setState(() {
      role = storedRole;
      _selectedTab = 0;
    });
  }

  void onTabTapped(int index) {
    if (role == null && index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ).then((_) => loadRole());
    } else {
      setState(() {
        _selectedTab = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [];
    List<BottomNavigationBarItem> navItems = [];

    if (role == null) {
      pages = [
        const DashboardContent(),
        const Center(child: Text('Silakan login')),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
      ];
    } else {
      pages = [
        const DashboardContent(),
        if (role == 'pembeli')
          const Center(child: Text('Merch Page (Coming soon)')),
        const ProfilePage(), // Ganti ini dengan halaman profil sungguhan nanti
      ];

      navItems = [
        const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        if (role == 'pembeli')
          const BottomNavigationBarItem(
              icon: Icon(Icons.store), label: 'Merch'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    final clampedTabIndex = _selectedTab.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50B794),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: pages[clampedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF50B794),
        unselectedItemColor: Colors.grey,
        currentIndex: clampedTabIndex,
        onTap: onTabTapped,
        items: navItems,
      ),
    );
  }
}

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

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil logout')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => logout(context),
        child: const Text('Logout'),
      ),
    );
  }
}