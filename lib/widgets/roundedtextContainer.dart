import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Roundedtextcontainer extends StatelessWidget {
  const Roundedtextcontainer({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _roundedtextcontainer(text); // 👈 No SizedBox here
  }
}

Widget _roundedtextcontainer(String text) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double screenWidth = MediaQuery.of(context).size.width;
      double targetWidth;
      double paddingLeft;
      double paddingTop;
      if (screenWidth >= 320 && screenWidth < 375) {
        targetWidth = screenWidth * 0.50;
        paddingTop = 10;
        paddingLeft = 50;
      } else if (screenWidth >= 375 && screenWidth < 425) {
        targetWidth = screenWidth * 0.45;
        paddingTop = 10;
        paddingLeft = 60;
      } else if (screenWidth >= 425 && screenWidth < 700) {
        targetWidth = screenWidth * 0.42;
        paddingTop = 10;
        paddingLeft = 50;
      } else if (screenWidth >= 700 && screenWidth < 900) {
        targetWidth = screenWidth * 0.39;
        paddingTop = 10;
        paddingLeft = 50;
      } else {
        targetWidth = screenWidth * 0.40;
        paddingTop = 10;
        paddingLeft = 60;
      }

      return Container(
        width: targetWidth,
        constraints: const BoxConstraints(minHeight: 55, maxHeight: 65),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: const Color(0xFF3B970C).withValues(alpha: 0.69),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: paddingLeft,
            top: paddingTop,
            right: 0,
          ),
          child: AutoSizeText(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20 , fontWeight: FontWeight.bold),
            maxLines: 2,
            minFontSize: 16,
            stepGranularity: 1,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    },
  );
}
