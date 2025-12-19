import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:sv_timestamp/utils/emoji_manager.dart';
import '../models/watermark_template.dart';

class MetadataService {
  static Map<String, img.Image> _emojiCache = {};

  // Get GPS Coordinates
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return null;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      print('Getting address for coordinates: $lat, $lng');

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "";

        // Build address gradually
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ", ";
          address += place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ", ";
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ", ";
          address += place.country!;
        }

        print('Address found: $address');
        return address.isNotEmpty ? address : null;
      } else {
        print('No placemarks found for coordinates');
        return null;
      }
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  // Load logo from assets and convert to img.Image
  static Future<img.Image?> loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      return img.decodeImage(bytes);
    } catch (e) {
      print('Error loading logo: $e');
      return null;
    }
  }

  static Future<Uint8List> addMetadataToImage(
    Uint8List originalImage,
    DateTime timestamp,
    Map<String, double>? location,
    String? address,
  ) async {
    return await _legacyAddMetadataToImage(
      originalImage,
      timestamp,
      location,
      address,
    );
  }

  // Initialize emoji cache (call this once at app startup)
  static Future<void> initEmojiCache() async {
    final emojiPaths = {
      '🕘': 'assets/clock_emoji.png',
      '📅': 'assets/calendar_emoji.png',
      '📍': 'assets/location_emoji.png',
      '🏠': 'assets/house_emoji.png',
    };

    for (final entry in emojiPaths.entries) {
      try {
        final file = File(entry.value);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final emojiImage = img.decodeImage(bytes);
          if (emojiImage != null) {
            _emojiCache[entry.key] = img.copyResize(
              emojiImage,
              width: 40,
              height: 40,
            );
          }
        }
      } catch (e) {
        print('Error loading emoji ${entry.key}: $e');
      }
    }
  }

  static Future<Uint8List> _legacyAddMetadataToImage(
    Uint8List originalImage,
    DateTime timestamp,
    Map<String, double>? location,
    String? address,
  ) async {
    img.Image? image = img.decodeImage(originalImage);
    if (image == null) return originalImage;

    // ---- TIME FORMAT ----
    final hour12 = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final amPm = timestamp.hour >= 12 ? 'PM' : 'AM';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final dateText =
        '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}, '
        '${days[timestamp.weekday - 1]}';

    // ---- STYLES (BIG) ----
    const int fontSize = 120; // ⬅ BIG TEXT
    final int lineHeight = (fontSize * 1.4).toInt();
    const int leftMargin = 40;
    const int bottomPadding = 40;

    // ---- LOGO (VERY BIG) ----
    final logoImage = await loadLogoImage();
    final logo = logoImage != null
        ? img.copyResize(logoImage, width: 1200) // ⬅ BIG LOGO
        : null;

    // ---- CALCULATE HEIGHT SAFELY ----
    int textLines = 2; // title + datetime
    if (address != null && address.isNotEmpty) textLines++;
    if (location != null) textLines++;

    final int logoHeight = logo?.height ?? 0;
    final int spacingAfterLogo = logo != null ? 40 : 0;
    final int totalTextHeight = textLines * lineHeight;

    final int totalWatermarkHeight =
        logoHeight + spacingAfterLogo + totalTextHeight;

    // ---- SAFE START Y ----
    int currentY = image.height - totalWatermarkHeight - bottomPadding;

    if (currentY < 20) currentY = 20; // ⬅ clamp to top-safe area

    // ---- DRAW LOGO ----
    if (logo != null) {
      for (int y = 0; y < logo.height; y++) {
        for (int x = 0; x < logo.width; x++) {
          final p = logo.getPixel(x, y);
          if (p.a == 0) continue;

          final tx = leftMargin + x;
          final ty = currentY + y;

          if (tx < 0 || ty < 0 || tx >= image.width || ty >= image.height)
            continue;

          final bg = image.getPixel(tx, ty);
          final a = p.a / 255.0;

          image.setPixelRgba(
            tx,
            ty,
            (p.r * a + bg.r * (1 - a)).toInt(),
            (p.g * a + bg.g * (1 - a)).toInt(),
            (p.b * a + bg.b * (1 - a)).toInt(),
            255,
          );
        }
      }
      currentY += logo.height + spacingAfterLogo;
    }

    // ---- TEXT BLOCK ----
    _drawText(image, 'SV Timestamp', leftMargin, currentY, fontSize);
    currentY += lineHeight;

    final timeText =
        'Datetime: ${hour12.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')} $amPm | $dateText';

    _drawText(image, timeText, leftMargin, currentY, fontSize);
    currentY += lineHeight;

    if (address != null && address.isNotEmpty) {
      _drawText(
        image,
        'Location: ${_truncateSingleLine(address, fontSize, image.width - 100)}',
        leftMargin,
        currentY,
        fontSize,
      );
      currentY += lineHeight;
    }

    if (location != null) {
      final lat = location['latitude']!;
      final lng = location['longitude']!;
      final latH = lat >= 0 ? 'N' : 'S';
      final lngH = lng >= 0 ? 'E' : 'W';

      _drawText(
        image,
        'Lat/Long: ${lat.abs().toStringAsFixed(6)}°$latH, '
        '${lng.abs().toStringAsFixed(6)}°$lngH',
        leftMargin,
        currentY,
        fontSize,
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  static String _truncateSingleLine(String text, int fontSize, int maxWidth) {
    final font = _getFontForSize(fontSize);

    if (_measureTextWidth(text, font) <= maxWidth) return text;

    String result = text;
    while (result.isNotEmpty &&
        _measureTextWidth('$result...', font) > maxWidth) {
      result = result.substring(0, result.length - 1);
    }
    return '$result...';
  }

  // Helper method to measure text width
  static int _measureTextWidth(String text, img.BitmapFont font) {
    int width = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      final charData = font.characters[char];
      if (charData != null) {
        width += charData.xAdvance;
      }
    }
    return width;
  }

  // Keep your existing _drawText method
  static void _drawText(
    img.Image image,
    String text,
    int x,
    int y,
    int fontSize, {
    Color? color,
  }) {
    final font = _getFontForSize(fontSize);

    img.drawString(
      image,
      text,
      font: font,
      x: x,
      y: y,
      color: img.ColorRgb8(
        color?.red ?? 255,
        color?.green ?? 255,
        color?.blue ?? 255,
      ),
    );
  }

  // Update the helper method to support larger font sizes
  static img.BitmapFont _getFontForSize(int fontSize) {
    if (fontSize <= 12) {
      return img.arial14;
    } else if (fontSize <= 18) {
      return img.arial24;
    } else if (fontSize <= 36) {
      return img.arial24;
    } else if (fontSize <= 48) {
      return img.arial48;
    } else if (fontSize <= 72) {
      return img.arial48; // For larger sizes
    } else {
      return img.arial48;
    }
  }
}
