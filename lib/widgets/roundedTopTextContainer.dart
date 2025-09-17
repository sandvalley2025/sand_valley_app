import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Roundedtoptextcontainer extends StatelessWidget {
  const Roundedtoptextcontainer({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
  return Roundedtoptextcontainerwidget(text,color);
  }
}

Widget Roundedtoptextcontainerwidget(String text, Color color) {
  return Container(
    height: 90,
    width: double.infinity,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Center(
      child: AutoSizeText(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        minFontSize: 13,
        stepGranularity: 1,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    ),
  );
}
