import 'package:flutter/material.dart';
import 'package:mobile_p3l/screens/dashboard_screen.dart';  // pastikan path sesuai dengan struktur project kamu
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),  // ganti MyHomePage jadi DashboardScreen
    );
  }
}