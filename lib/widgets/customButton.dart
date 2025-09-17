import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.icon,
    this.routeName,
    this.buttonColor,
  });

  final Widget icon; // Can be Icon or Image
  final String? routeName;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 35,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        color: buttonColor,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: icon,
      ),
    );
  }
}
