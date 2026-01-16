import 'package:flutter/material.dart';
import '../models/watermark_template.dart';

class WatermarkPreviewOverlay extends StatelessWidget {
  final WatermarkTemplate template;
  final DateTime timestamp;
  final Map<String, double> location;
  final String address;

  const WatermarkPreviewOverlay({
    super.key,
    required this.template,
    required this.timestamp,
    required this.location,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: WatermarkPreviewPainter(
            template: template,
            timestamp: timestamp,
            location: location,
            address: address,
          ),
        ),
      ),
    );
  }
}

class WatermarkPreviewPainter extends CustomPainter {
  final WatermarkTemplate template;
  final DateTime timestamp;
  final Map<String, double> location;
  final String address;

  WatermarkPreviewPainter({
    required this.template,
    required this.timestamp,
    required this.location,
    required this.address,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final element in template.elements) {
      if (!element.isVisible) continue;

      final position = Offset(
        element.position.dx * size.width,
        element.position.dy * size.height,
      );

      _drawElement(canvas, size, element, position, paint);
    }
  }

  void _drawElement(
    Canvas canvas,
    Size size,
    WatermarkElement element,
    Offset position,
    Paint paint,
  ) {
    final textSpan = TextSpan(
      text: _getElementText(element),
      style: TextStyle(
        color: element.style.color ?? Colors.white,
        fontSize: element.style.fontSize ?? 14,
        fontWeight: element.style.fontWeight,
        fontStyle: element.style.fontStyle,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final centeredPosition = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    // Draw background if needed
    if (element.backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = element.backgroundColor.withOpacity(element.opacity)
        ..style = PaintingStyle.fill;

      final backgroundRect = Rect.fromCenter(
        center: position,
        width: textPainter.width + 20,
        height: textPainter.height + 10,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(backgroundRect, Radius.circular(5)),
        backgroundPaint,
      );
    }

    // Draw text with shadow for better visibility
    paint
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    textPainter.paint(canvas, centeredPosition.translate(1, 1));

    paint.color = element.style.color ?? Colors.white;
    textPainter.paint(canvas, centeredPosition);
  }

  String _getElementText(WatermarkElement element) {
    String text = element.text ?? '';

    // Replace placeholders with preview data
    final hour12 = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final amPm = timestamp.hour >= 12 ? 'PM' : 'AM';

    return text
        .replaceAll(
          '{time}',
          '${hour12.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} $amPm',
        )
        .replaceAll(
          '{date}',
          '${timestamp.day}/${timestamp.month}/${timestamp.year}',
        )
        .replaceAll('{timestamp}', timestamp.toLocal().toString())
        .replaceAll(
          '{location}',
          '${location['latitude']?.toStringAsFixed(4)}, ${location['longitude']?.toStringAsFixed(4)}',
        )
        .replaceAll('{address}', address)
        .replaceAll(
          '{latitude}',
          location['latitude']?.toStringAsFixed(4) ?? '0.0000',
        )
        .replaceAll(
          '{longitude}',
          location['longitude']?.toStringAsFixed(4) ?? '0.0000',
        )
        .replaceAll('{device}', 'Preview Device');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
