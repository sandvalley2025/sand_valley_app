import 'package:flutter/material.dart';

class RoundedImageContainer extends StatelessWidget {
  const RoundedImageContainer({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return roundedImageContainer(image);
  }
}

Widget roundedImageContainer(String image) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double screenWidth = MediaQuery.of(context).size.width;
      double targetWidth;

      if (screenWidth >= 320 && screenWidth < 375) {
        targetWidth = screenWidth * 0.65;
      } else if (screenWidth >= 375 && screenWidth < 425) {
        targetWidth = screenWidth * 0.68;
      } else if (screenWidth >= 425 && screenWidth < 700) {
        targetWidth = screenWidth * 0.69;
      } else if (screenWidth >= 700 && screenWidth < 900) {
        targetWidth = screenWidth * 0.67;
      } else if (screenWidth >= 900 && screenWidth < 1300) {
        targetWidth = screenWidth * 0.64;
      } else {
        targetWidth = screenWidth * 0.62;
      }

      return Container(
        width: targetWidth,
        constraints: const BoxConstraints(minHeight: 50, maxHeight: 55),
        decoration: BoxDecoration(
          color: Colors.white, // ✅ White background added here
          borderRadius: BorderRadius.circular(40),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.network(
            image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 30,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Color(0xFF3B970C),
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
