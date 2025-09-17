import 'package:flutter/material.dart';

Widget roundedRectangle(String text) {
  return Container(
    alignment: Alignment.center,
    width: 260,
    height: 45,
    decoration: BoxDecoration(
      color: const Color(0xFF3B970C),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 29),
    ),
  );
}
