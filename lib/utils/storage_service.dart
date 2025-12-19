import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/captured_image.dart';
import 'metadata_service.dart';

class StorageService extends ChangeNotifier {
  List<CapturedImage> _capturedImages = [];
  List<CapturedImage> get capturedImages => _capturedImages;

  StorageService() {
    _loadImages();
  }

  Future<void> _loadImages() async {
    // In a real app, load from local database
    // For now, we'll use a dummy list
    notifyListeners();
  }

  Future<CapturedImage?> captureImage() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Optionally, you can show a dialog to the user here
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          debugPrint('Location permission denied.');
          return null;
        }
      }

      // Capture image from camera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      if (image == null) return null;

      // Get metadata
      final timestamp = DateTime.now();
      final location = await MetadataService.getCurrentLocation();
      String? address;

      if (location != null) {
        address = await MetadataService.getAddressFromCoordinates(
          location['latitude']!,
          location['longitude']!,
        );
      }

      // Read original image
      final originalBytes = await File(image.path).readAsBytes();

      // Add metadata to image
      final processedBytes = await MetadataService.addMetadataToImage(
        originalBytes,
        timestamp,
        location,
        address,
      );

      // Save processed image
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${timestamp.millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(appDir.path, 'captured_images', fileName);

      await Directory(path.dirname(savedPath)).create(recursive: true);
      await File(savedPath).writeAsBytes(processedBytes);

      // Create captured image object
      final capturedImage = CapturedImage(
        id: timestamp.millisecondsSinceEpoch.toString(),
        imagePath: savedPath,
        timestamp: timestamp,
        location: location,
        address: address,
        additionalData: {'device': 'Mobile', 'app': 'SV TimeStamp'},
      );

      _capturedImages.insert(0, capturedImage);
      notifyListeners();

      return capturedImage;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String id) async {
    _capturedImages.removeWhere((image) => image.id == id);
    notifyListeners();
  }
}
