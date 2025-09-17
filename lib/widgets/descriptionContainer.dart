import 'package:flutter/material.dart';

class Descriptioncontainer extends StatelessWidget {
  const Descriptioncontainer({
    super.key,
    required this.text,
    required this.color,
    required this.borderColor,
  });

  final String text;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double targetWidth;

        if (width < 375) {
          targetWidth = 250;
        } else if (width < 425) {
          targetWidth = 300;
        } else if (width < 700) {
          targetWidth = 350;
        } else if (width < 900) {
          targetWidth = 600;
        } else if (width < 1300) {
          targetWidth = 700;
        } else {
          targetWidth = 800;
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: targetWidth,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
              color: color,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        );
      },
    );
  }
}
