import 'package:flutter/material.dart';
import '../models/watermark_template.dart';

class TemplatePreview extends StatelessWidget {
  final WatermarkTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApply;
  final bool isSelected;

  const TemplatePreview({
    super.key,
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onApply,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue[100]!, Colors.blue[200]!],
                      ),
                    ),
                    child: _buildWatermarkPreview(),
                  ),
                ),

                // Template info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              template.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (template.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (template.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            template.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.layers, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${template.elements.length} elements',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (onApply != null)
                    _ActionButton(
                      icon: Icons.check,
                      color: Colors.green,
                      onTap: onApply!,
                      tooltip: 'Apply Template',
                    ),
                  if (onEdit != null && !template.isDefault)
                    _ActionButton(
                      icon: Icons.edit,
                      color: Colors.blue,
                      onTap: onEdit!,
                      tooltip: 'Edit Template',
                    ),
                  if (onDelete != null && !template.isDefault)
                    _ActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: onDelete!,
                      tooltip: 'Delete Template',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermarkPreview() {
    return Stack(
      children: template.elements.map((element) {
        if (!element.isVisible) return const SizedBox();

        final position = Offset(
          element.position.dx * 150, // Preview width
          element.position.dy * 150, // Preview height
        );

        return Positioned(
          left: position.dx - 15 * element.scale,
          top: position.dy - 15 * element.scale,
          child: Transform.scale(
            scale: element.scale,
            child: Opacity(
              opacity: element.opacity,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: element.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _buildElementPreview(element),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildElementPreview(WatermarkElement element) {
    switch (element.type) {
      case WatermarkElementType.logo:
        return const Center(
          child: Icon(Icons.image, size: 16, color: Colors.white),
        );
      case WatermarkElementType.timestamp:
        return const Center(
          child: Text(
            '14:30',
            style: TextStyle(fontSize: 8, color: Colors.white),
          ),
        );
      case WatermarkElementType.location:
        return const Center(
          child: Icon(Icons.location_on, size: 12, color: Colors.white),
        );
      case WatermarkElementType.address:
        return const Center(
          child: Icon(Icons.home, size: 12, color: Colors.white),
        );
      case WatermarkElementType.gpsCoordinates:
        return const Center(
          child: Text(
            'GPS',
            style: TextStyle(fontSize: 8, color: Colors.white),
          ),
        );
      case WatermarkElementType.border:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
          ),
        );
      case WatermarkElementType.qrCode:
        return const Center(
          child: Icon(Icons.qr_code, size: 16, color: Colors.white),
        );
      default:
        return const Center(
          child: Text(
            'TXT',
            style: TextStyle(fontSize: 8, color: Colors.white),
          ),
        );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        color: color,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: tooltip,
      ),
    );
  }
}
