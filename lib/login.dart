import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'history.dart'; // pastikan MainPage ada di sini

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login UI',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('[DEBUG] Login request started...');
        final result = await ApiService.signIn({
          'username': usernameController.text,
          'password': passwordController.text,
        });

        print('[DEBUG] Login success. Response: $result');

        final prefs = await SharedPreferences.getInstance();

        final role = result['role'];
        final token = result['token'];
        final user = result['user'];

        print('[DEBUG] Saving role and token...');
        await prefs.setString('role', role);
        await prefs.setString('token', token);

        if (role == 'pembeli') {
          if (user.containsKey('id_pembeli')) {
            final idPembeli = int.tryParse(user['id_pembeli'].toString());
            if (idPembeli != null) {
              print('[DEBUG] Saving id_pembeli: $idPembeli');
              await prefs.setInt('id_pembeli', idPembeli);
            } else {
              print('[ERROR] id_pembeli is not a valid integer!');
            }
          }
        } else {
          if (user.containsKey('id_penitip')) {
            final idPenitip = int.tryParse(user['id_penitip'].toString());
            if (idPenitip != null) {
              print('[DEBUG] Saving id_penitip: $idPenitip');
              await prefs.setInt('id_penitip', idPenitip);
            } else {
              print('[ERROR] id_penitip is not a valid integer!');
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        print('[DEBUG] Navigating to MainPage...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } catch (e, stacktrace) {
        print('[ERROR] Login failed: $e');
        print('[STACKTRACE] $stacktrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF4DB690),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Expanded(child: SizedBox()),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4DB690),
                              ),
                            ),
                            const SizedBox(height: 30),
                            buildLabel('Username'),
                            buildTextFormField(
                              controller: usernameController,
                              icon: Icons.person,
                              hint: 'Username',
                              obscure: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            buildLabel('Password'),
                            buildTextFormField(
                              controller: passwordController,
                              icon: Icons.lock,
                              hint: 'Password',
                              obscure: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4DB690),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget buildLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );
}

Widget buildTextFormField({
  required TextEditingController controller,
  required IconData icon,
  required String hint,
  required bool obscure,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4DB690)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4DB690)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4DB690), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
