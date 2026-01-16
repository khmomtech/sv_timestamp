import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class PreviewGenerator {
  static Future<Uint8List> createPreviewBackground() async {
    // Create a 400x600 image (same as your canvas size)
    final image = img.Image(width: 400, height: 600);

    // Create gradient background
    for (int y = 0; y < image.height; y++) {
      final progress = y / image.height;
      final r = (50 + progress * 100).toInt();
      final g = (100 + progress * 80).toInt();
      final b = (150 + progress * 60).toInt();

      for (int x = 0; x < image.width; x++) {
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    // Add some subtle texture
    _addTexture(image);

    // Add grid lines
    _addGridLines(image);

    // Return as JPEG bytes
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  static void _addTexture(img.Image image) {
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        if ((x ~/ 4 + y ~/ 4) % 2 == 0) {
          final pixel = image.getPixel(x, y);
          image.setPixelRgba(
            x,
            y,
            (pixel.r * 0.95).toInt(),
            (pixel.g * 0.95).toInt(),
            (pixel.b * 0.95).toInt(),
            (pixel.b * 0.95).toInt(),
          );
        }
      }
    }
  }

  static void _addGridLines(img.Image image) {
    final gridColor = img.ColorRgb8(255, 255, 255);

    // Vertical lines
    for (int x = 0; x < image.width; x += 40) {
      for (int y = 0; y < image.height; y++) {
        image.setPixel(x, y, gridColor);
      }
    }

    // Horizontal lines
    for (int y = 0; y < image.height; y += 40) {
      for (int x = 0; x < image.width; x++) {
        image.setPixel(x, y, gridColor);
      }
    }
  }
}
