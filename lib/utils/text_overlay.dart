import 'package:flutter/material.dart';

class TextOverlay {
  final String text;
  final Offset position;
  final double fontSize;
  final Color color;

  TextOverlay({
    required this.text,
    required this.position,
    required this.fontSize,
    this.color = Colors.white,
  });
}
