import 'dart:io';
import 'dart:math';
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
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'captured_images'));

      if (await imagesDir.exists()) {
        final files = await imagesDir.list().toList();
        final imageFiles = files.whereType<File>().toList();

        _capturedImages = [];

        for (final file in imageFiles) {
          final fileName = path.basename(file.path);
          final timestamp = DateTime.fromMillisecondsSinceEpoch(
            int.parse(fileName.split('.')[0]),
          );

          _capturedImages.add(
            CapturedImage(
              id: timestamp.millisecondsSinceEpoch.toString(),
              imagePath: file.path,
              timestamp: timestamp,
              location: null, // You would need to store this separately
              address: null,
              additionalData: {'loaded_from_storage': true},
            ),
          );
        }

        // Sort by timestamp descending (newest first)
        _capturedImages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading images: $e');
    }
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
        additionalData: {'device': 'Mobile', 'app': 'SV'},
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

  Future<int> getTotalStorageSize() async {
    try {
      int totalSize = 0;

      // Get the directory where images are stored
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'captured_images'));

      // Check if directory exists
      if (await imagesDir.exists()) {
        // List all files in the directory
        final files = await imagesDir.list().toList();

        for (var file in files) {
          if (file is File) {
            try {
              final stat = await file.stat();
              totalSize += stat.size;
            } catch (e) {
              print('Error getting file size for ${file.path}: $e');
            }
          }
        }
      }

      // Also check from capturedImages list for consistency
      for (var image in capturedImages) {
        final file = File(image.imagePath);
        if (await file.exists()) {
          try {
            final stat = await file.stat();
            totalSize += stat.size;
          } catch (e) {
            print('Error getting file size for ${image.imagePath}: $e');
          }
        }
      }

      // Divide by 2 if we counted from both sources
      // This prevents double counting
      return totalSize ~/ 2;
    } catch (e) {
      print('Error calculating storage size: $e');
      return 0;
    }
  }

  /// Delete all captured images from storage and memory
  Future<void> deleteAllImages() async {
    try {
      // Get the directory where images are stored
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'captured_images'));

      // Check if directory exists
      if (await imagesDir.exists()) {
        // Delete all files in the directory
        final files = await imagesDir.list().toList();

        for (var file in files) {
          if (file is File) {
            try {
              await file.delete();
            } catch (e) {
              print('Error deleting file ${file.path}: $e');
            }
          }
        }

        // Optionally, delete the directory itself
        // await imagesDir.delete(recursive: true);
      }

      // Clear the in-memory list
      capturedImages.clear();

      // Optional: Clear any thumbnail cache if you have it
      _clearThumbnailCache();
    } catch (e) {
      print('Error deleting all images: $e');
      throw Exception('Failed to delete all images: $e');
    }
  }

  /// Helper method to clear thumbnail cache if you have one
  void _clearThumbnailCache() {
    // If you're caching thumbnails, clear them here
    // Example:
    // _thumbnailCache.clear();
  }

  /// Alternative: Delete images one by one from capturedImages list
  Future<void> deleteAllImagesFromList() async {
    try {
      // Make a copy of the list to avoid modification during iteration
      final imagesToDelete = List<CapturedImage>.from(capturedImages);

      for (var image in imagesToDelete) {
        try {
          // Delete the file
          final file = File(image.imagePath);
          if (await file.exists()) {
            await file.delete();
          }

          // Remove from list
          capturedImages.removeWhere((img) => img.id == image.id);
        } catch (e) {
          print('Error deleting image ${image.id}: $e');
          // Continue with next image even if one fails
        }
      }
    } catch (e) {
      print('Error in deleteAllImagesFromList: $e');
      throw Exception('Failed to delete images: $e');
    }
  }

  /// Get formatted storage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final totalSize = await getTotalStorageSize();
      final imageCount = capturedImages.length;

      return {
        'totalSize': totalSize,
        'formattedSize': _formatBytes(totalSize),
        'imageCount': imageCount,
        'averageSize': imageCount > 0 ? totalSize ~/ imageCount : 0,
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {
        'totalSize': 0,
        'formattedSize': '0 B',
        'imageCount': 0,
        'averageSize': 0,
      };
    }
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
