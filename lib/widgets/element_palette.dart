import 'package:flutter/material.dart';
import '../models/watermark_template.dart';

class ElementPalette extends StatefulWidget {
  final Function(WatermarkElementType, {String? customText}) onAddElement;
  final VoidCallback onPickImage;

  const ElementPalette({
    super.key,
    required this.onAddElement,
    required this.onPickImage,
  });

  @override
  State<ElementPalette> createState() => _ElementPaletteState();
}

class _ElementPaletteState extends State<ElementPalette> {
  final Map<WatermarkElementType, Map<String, dynamic>> _elementTypes = {
    WatermarkElementType.logo: {
      'name': 'Logo',
      'icon': Icons.image,
      'color': Colors.blue,
    },
    WatermarkElementType.timestamp: {
      'name': 'Timestamp',
      'icon': Icons.access_time,
      'color': Colors.green,
    },
    WatermarkElementType.location: {
      'name': 'Location',
      'icon': Icons.location_on,
      'color': Colors.red,
    },
    WatermarkElementType.address: {
      'name': 'Address',
      'icon': Icons.home,
      'color': Colors.orange,
    },
    WatermarkElementType.gpsCoordinates: {
      'name': 'GPS Coordinates',
      'icon': Icons.gps_fixed,
      'color': Colors.purple,
    },
    WatermarkElementType.deviceInfo: {
      'name': 'Device Info',
      'icon': Icons.smartphone,
      'color': Colors.teal,
    },
    WatermarkElementType.customText: {
      'name': 'Custom Text',
      'icon': Icons.text_fields,
      'color': Colors.indigo,
    },
    WatermarkElementType.border: {
      'name': 'Border',
      'icon': Icons.border_all,
      'color': Colors.brown,
    },
    WatermarkElementType.qrCode: {
      'name': 'QR Code',
      'icon': Icons.qr_code,
      'color': Colors.cyan,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Add Elements',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // Quick add buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _elementTypes.entries.map((entry) {
              return _ElementTypeButton(
                type: entry.key,
                name: entry.value['name'],
                icon: entry.value['icon'],
                color: entry.value['color'],
                onTap: () {
                  if (entry.key == WatermarkElementType.logo) {
                    widget.onPickImage();
                  } else if (entry.key == WatermarkElementType.customText) {
                    _showCustomTextDialog(entry.key);
                  } else {
                    widget.onAddElement(entry.key);
                  }
                },
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Preset templates
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Templates',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPresetTemplate(
                'Classic Bottom',
                Icons.format_align_center_outlined,
                () => _addPresetTemplate('classic_bottom'),
              ),
              _buildPresetTemplate(
                'Top Right Logo',
                Icons.crop_square,
                () => _addPresetTemplate('top_right_logo'),
              ),
              _buildPresetTemplate(
                'Full Overlay',
                Icons.grid_on,
                () => _addPresetTemplate('full_overlay'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Recent elements
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Text Presets',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: _showCustomTextDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TextPresetButton(
                    text: '© SV TimeStamp',
                    onTap: () => widget.onAddElement(
                      WatermarkElementType.customText,
                      customText: '© SV TimeStamp',
                    ),
                  ),
                  _TextPresetButton(
                    text: 'Captured: {date}',
                    onTap: () => widget.onAddElement(
                      WatermarkElementType.customText,
                      customText: 'Captured: {date}',
                    ),
                  ),
                  _TextPresetButton(
                    text: '📸 {time}',
                    onTap: () => widget.onAddElement(
                      WatermarkElementType.customText,
                      customText: '📸 {time}',
                    ),
                  ),
                  _TextPresetButton(
                    text: '📍 {location}',
                    onTap: () => widget.onAddElement(
                      WatermarkElementType.customText,
                      customText: '📍 {location}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetTemplate(String name, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.blue),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.add, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _addPresetTemplate(String templateType) {
    switch (templateType) {
      case 'classic_bottom':
        widget.onAddElement(WatermarkElementType.logo);
        widget.onAddElement(WatermarkElementType.timestamp);
        widget.onAddElement(WatermarkElementType.location);
        break;
      case 'top_right_logo':
        widget.onAddElement(WatermarkElementType.logo);
        break;
      case 'full_overlay':
        widget.onAddElement(WatermarkElementType.border);
        widget.onAddElement(WatermarkElementType.logo);
        widget.onAddElement(WatermarkElementType.timestamp);
        widget.onAddElement(WatermarkElementType.location);
        widget.onAddElement(WatermarkElementType.gpsCoordinates);
        break;
    }
  }

  void _showCustomTextDialog([WatermarkElementType? type]) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Text'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter custom text...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.onAddElement(
                  type ?? WatermarkElementType.customText,
                  customText: controller.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ElementTypeButton extends StatelessWidget {
  final WatermarkElementType type;
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ElementTypeButton({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextPresetButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _TextPresetButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
