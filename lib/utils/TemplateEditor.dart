import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'dart:ui' as ui;
import '../models/watermark_template.dart';

class TemplateEditor extends StatefulWidget {
  final WatermarkTemplate template;
  final Function(WatermarkTemplate) onTemplateUpdated;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const TemplateEditor({
    super.key,
    required this.template,
    required this.onTemplateUpdated,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<TemplateEditor> {
  late WatermarkTemplate _currentTemplate;
  WatermarkElement? _selectedElement;
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentTemplate = widget.template;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Preview
        Expanded(
          child: Container(
            key: _previewKey,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Stack(
              children: [
                // Simulated image background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade900, Colors.grey.shade800],
                    ),
                  ),
                ),

                // Watermark elements
                ..._buildPreviewElements(),

                // Grid overlay
                IgnorePointer(child: CustomPaint(painter: GridPainter())),
              ],
            ),
          ),
        ),

        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Element list
              if (_currentTemplate.elements.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _currentTemplate.elements.map((element) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: ChoiceChip(
                          label: Text(_getElementLabel(element)),
                          selected: _selectedElement?.id == element.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedElement = selected ? element : null;
                            });
                          },
                          avatar: Icon(_getElementIcon(element.type)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 12),

              // Add element buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildAddButton(AppLocalizations.of(context)!.logo, Icons.image, () => _addLogoElement()),
                  _buildAddButton(
                    AppLocalizations.of(context)!.customTextLabel,
                    Icons.text_fields,
                    () => _addTextElement(),
                  ),
                  _buildAddButton(
                    AppLocalizations.of(context)!.timestampLabel,
                    Icons.access_time,
                    () => _addTimestampElement(),
                  ),
                  _buildAddButton(
                    AppLocalizations.of(context)!.locationLabelShort,
                    Icons.location_on,
                    () => _addLocationElement(),
                  ),
                  _buildAddButton(
                    AppLocalizations.of(context)!.gpsCoordinatesLabel,
                    Icons.gps_fixed,
                    () => _addGpsElement(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Selected element controls
              if (_selectedElement != null) _buildElementControls(),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                    label: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onTemplateUpdated(_currentTemplate);
                      widget.onSave();
                    },
                    icon: const Icon(Icons.save),
                    label: Text(AppLocalizations.of(context)!.saveTemplate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPreviewElements() {
    return _currentTemplate.visibleElements.map((element) {
      return Positioned(
        left: element.position.dx,
        top: element.position.dy,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedElement = element;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              final index = _currentTemplate.elements.indexWhere(
                (e) => e.id == element.id,
              );
              if (index != -1) {
                final newElement = element.copyWith(
                  position: element.position + details.delta,
                );
                _currentTemplate = _currentTemplate.copyWith(
                  elements: List.from(_currentTemplate.elements)
                    ..[index] = newElement,
                );
                widget.onTemplateUpdated(_currentTemplate);
              }
            });
          },
          child: Opacity(
            opacity: element.opacity,
            child: Transform.scale(
              scale: element.scale,
              child: Transform.rotate(
                angle: element.rotation,
                child: _buildElementWidget(element),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildElementWidget(WatermarkElement element) {
    switch (element.type) {
      case WatermarkElementType.logo:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: _selectedElement?.id == element.id
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: const Icon(Icons.image, size: 40, color: Colors.white),
        );

      case WatermarkElementType.timestamp:
      case WatermarkElementType.location:
      case WatermarkElementType.gpsCoordinates:
      case WatermarkElementType.address:
      case WatermarkElementType.customText:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: element.backgroundColor.withOpacity(0.3),
            border: _selectedElement?.id == element.id
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Text(
            element.text ?? _getElementDefaultText(element.type),
            style: element.style.copyWith(
              color: element.style.color ?? Colors.white,
            ),
          ),
        );

      default:
        return Container();
    }
  }

  Widget _buildElementControls() {
    final element = _selectedElement!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editing: ${_getElementLabel(element)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Opacity slider
          Row(
            children: [
              const Icon(Icons.opacity, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: element.opacity,
                  onChanged: (value) {
                    _updateSelectedElement(element.copyWith(opacity: value));
                  },
                  min: 0.1,
                  max: 1.0,
                ),
              ),
              Text('${(element.opacity * 100).toInt()}%'),
            ],
          ),

          // Scale slider
          Row(
            children: [
              const Icon(Icons.zoom_in, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: element.scale,
                  onChanged: (value) {
                    _updateSelectedElement(element.copyWith(scale: value));
                  },
                  min: 0.5,
                  max: 2.0,
                ),
              ),
              Text('${(element.scale * 100).toInt()}%'),
            ],
          ),

          // Rotation slider
          Row(
            children: [
              const Icon(Icons.rotate_right, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: element.rotation,
                  onChanged: (value) {
                    _updateSelectedElement(element.copyWith(rotation: value));
                  },
                  min: 0.0,
                  max: 360.0,
                ),
              ),
              Text('${element.rotation.toInt()}°'),
            ],
          ),

          // Color picker for text elements
          if (element.type != WatermarkElementType.logo)
            Row(
              children: [
                const Icon(Icons.color_lens, size: 16),
                const SizedBox(width: 8),
                ...['White', 'Black', 'Red', 'Blue', 'Green'].map((colorName) {
                  Color color;
                  switch (colorName) {
                    case 'Black':
                      color = Colors.black;
                      break;
                    case 'Red':
                      color = Colors.red;
                      break;
                    case 'Blue':
                      color = Colors.blue;
                      break;
                    case 'Green':
                      color = Colors.green;
                      break;
                    default:
                      color = Colors.white;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () {
                        _updateSelectedElement(
                          element.copyWith(
                            style: element.style.copyWith(color: color),
                          ),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: element.style.color == color
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),

          // Delete button
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _currentTemplate = _currentTemplate.copyWith(
                      elements: _currentTemplate.elements
                          .where((e) => e.id != element.id)
                          .toList(),
                    );
                    _selectedElement = null;
                    widget.onTemplateUpdated(_currentTemplate);
                  });
                },
                tooltip: 'Delete Element',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _updateSelectedElement(WatermarkElement updatedElement) {
    setState(() {
      final index = _currentTemplate.elements.indexWhere(
        (e) => e.id == updatedElement.id,
      );
      if (index != -1) {
        _currentTemplate = _currentTemplate.copyWith(
          elements: List.from(_currentTemplate.elements)
            ..[index] = updatedElement,
        );
        _selectedElement = updatedElement;
        widget.onTemplateUpdated(_currentTemplate);
      }
    });
  }

  void _addLogoElement() {
    final newElement = WatermarkElement(
      id: 'logo_${DateTime.now().millisecondsSinceEpoch}',
      type: WatermarkElementType.logo,
      imagePath: 'assets/logo.png',
      position: const Offset(40, 40),
      scale: 1.0,
      opacity: 1.0,
      isVisible: true,
    );

    _addElement(newElement);
  }

  void _addTextElement() {
    final newElement = WatermarkElement(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      type: WatermarkElementType.customText,
      text: 'Custom Text',
      position: const Offset(40, 100),
      scale: 1.0,
      opacity: 1.0,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      isVisible: true,
    );

    _addElement(newElement);
  }

  void _addTimestampElement() {
    final newElement = WatermarkElement(
      id: 'timestamp_${DateTime.now().millisecondsSinceEpoch}',
      type: WatermarkElementType.timestamp,
      position: const Offset(40, 150),
      scale: 1.0,
      opacity: 1.0,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      isVisible: true,
    );

    _addElement(newElement);
  }

  void _addLocationElement() {
    final newElement = WatermarkElement(
      id: 'location_${DateTime.now().millisecondsSinceEpoch}',
      type: WatermarkElementType.location,
      position: const Offset(40, 200),
      scale: 1.0,
      opacity: 1.0,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      isVisible: true,
    );

    _addElement(newElement);
  }

  void _addGpsElement() {
    final newElement = WatermarkElement(
      id: 'gps_${DateTime.now().millisecondsSinceEpoch}',
      type: WatermarkElementType.gpsCoordinates,
      position: const Offset(40, 250),
      scale: 1.0,
      opacity: 1.0,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      isVisible: true,
    );

    _addElement(newElement);
  }

  void _addElement(WatermarkElement element) {
    setState(() {
      _currentTemplate = _currentTemplate.copyWith(
        elements: [..._currentTemplate.elements, element],
      );
      _selectedElement = element;
      widget.onTemplateUpdated(_currentTemplate);
    });
  }

  String _getElementLabel(WatermarkElement element) {
    switch (element.type) {
      case WatermarkElementType.logo:
        return 'Logo';
      case WatermarkElementType.timestamp:
        return 'Timestamp';
      case WatermarkElementType.location:
        return 'Location';
      case WatermarkElementType.gpsCoordinates:
        return 'GPS';
      case WatermarkElementType.address:
        return 'Address';
      case WatermarkElementType.customText:
        return element.text ?? 'Text';
      default:
        return 'Element';
    }
  }

  String _getElementDefaultText(WatermarkElementType type) {
    switch (type) {
      case WatermarkElementType.timestamp:
        return '12:00 PM | 1 Jan 2024, Mon';
      case WatermarkElementType.location:
        return 'Location: New York, USA';
      case WatermarkElementType.gpsCoordinates:
        return 'GPS: 40.7128°N, 74.0060°W';
      case WatermarkElementType.address:
        return '123 Main Street, New York';
      default:
        return 'Text';
    }
  }

  IconData _getElementIcon(WatermarkElementType type) {
    switch (type) {
      case WatermarkElementType.logo:
        return Icons.image;
      case WatermarkElementType.timestamp:
        return Icons.access_time;
      case WatermarkElementType.location:
        return Icons.location_on;
      case WatermarkElementType.gpsCoordinates:
        return Icons.gps_fixed;
      case WatermarkElementType.address:
        return Icons.home;
      case WatermarkElementType.customText:
        return Icons.text_fields;
      default:
        return Icons.widgets;
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
