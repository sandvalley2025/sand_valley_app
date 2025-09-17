import 'package:flutter/material.dart';

class Circularimagecontainer extends StatelessWidget {
  const Circularimagecontainer({
    super.key,
    required this.image,
    required this.borderColor,
  });

  final String image;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return circularContainer(image, borderColor); // ✅ pass borderColor
  }
}

Widget circularContainer(String image, Color borderColor) {
  bool isNetwork = image.startsWith('http');

  return Container(
    width: 220,
    height: 220,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 5),
    ),
    child: ClipOval(
      child:
          isNetwork
              ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallbackImage(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xffFFA927)),
                  );
                },
              )
              : Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallbackImage(),
              ),
    ),
  );
}

Widget _fallbackImage() {
  return Container(
    color: Colors.white,
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey,
      size: 60,
    ),
  );
}
