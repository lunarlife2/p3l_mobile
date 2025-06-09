import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTab = 0;
  String? role;

  List<String> tabs = ['Proses', 'Selesai', 'Batal'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50B794),
        title: const Text('History', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == index
                            ? const Color(0xFF50B794)
                            : Colors.white,
                        side: const BorderSide(color: Color(0xFF50B794)),
                        foregroundColor: _selectedTab == index
                            ? Colors.white
                            : const Color(0xFF50B794),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(tabs[index]),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Order cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF50B794)),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order date : 19 April 2025"),
                        const SizedBox(height: 4),
                        Text("Order Id : PM-1234", style: const TextStyle(fontWeight: FontWeight.bold)),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Image.asset(
                              'assets/fridge.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Samsung Kulkas 2 Pintu 203L | AntiBacterial | Hemat Energi | All around Cooling | RT19M300BGS"),
                                  SizedBox(height: 4),
                                  Text("Rp 8.500.000", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text("+1 produk lainnya"),

                        const Divider(height: 20, thickness: 1),
                        const Text("Total Belanja", style: TextStyle(fontWeight: FontWeight.w600)),
                        const Text("Rp 16.250.000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Detail order navigation
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF50B794),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Detail pesanan"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: role == null
          ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
          : BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF50B794),
              unselectedItemColor: Colors.grey,
              currentIndex: _selectedTab,
              onTap: (index) {
                // handle page switching here
              },
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                if (role == 'pembeli')
                  const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Merch'),
                const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
    );
  }
}
