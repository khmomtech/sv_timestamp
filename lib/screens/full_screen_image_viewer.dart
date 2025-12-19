import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/captured_image.dart';

class FullScreenImageViewer extends StatefulWidget {
  final CapturedImage image;

  const FullScreenImageViewer({super.key, required this.image});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(context),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: () => _saveImageToGallery(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showImageDetails(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: FileImage(File(widget.image.imagePath)),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.image.imagePath),
        ),
      ),
    );
  }

  void _shareImage(BuildContext context) async {
    try {
      final file = File(widget.image.imagePath);
      if (await file.exists()) {
        final xFile = XFile(file.path);
        final result = await Share.shareXFiles(
          [xFile],
          subject: 'Image from Gallery',
          text:
              'Image captured at: ${widget.image.timestamp}\n'
              'Location: ${widget.image.location?['latitude']?.toStringAsFixed(4)}, '
              '${widget.image.location?['longitude']?.toStringAsFixed(4)}\n'
              'Address: ${widget.image.address ?? "Not available"}',
        );

        if (result.status == ShareResultStatus.success) {
          _showSnackBar(context, 'Image shared successfully', Colors.green);
        }
      } else {
        _showSnackBar(context, 'Image file not found', Colors.orange);
      }
    } catch (e) {
      _showSnackBar(context, 'Failed to share: $e', Colors.red);
    }
  }

  Future<void> _saveImageToGallery(BuildContext context) async {
    try {
      final file = File(widget.image.imagePath);
      if (await file.exists()) {
        final result = await GallerySaver.saveImage(file.path);

        if (result == true) {
          _showSnackBar(
            context,
            'Image saved to gallery successfully',
            Colors.green,
          );
        } else {
          _showSnackBar(
            context,
            'Failed to save image to gallery',
            Colors.orange,
          );
        }
      } else {
        _showSnackBar(context, 'Image file not found', Colors.orange);
      }
    } on PlatformException catch (e) {
      _showSnackBar(
        context,
        'Permission denied: $e\nPlease grant storage permission',
        Colors.red,
      );
    } catch (e) {
      _showSnackBar(context, 'Failed to save: $e', Colors.red);
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Image'),
              onTap: () {
                Navigator.pop(context);
                _editImage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Details'),
              onTap: () {
                Navigator.pop(context);
                _copyImageDetails(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Image'),
              onTap: () {
                Navigator.pop(context);
                _deleteImage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editImage(BuildContext context) {
    // Implement image editing functionality
    _showSnackBar(context, 'Image editing coming soon', Colors.blue);
  }

  void _copyImageDetails(BuildContext context) async {
    try {
      final details =
          'Image Details:\n'
          'Timestamp: ${widget.image.timestamp}\n'
          'Location: ${widget.image.location?['latitude']}, '
          '${widget.image.location?['longitude']}\n'
          'Address: ${widget.image.address ?? "Not available"}\n'
          'Path: ${widget.image.imagePath}';

      await Clipboard.setData(ClipboardData(text: details));

      _showSnackBar(context, 'Image details copied to clipboard', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Failed to copy: $e', Colors.red);
    }
  }

  void _deleteImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete image file
              final file = File(widget.image.imagePath);
              if (file.existsSync()) {
                file.deleteSync();
              }

              Navigator.pop(context);
              Navigator.pop(context); // Go back to gallery

              _showSnackBar(context, 'Image deleted successfully', Colors.red);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImageDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Image Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              context,
              Icons.access_time,
              'Captured Time',
              widget.image.timestamp.toLocal().toString(),
            ),
            if (widget.image.location != null)
              _buildDetailItem(
                context,
                Icons.location_on,
                'GPS Coordinates',
                '${widget.image.location!['latitude']!.toStringAsFixed(4)}, '
                    '${widget.image.location!['longitude']!.toStringAsFixed(4)}',
              ),
            if (widget.image.address != null)
              _buildDetailItem(
                context,
                Icons.place,
                'Address',
                widget.image.address!,
              ),
            _buildDetailItem(
              context,
              Icons.folder,
              'File Path',
              widget.image.imagePath,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
