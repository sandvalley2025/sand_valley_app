import 'package:flutter/material.dart';

class BackgroundOrange extends StatelessWidget {
  final Widget child;

  const BackgroundOrange({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/bg-main-screen.png', fit: BoxFit.cover),
        Container(
          color: Colors.orange.withOpacity(0.1) // 🍊 soft orange overlay
        ),
        child,
      ],
    );
  }
}
