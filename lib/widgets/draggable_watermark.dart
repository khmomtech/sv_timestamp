import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../models/watermark_template.dart';
import '../l10n/app_localizations.dart';

class DraggableWatermark extends StatefulWidget {
  final WatermarkElement element;
  final ValueChanged<WatermarkElement> onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final bool isSelected;
  final Size canvasSize;

  const DraggableWatermark({
    super.key,
    required this.element,
    required this.onUpdate,
    required this.onDelete,
    required this.onSelect,
    required this.isSelected,
    required this.canvasSize,
  });

  @override
  State<DraggableWatermark> createState() => _DraggableWatermarkState();
}

class _DraggableWatermarkState extends State<DraggableWatermark> {
  Offset _position = Offset.zero;
  double _rotation = 0.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _position = widget.element.position;
    _rotation = widget.element.rotation;
    _scale = widget.element.scale;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.element.isVisible) return const SizedBox();

    final actualPosition = Offset(
      _position.dx * widget.canvasSize.width,
      _position.dy * widget.canvasSize.height,
    );

    return Positioned(
      left: actualPosition.dx - 50 * _scale, // Center the handle
      top: actualPosition.dy - 50 * _scale,
      child: GestureDetector(
        onTap: widget.onSelect,
        onPanStart: (_) => widget.onSelect(),
        onPanUpdate: (details) {
          setState(() {
            _position += Offset(
              details.delta.dx / widget.canvasSize.width,
              details.delta.dy / widget.canvasSize.height,
            );
          });
          _updateElement();
        },
        child: Transform(
          transform: Matrix4.identity()
            ..translate(50 * _scale, 50 * _scale)
            ..rotateZ(_rotation)
            ..scale(_scale),
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: widget.isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Watermark content
                Center(child: _buildWatermarkContent()),

                // Controls (only show when selected)
                if (widget.isSelected) ...[
                  // Rotation handle
                  Positioned(
                    top: -30,
                    left: 45,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final center = Offset(50, 50);
                        final touchOffset = Offset(50, -10);
                        final currentAngle = vector.Vector2(
                          touchOffset.dx,
                          touchOffset.dy,
                        ).angleTo(vector.Vector2(1, 0));
                        final newAngle = vector.Vector2(
                          touchOffset.dx + details.delta.dx,
                          touchOffset.dy + details.delta.dy,
                        ).angleTo(vector.Vector2(1, 0));

                        setState(() {
                          _rotation += newAngle - currentAngle;
                        });
                        _updateElement();
                      },
                      child: Container(
                        width: 10,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  // Scale handle
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _scale += details.delta.dy * 0.01;
                          _scale = _scale.clamp(0.1, 3.0);
                        });
                        _updateElement();
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.open_with,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Delete button
                  Positioned(
                    top: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatermarkContent() {
    switch (widget.element.type) {
      case WatermarkElementType.logo:
        return widget.element.imagePath != null
            ? Image.asset(
                widget.element.imagePath!,
                width: 60,
                height: 60,
                color: Colors.white.withOpacity(widget.element.opacity),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(widget.element.opacity),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'SV',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );

      case WatermarkElementType.timestamp:
      case WatermarkElementType.location:
      case WatermarkElementType.address:
      case WatermarkElementType.gpsCoordinates:
      case WatermarkElementType.customText:
      case WatermarkElementType.deviceInfo:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.element.backgroundColor.withOpacity(
              widget.element.opacity * 0.3,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getPreviewText(),
            style: widget.element.style.copyWith(
              color: widget.element.style.color?.withOpacity(
                widget.element.opacity,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        );

      case WatermarkElementType.border:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(widget.element.opacity),
              width: 2,
            ),
          ),
        );

      case WatermarkElementType.qrCode:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(widget.element.opacity),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.qr_code, size: 40, color: Colors.black),
          ),
        );
    }
  }

  String _getPreviewText() {
    switch (widget.element.type) {
      case WatermarkElementType.timestamp:
        return widget.element.text
                ?.replaceAll('{time}', '14:30')
                ?.replaceAll('{date}', '2024-01-15') ??
            AppLocalizations.of(context)!.timestampLabel;
      case WatermarkElementType.location:
        return widget.element.text?.replaceAll('{location}', 'New York, USA') ??
            AppLocalizations.of(context)!.locationLabelShort;
      case WatermarkElementType.address:
        return widget.element.text?.replaceAll('{address}', '123 Main St') ??
            AppLocalizations.of(context)!.addressLabelShort;
      case WatermarkElementType.gpsCoordinates:
        return widget.element.text
                ?.replaceAll('{lat}', '40.7128')
                ?.replaceAll('{lng}', '-74.0060') ??
            AppLocalizations.of(context)!.gpsCoordinatesLabel;
      case WatermarkElementType.deviceInfo:
        return widget.element.text ?? AppLocalizations.of(context)!.deviceInfoLabel;
      case WatermarkElementType.customText:
        return widget.element.text ?? AppLocalizations.of(context)!.customTextLabel;
      default:
        return '';
    }
  }

  void _updateElement() {
    widget.onUpdate(
      widget.element.copyWith(
        position: _position,
        rotation: _rotation,
        scale: _scale,
      ),
    );
  }
}
