import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sv_timestamp/l10n/app_localizations.dart';
import '../models/captured_image.dart';
import '../services/metadata_overlay.dart';

class ImageCard extends StatefulWidget {
  final CapturedImage image;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;

  const ImageCard({
    super.key,
    required this.image,
    this.onTap,
    this.onDelete,
    this.onLongPress,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool _showShareOptions = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  Future<void> _loadImageBytes() async {
    try {
      final file = File(widget.image.imagePath);
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      print('Error loading image bytes: $e');
    }
  }

  Future<void> _shareImage() async {
    try {
      final file = File(widget.image.imagePath);
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.imageFileNotFound ?? 'Image file not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final files = [XFile(file.path)];

      final result = await Share.shareXFiles(
        files,
        text:
            'Captured with SV TimeStamp\n'
            '📍 ${widget.image.timestamp.toLocal().toString()}',
        subject: 'SV TimeStamp Image',
      );

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.imageShared ?? 'Image shared successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)?.failedToShare ?? 'Failed to share'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showShareMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.shareImage ?? 'Share Image',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOptionButton(
                  icon: Icons.share,
                  label: AppLocalizations.of(context)?.share ?? 'Share',
                  color: Colors.blue,
                  onTap: _shareImage,
                ),
                _ShareOptionButton(
                  icon: Icons.copy,
                  label: AppLocalizations.of(context)?.copy ?? 'Copy',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)?.imagePathCopied ?? 'Image path copied to clipboard'),
                      ),
                    );
                  },
                ),
                _ShareOptionButton(
                  icon: Icons.save_alt,
                  label: AppLocalizations.of(context)?.save ?? 'Save',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // Implement save to gallery
                  },
                ),
                _ShareOptionButton(
                  icon: Icons.more_horiz,
                  label: AppLocalizations.of(context)?.more ?? 'More',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _shareImage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image section with fixed height
                SizedBox(
                  height: 220,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Hero(tag: widget.image.id, child: _buildImage()),
                  ),
                ),
                // Metadata overlay
                Expanded(child: MetadataOverlay(image: widget.image)),
              ],
            ),
            // Top-right logo badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.9),
                      Colors.blueAccent.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fallback to icon if logo.png doesn't exist
                    Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    const SizedBox(width: 6),
                    const Text(
                      'SV',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            if (widget.onDelete != null)
              Positioned(
                top: 12,
                left: 12,
                child: _ActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  onTap: widget.onDelete!,
                ),
              ),
            // Share button
            Positioned(
              bottom: 80,
              right: 12,
              child: _ActionButton(
                icon: Icons.share,
                color: Colors.blue,
                onTap: () => _showShareMenu(context),
              ),
            ),
            // Quick share menu
            if (_showShareOptions)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Share Options',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _ShareQuickButton(
                                icon: Icons.message,
                                label: 'Message',
                                onTap: _shareImage,
                              ),
                              _ShareQuickButton(
                                icon: Icons.mail,
                                label: 'Mail',
                                onTap: _shareImage,
                              ),
                              _ShareQuickButton(
                                icon: Icons.photo_library,
                                label: 'Gallery',
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                setState(() => _showShareOptions = false),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      return Image.file(
        File(widget.image.imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                  SizedBox(height: 8),
                  Text(
                    'Loading image...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _ShareOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ShareQuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareQuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
