import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController =
      TextEditingController(text: "Jane Doe");
  TextEditingController emailController =
      TextEditingController(text: "JaneDoe@gmail.com");
  TextEditingController phoneController =
      TextEditingController(text: "0987654321");
  TextEditingController usernameController =
      TextEditingController(text: "Jane");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SafeArea(
        child: SingleChildScrollView(
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
                backgroundImage: NetworkImage(
                    'https://i.pinimg.com/564x/3a/fb/20/3afb20f568df4f0c1a72edbba7d685ec.jpg'),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Implement image picker here
                  },
                  child: Text('Change Profile Picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF51B995),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField("Name", nameController),
                      buildTextField("Email", emailController),
                      buildTextField("Phone", phoneController),
                      buildTextField("Username", usernameController),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Save API call
                              // Show success dialog or snackbar
                            }
                          },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF51B995),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF51B995)),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
