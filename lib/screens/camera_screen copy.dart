import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sv_timestamp/models/captured_image.dart';
import '../utils/metadata_service.dart';
import '../utils/storage_service.dart';
import '../widgets/image_card.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late StorageService _storageService;
  late List<CameraDescription> _cameras;
  String _currentAddress = "Loading...";
  Map<String, double>? _currentCoords;
  bool _showLocation = true;
  bool _isCapturing = false;
  bool _isCameraReady = false;
  bool _isLocationReady = false;
  double _currentZoom = 1.0;
  FlashMode _currentFlash = FlashMode.off;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _storageService = Provider.of<StorageService>(context, listen: false);
  }

  Future<void> _initApp() async {
    await MetadataService.initEmojiCache();
    await _initLocation();
    await _initializeCamera();
  }

  Future<void> _initLocation() async {
    try {
      final loc = await MetadataService.getCurrentLocation();
      if (loc != null) {
        final addr = await MetadataService.getAddressFromCoordinates(
          loc['latitude']!,
          loc['longitude']!,
        );
        if (mounted) {
          setState(() {
            _currentCoords = loc;
            _currentAddress = addr ?? "Unknown Location";
            _isLocationReady = true;
          });
        }
      } else if (mounted) {
        setState(() {
          _currentAddress = "Location not available";
          _isLocationReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "Location error";
          _isLocationReady = true;
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      // Set initial zoom
      _currentZoom = await _controller!.getMaxZoomLevel() / 2;
      await _controller!.setZoomLevel(_currentZoom);

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        // Show error state
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isCameraReady = false;
    });

    await _controller!.dispose();

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    _controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (mounted) {
      setState(() {
        _isCameraReady = true;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    final modes = [FlashMode.off, FlashMode.auto, FlashMode.always];
    final currentIndex = modes.indexOf(_currentFlash);
    final nextIndex = (currentIndex + 1) % modes.length;

    try {
      await _controller!.setFlashMode(modes[nextIndex]);
      if (mounted) {
        setState(() {
          _currentFlash = modes[nextIndex];
        });
      }
    } catch (e) {
      print('Error setting flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Capture image
      final image = await _controller!.takePicture();

      // Create temporary file path
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Move to temp location
      await File(image.path).copy(tempPath);

      // Prepare metadata
      final timestamp = DateTime.now();
      final metadata = {
        'timestamp': timestamp.toIso8601String(),
        'formatted_time': _getFormattedDateTime(),
        'title': MetadataService.appTitle,
        'address': _showLocation ? _currentAddress : null,
        'latitude': _currentCoords?['latitude'],
        'longitude': _currentCoords?['longitude'],
        'show_location': _showLocation,
      };

      // Process in background
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // Read image bytes
          final originalBytes = await File(tempPath).readAsBytes();

          // Process with MetadataService
          final processedBytes = await MetadataService.addMetadataToImage(
            originalBytes,
            timestamp,
            _currentCoords,
            _showLocation ? _currentAddress : null,
          );

          // Create captured image object
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = '${timestamp.millisecondsSinceEpoch}.jpg';
          final savedPath = path.join(appDir.path, 'captured_images', fileName);

          // Ensure directory exists
          await Directory(path.dirname(savedPath)).create(recursive: true);

          // Save processed image
          await File(savedPath).writeAsBytes(processedBytes);

          // Create and add to storage
          final capturedImage = CapturedImage(
            id: timestamp.millisecondsSinceEpoch.toString(),
            imagePath: savedPath,
            timestamp: timestamp,
            location: _currentCoords,
            address: _showLocation ? _currentAddress : null,
            additionalData: {
              'device': 'Mobile',
              'app': 'SV TimeStamp',
              'flash': _currentFlash.toString(),
              'camera': _cameras[_currentCameraIndex].lensDirection.toString(),
            },
          );

          _storageService.capturedImages.insert(0, capturedImage);

          // Clean up temp file
          await File(tempPath).delete();

          if (mounted) {
            // Show success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image captured successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        } catch (e) {
          print('Error processing image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isCapturing = false;
            });
          }
        }
      });
    } catch (e) {
      print('Capture error: $e');
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Capture failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera Preview
        if (_controller != null && _controller!.value.isInitialized)
          CameraPreview(_controller!),

        // Top Controls
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: _buildTopControls(),
        ),

        // Watermark Overlay
        Positioned(bottom: 140, left: 20, child: _buildWatermark()),

        // Bottom Controls
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: _buildCameraControls(),
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flash Button
            IconButton(
              icon: Icon(
                _currentFlash == FlashMode.off
                    ? Icons.flash_off
                    : _currentFlash == FlashMode.auto
                    ? Icons.flash_auto
                    : Icons.flash_on,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _toggleFlash,
            ),

            // Zoom Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentZoom.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Switch Camera
            IconButton(
              icon: const Icon(
                Icons.cameraswitch,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _cameras.length > 1 ? _switchCamera : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Title
          Text(
            MetadataService.appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
            ),
          ),

          const SizedBox(height: 8),

          // Date and Time
          Text(
            _getFormattedDateTime(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [Shadow(blurRadius: 5, color: Colors.black87)],
            ),
          ),

          // Location (if enabled)
          if (_showLocation && _isLocationReady) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _currentAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black87)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_currentCoords != null)
              Text(
                "Lat/Long: ${_currentCoords!['latitude']!.toStringAsFixed(4)}, "
                "${_currentCoords!['longitude']!.toStringAsFixed(4)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black87)],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Location Toggle
            IconButton(
              icon: Icon(
                _showLocation ? Icons.location_on : Icons.location_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => setState(() => _showLocation = !_showLocation),
            ),

            // Capture Button
            GestureDetector(
              onTap: _isCapturing ? null : _takePicture,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _isCapturing ? 60 : 80,
                width: _isCapturing ? 60 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCapturing ? Colors.grey : Colors.transparent,
                  border: Border.all(
                    color: _isCapturing ? Colors.grey : Colors.white,
                    width: _isCapturing ? 3 : 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: _isCapturing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : const Icon(Icons.camera, color: Colors.white, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraReady
          ? _buildCameraView()
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _initializeCamera();
      }
    }
  }

  String _getFormattedDateTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')} | "
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";
  }
}
