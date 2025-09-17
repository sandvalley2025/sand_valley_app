import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
  await Future.delayed(const Duration(seconds: 2));
  Navigator.pushReplacementNamed(context, '/home');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg-main-screen.png', fit: BoxFit.cover),
          Center(
            child: Image.asset('assets/images/logo.png', width: 180, height: 180),
          ),
        ],
      ),
    );
  }
}
