import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomWidget2 extends StatelessWidget {
  final String text;
  final String image; // Network or asset path
  final String routeName;
  final Color customColor;
  final Color customBorderColor;
  final Map<String, dynamic>? arguments;

  const CustomWidget2({
    super.key,
    required this.text,
    required this.image,
    required this.routeName,
    required this.arguments,
    required this.customColor,
    required this.customBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    final isNetworkImage = image.toLowerCase().startsWith('http');

    return Container(
      height: 150,
      width: deviceWidth * 0.9,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, routeName, arguments: arguments);
              },
              child: Container(
                width: deviceWidth * 0.8,
                child: Stack(
                  children: [
                    Positioned(
                      left: 50,
                      top: 55,
                      child: _roundedRectangle(text, context),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: customBorderColor,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              isNetworkImage
                                  ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          color: customBorderColor,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                  )
                                  : Image.asset(image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedRectangle(String text, BuildContext context) {
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

    return SizedBox(
      width: targetWidth,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40, maxHeight: 110),
        padding: const EdgeInsets.fromLTRB(46, 8, 20, 8), // Added left padding
        decoration: BoxDecoration(
          color: customColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: AutoSizeText(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          maxLines: 3,
          stepGranularity: 1,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
