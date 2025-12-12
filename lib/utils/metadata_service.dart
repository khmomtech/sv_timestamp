import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class MetadataService {
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

  // Convert GPS → Address
  static Future<String?> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Create Logo as Image
  static Future<ui.Image> createLogo() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = Size(120, 40);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SV',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  // Add timestamp + GPS + address into image
  static Future<Uint8List> addMetadataToImage(
    Uint8List originalImage,
    DateTime timestamp,
    Map<String, double>? location,
    String? address,
  ) async {
    // Decode image
    img.Image? image = img.decodeImage(originalImage);
    if (image == null) return originalImage;

    // Metadata text
    final metadataText =
        """
SV TimeStamp
${timestamp.toLocal()}
${location != null ? '📍 ${location['latitude']!.toStringAsFixed(4)}, ${location['longitude']!.toStringAsFixed(4)}' : '📍 Location not available'}
${address != null ? '🏠 $address' : ''}
""";

    // Draw metadata text (updated API)
    img.drawString(
      image,
      metadataText,
      font: img.arial24,
      x: 20,
      y: image.height - 140,
      color: img.ColorRgb8(255, 255, 255),
    );

    // Draw Logo "SV"
    img.drawString(
      image,
      'SV',
      font: img.arial48,
      x: image.width - 120,
      y: 20,
      color: img.ColorRgb8(0, 102, 255),
    );

    // Return as JPG bytes
    return Uint8List.fromList(img.encodeJpg(image));
  }
}
