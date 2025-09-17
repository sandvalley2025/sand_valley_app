import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class customLayoutReversed extends StatelessWidget {
  const customLayoutReversed({
    super.key,
    required this.routeName,
    required this.image,
    required this.text,
  });

  final String routeName;
  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 120,
      width: deviceWidth * 0.9,
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: circularBoxReversed(image, text, context, routeName),
            ),
          ),
        ],
      ),
    );
  }
}

Widget circularBoxReversed(
  String image,
  String text,
  BuildContext context,
  String routeName,
) {
  double deviceWidth = MediaQuery.of(context).size.width;
  final isNetworkImage = image.toLowerCase().startsWith('http');

  return SizedBox(
    width: deviceWidth * 0.8,
    child: Stack(
      children: [
        Positioned(
          right: 55,
          top: 55,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, routeName);
            },
            child: roundedRectangle(text, context),
          ),
        ),
        Positioned(
          right: 3,
          top: 2,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, routeName);
            },
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffFFA927),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, routeName);
            },
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // White background
              ),
              child: ClipOval(
                child: isNetworkImage
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff00793F),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget roundedRectangle(String text, BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double screenWidth = MediaQuery.of(context).size.width;

      double targetWidth;
      if (screenWidth < 400) {
        targetWidth = screenWidth * 0.65;
      } else if (screenWidth < 600) {
        targetWidth = screenWidth * 0.70;
      } else if (screenWidth >= 700 && screenWidth <= 900) {
        targetWidth = screenWidth * 0.50;
      } else {
        targetWidth = screenWidth * 0.40;
      }

      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: targetWidth,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50, maxHeight: 120),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B970C),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: AutoSizeText(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              maxLines: 2,
              minFontSize: 16,
              stepGranularity: 1,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    },
  );
}
