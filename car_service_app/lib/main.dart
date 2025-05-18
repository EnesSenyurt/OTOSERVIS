import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const CarServiceApp());
}

class CarServiceApp extends StatelessWidget {
  const CarServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginPage(),
    );
  }
}
