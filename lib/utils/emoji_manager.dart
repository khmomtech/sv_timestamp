import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

class EmojiManager {
  static final Map<String, img.Image> _emojiCache = {};
  static bool _isInitialized = false;

  // Initialize all emoji images
  static Future<void> init() async {
    if (_isInitialized) return;

    // Create simple emoji-like icons
    _emojiCache['clock'] = _createClockIcon(40, 40);
    _emojiCache['calendar'] = _createCalendarIcon(40, 40);
    _emojiCache['location'] = _createLocationIcon(40, 40);
    _emojiCache['house'] = _createHouseIcon(40, 40);

    _isInitialized = true;
    print('EmojiManager initialized with ${_emojiCache.length} icons');
  }

  // Create a clock icon
  static img.Image _createClockIcon(int width, int height) {
    // final image = img.Image(width, height, numChannels: 4);
    final image = img.Image(width: width, height: height, numChannels: 4);

    // Fill with transparent
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

    // Draw yellow circle
    final centerX = width ~/ 2;
    final centerY = height ~/ 2;
    final radius = (width ~/ 2) - 4;

    // Draw clock body
    _drawCircle(image, centerX, centerY, radius, Colors.orange);

    // Draw clock hands
    // Hour hand
    _drawLine(
      image,
      centerX,
      centerY,
      centerX,
      centerY - radius ~/ 2,
      Colors.black,
      2,
    );

    // Minute hand
    _drawLine(
      image,
      centerX,
      centerY,
      centerX + radius ~/ 2,
      centerY,
      Colors.black,
      2,
    );

    return image;
  }

  // Create a calendar icon
  static img.Image _createCalendarIcon(int width, int height) {
    final image = img.Image(width: width, height: height, numChannels: 4);

    // Transparent background
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

    // Draw blue rectangle
    final margin = 4;
    final rectWidth = width - margin * 2;
    final rectHeight = height - margin * 2;

    _drawRect(image, margin, margin, rectWidth, rectHeight, Colors.blue);

    // Draw lines for calendar
    // Top date section
    final dateSectionHeight = rectHeight ~/ 3;
    _drawRect(
      image,
      margin,
      margin,
      rectWidth,
      dateSectionHeight,
      Colors.blue[800]!,
    );

    // Draw date number
    _drawTextOnImage(
      image,
      '15',
      margin + rectWidth ~/ 2 - 5,
      margin + dateSectionHeight ~/ 2 + 5,
      Colors.white,
      16,
    );

    return image;
  }

  // Create a location pin icon
  static img.Image _createLocationIcon(int width, int height) {
    final image = img.Image(width: width, height: height, numChannels: 4);

    // Transparent background
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

    final centerX = width ~/ 2;
    final centerY = height ~/ 2;
    final radius = (width ~/ 3);

    // Draw red circle
    _drawCircle(image, centerX, centerY, radius, Colors.red);

    // Draw pointer at bottom
    _drawTriangle(
      image,
      centerX,
      centerY + radius ~/ 2,
      centerX - radius ~/ 2,
      centerY + radius,
      centerX + radius ~/ 2,
      centerY + radius,
      Colors.red,
    );

    return image;
  }

  // Create a house icon
  static img.Image _createHouseIcon(int width, int height) {
    final image = img.Image(width: width, height: height, numChannels: 4);

    // Transparent background
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

    // Draw house body
    final houseWidth = width - 8;
    final houseHeight = height - 8;
    final houseX = 4;
    final houseY = 4;

    // House body
    _drawRect(
      image,
      houseX,
      houseY + houseHeight ~/ 3,
      houseWidth,
      houseHeight * 2 ~/ 3,
      Colors.green,
    );

    // Roof (triangle)
    _drawTriangle(
      image,
      houseX + houseWidth ~/ 2,
      houseY,
      houseX,
      houseY + houseHeight ~/ 3,
      houseX + houseWidth,
      houseY + houseHeight ~/ 3,
      Colors.green[800]!,
    );

    // Door
    _drawRect(
      image,
      houseX + houseWidth ~/ 2 - 4,
      houseY + houseHeight ~/ 2,
      8,
      houseHeight ~/ 3,
      Colors.brown,
    );

    return image;
  }

  // Helper methods for drawing
  static void _drawCircle(
    img.Image image,
    int x,
    int y,
    int radius,
    Color color,
  ) {
    for (int py = y - radius; py <= y + radius; py++) {
      for (int px = x - radius; px <= x + radius; px++) {
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          final dx = px - x;
          final dy = py - y;
          if (dx * dx + dy * dy <= radius * radius) {
            image.setPixel(
              px,
              py,
              img.ColorRgba8(color.red, color.green, color.blue, 255),
            );
          }
        }
      }
    }
  }

  static void _drawRect(
    img.Image image,
    int x,
    int y,
    int width,
    int height,
    Color color,
  ) {
    for (int py = y; py < y + height; py++) {
      for (int px = x; px < x + width; px++) {
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          image.setPixel(
            px,
            py,
            img.ColorRgba8(color.red, color.green, color.blue, 255),
          );
        }
      }
    }
  }

  static void _drawLine(
    img.Image image,
    int x1,
    int y1,
    int x2,
    int y2,
    Color color,
    int thickness,
  ) {
    final dx = (x2 - x1).abs();
    final dy = (y2 - y1).abs();
    final sx = x1 < x2 ? 1 : -1;
    final sy = y1 < y2 ? 1 : -1;
    var err = dx - dy;

    while (true) {
      // Draw pixel with thickness
      for (int t = -thickness ~/ 2; t <= thickness ~/ 2; t++) {
        for (int s = -thickness ~/ 2; s <= thickness ~/ 2; s++) {
          final tx = x1 + s;
          final ty = y1 + t;
          if (tx >= 0 && tx < image.width && ty >= 0 && ty < image.height) {
            image.setPixel(
              tx,
              ty,
              img.ColorRgba8(color.red, color.green, color.blue, 255),
            );
          }
        }
      }

      if (x1 == x2 && y1 == y2) break;
      final e2 = err * 2;
      if (e2 > -dy) {
        err -= dy;
        x1 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y1 += sy;
      }
    }
  }

  static void _drawTriangle(
    img.Image image,
    int x1,
    int y1,
    int x2,
    int y2,
    int x3,
    int y3,
    Color color,
  ) {
    // Simple triangle fill
    final minX = [x1, x2, x3].reduce((a, b) => a < b ? a : b);
    final maxX = [x1, x2, x3].reduce((a, b) => a > b ? a : b);
    final minY = [y1, y2, y3].reduce((a, b) => a < b ? a : b);
    final maxY = [y1, y2, y3].reduce((a, b) => a > b ? a : b);

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        if (_pointInTriangle(x, y, x1, y1, x2, y2, x3, y3)) {
          if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
            image.setPixel(
              x,
              y,
              img.ColorRgba8(color.red, color.green, color.blue, 255),
            );
          }
        }
      }
    }
  }

  static bool _pointInTriangle(
    int px,
    int py,
    int x1,
    int y1,
    int x2,
    int y2,
    int x3,
    int y3,
  ) {
    final area = (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1);
    final s = ((x2 - px) * (y3 - py) - (x3 - px) * (y2 - py)) / area;
    final t = ((x3 - px) * (y1 - py) - (x1 - px) * (y3 - py)) / area;
    return s >= 0 && t >= 0 && 1 - s - t >= 0;
  }

  static void _drawTextOnImage(
    img.Image image,
    String text,
    int x,
    int y,
    Color color,
    int size,
  ) {
    // Simple text drawing (basic implementation)
    final font = size <= 12
        ? img.arial14
        : size <= 18
        ? img.arial24
        : size <= 24
        ? img.arial24
        : img.arial48;

    img.drawString(
      image,
      text,
      font: font,
      x: x,
      y: y,
      color: img.ColorRgba8(color.red, color.green, color.blue, 255),
    );
  }

  // Get emoji image by key
  static img.Image? getEmoji(String key) {
    return _emojiCache[key];
  }

  // Get all available emoji keys
  static List<String> getAvailableEmojis() {
    return _emojiCache.keys.toList();
  }
}
