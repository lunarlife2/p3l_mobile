import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user = {
    'name': 'Jane Doe',
    'email': 'JaneDoe@gmail.com',
    'phone': '0987654321',
    'username': 'Jane',
    'poin': 2500,
    'photo':
        'https://i.pinimg.com/564x/3a/fb/20/3afb20f568df4f0c1a72edbba7d685ec.jpg'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF51B995),
              width: double.infinity,
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user['photo']),
            ),
            SizedBox(height: 12),
            Text(
              user['name'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Poin : ${user['poin']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
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
                  buildProfileDetail('Name', user['name']),
                  buildProfileDetail('Email', user['email']),
                  buildProfileDetail('Phone', user['phone']),
                  buildProfileDetail('Username', user['username']),
                  SizedBox(height: 20),
                  Divider(),
                  InkWell(
                    onTap: () {
                      // Clear SharedPreferences and navigate to login screen
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF51B995),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Merch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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
