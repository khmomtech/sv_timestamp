import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';

enum WatermarkElementType {
  logo,
  timestamp,
  location,
  address,
  customText,
  gpsCoordinates,
  deviceInfo,
  border,
  qrCode,
}

class WatermarkElement {
  final String id;
  final WatermarkElementType type;
  final String? text;
  final String? imagePath;
  final Offset position;
  final double scale;
  final double rotation;
  final double opacity;
  final TextStyle style;
  final Color backgroundColor;
  final Alignment alignment;
  final bool isVisible;

  const WatermarkElement({
    required this.id,
    required this.type,
    this.text,
    this.imagePath,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    TextStyle? style,
    this.backgroundColor = Colors.transparent,
    this.alignment = Alignment.center,
    this.isVisible = true,
  }) : style = style ?? const TextStyle(color: Colors.white, fontSize: 14);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'text': text,
      'imagePath': imagePath,
      'position': {'dx': position.dx, 'dy': position.dy},
      'scale': scale,
      'rotation': rotation,
      'opacity': opacity,
      'style': {
        'color': style.color?.value,
        'fontSize': style.fontSize,
        'fontWeight': style.fontWeight?.index,
        'fontStyle': style.fontStyle?.index,
      },
      'backgroundColor': backgroundColor.value,
      'alignment': alignment.x.toString() + ',' + alignment.y.toString(),
      'isVisible': isVisible,
    };
  }

  factory WatermarkElement.fromMap(Map<String, dynamic> map) {
    return WatermarkElement(
      id: map['id'],
      type: WatermarkElementType.values[map['type']],
      text: map['text'],
      imagePath: map['imagePath'],
      position: Offset(
        (map['position'] as Map<String, dynamic>)['dx'],
        (map['position'] as Map<String, dynamic>)['dy'],
      ),
      scale: map['scale'] ?? 1.0,
      rotation: map['rotation'] ?? 0.0,
      opacity: map['opacity'] ?? 1.0,
      style: TextStyle(
        color: map['style']['color'] != null
            ? Color(map['style']['color'])
            : Colors.white,
        fontSize: map['style']['fontSize'] ?? 14.0,
        fontWeight: map['style']['fontWeight'] != null
            ? FontWeight.values[map['style']['fontWeight']]
            : FontWeight.normal,
        fontStyle: map['style']['fontStyle'] != null
            ? FontStyle.values[map['style']['fontStyle']]
            : FontStyle.normal,
      ),
      backgroundColor: map['backgroundColor'] != null
          ? Color(map['backgroundColor'])
          : Colors.transparent,
      alignment: map['alignment'] != null
          ? Alignment(
              double.parse(map['alignment'].split(',')[0]),
              double.parse(map['alignment'].split(',')[1]),
            )
          : Alignment.center,
      isVisible: map['isVisible'] ?? true,
    );
  }

  WatermarkElement copyWith({
    String? id,
    WatermarkElementType? type,
    String? text,
    String? imagePath,
    Offset? position,
    double? scale,
    double? rotation,
    double? opacity,
    TextStyle? style,
    Color? backgroundColor,
    Alignment? alignment,
    bool? isVisible,
  }) {
    return WatermarkElement(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      style: style ?? this.style,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alignment: alignment ?? this.alignment,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class WatermarkTemplate {
  final String id;
  final String name;
  final String description;
  final List<WatermarkElement> elements;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBuiltIn; // NEW FIELD
  final bool isDefault; // NEW FIELD
  final Color backgroundColor;
  final double backgroundOpacity;

  WatermarkTemplate({
    required this.id,
    required this.name,
    this.description = '',
    required this.elements,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isBuiltIn = false,
    this.isDefault = false,
    this.backgroundColor = Colors.transparent,
    this.backgroundOpacity = 0.0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'elements': elements.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isBuiltIn': isBuiltIn,
      'isDefault': isDefault,
      'backgroundColor': backgroundColor.value,
      'backgroundOpacity': backgroundOpacity,
    };
  }

  factory WatermarkTemplate.fromMap(Map<String, dynamic> map) {
    return WatermarkTemplate(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      elements: (map['elements'] as List)
          .map((e) => WatermarkElement.fromMap(e))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isBuiltIn: map['isBuiltIn'] ?? false,
      isDefault: map['isDefault'] ?? false,
      backgroundColor: map['backgroundColor'] != null
          ? Color(map['backgroundColor'])
          : Colors.transparent,
      backgroundOpacity: map['backgroundOpacity'] ?? 0.0,
    );
  }

  WatermarkTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<WatermarkElement>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBuiltIn,
    bool? isDefault,
    Color? backgroundColor,
    double? backgroundOpacity,
  }) {
    return WatermarkTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isDefault: isDefault ?? this.isDefault,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
    );
  }

  // Helper method to check if this is a system/built-in template
  bool get isSystemTemplate => isBuiltIn;

  // Helper method to check if this is the currently selected default template
  bool get isCurrentDefault => isDefault;

  // Get element by ID
  WatermarkElement? getElementById(String elementId) {
    try {
      return elements.firstWhere((element) => element.id == elementId);
    } catch (e) {
      return null;
    }
  }

  // Get elements by type
  List<WatermarkElement> getElementsByType(WatermarkElementType type) {
    return elements.where((element) => element.type == type).toList();
  }

  // Get visible elements
  List<WatermarkElement> get visibleElements =>
      elements.where((element) => element.isVisible).toList();

  // Check if template has any elements of specific type
  bool hasElementType(WatermarkElementType type) {
    return elements.any((element) => element.type == type);
  }

  // Count elements by type
  int countElementsByType(WatermarkElementType type) {
    return elements.where((element) => element.type == type).length;
  }

  // Export to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  // Import from JSON string
  factory WatermarkTemplate.fromJson(String json) {
    return WatermarkTemplate.fromMap(jsonDecode(json));
  }

  @override
  String toString() {
    return 'WatermarkTemplate{id: $id, name: $name, elements: ${elements.length}, isBuiltIn: $isBuiltIn, isDefault: $isDefault}';
  }
}
