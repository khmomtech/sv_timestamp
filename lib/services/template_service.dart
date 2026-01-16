import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/watermark_template.dart';

class TemplateService {
  static const String _templatesKey = 'watermark_templates';
  static const String _defaultTemplateKey = 'default_template_id';

  // Get all templates
  Future<List<WatermarkTemplate>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getStringList(_templatesKey);

    List<WatermarkTemplate> allTemplates = [];

    // Add built-in templates
    allTemplates.addAll(_getBuiltInTemplates());

    // Add user templates
    if (templatesJson != null && templatesJson.isNotEmpty) {
      final userTemplates = templatesJson
          .map((json) => WatermarkTemplate.fromMap(jsonDecode(json)))
          .toList();
      allTemplates.addAll(userTemplates);
    }

    // Mark default template
    final defaultTemplateId = prefs.getString(_defaultTemplateKey);
    if (defaultTemplateId != null) {
      for (int i = 0; i < allTemplates.length; i++) {
        if (allTemplates[i].id == defaultTemplateId) {
          allTemplates[i] = allTemplates[i].copyWith(isDefault: true);
        } else {
          allTemplates[i] = allTemplates[i].copyWith(isDefault: false);
        }
      }
    }

    return allTemplates;
  }

  // Get built-in templates
  List<WatermarkTemplate> _getBuiltInTemplates() {
    return [
      WatermarkTemplate(
        id: 'classic',
        name: 'Classic',
        description: 'Simple bottom overlay with all metadata',
        elements: [
          WatermarkElement(
            id: 'logo_classic',
            type: WatermarkElementType.logo,
            imagePath: 'assets/logo.png',
            position: const Offset(0.85, 0.05),
            scale: 0.3,
          ),
          WatermarkElement(
            id: 'timestamp_classic',
            type: WatermarkElementType.timestamp,
            text: 'Time: {time}',
            position: const Offset(0.05, 0.85),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        isBuiltIn: true,
        isDefault: false,
      ),
      WatermarkTemplate(
        id: 'minimal',
        name: 'Minimal',
        description: 'Only logo and timestamp',
        elements: [
          WatermarkElement(
            id: 'logo_minimal',
            type: WatermarkElementType.logo,
            imagePath: 'assets/logo.png',
            position: const Offset(0.9, 0.9),
            scale: 0.2,
            opacity: 0.8,
          ),
          WatermarkElement(
            id: 'timestamp_minimal',
            type: WatermarkElementType.timestamp,
            text: '{date} {time}',
            position: const Offset(0.05, 0.95),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
        isBuiltIn: true,
        isDefault: false,
      ),
    ];
  }

  Future<WatermarkTemplate> saveTemplate(WatermarkTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    List<WatermarkTemplate> templates = [];

    // Get existing templates
    final templatesJson = prefs.getStringList(_templatesKey);
    if (templatesJson != null && templatesJson.isNotEmpty) {
      templates = templatesJson
          .map((json) => WatermarkTemplate.fromMap(jsonDecode(json)))
          .toList();
    }

    // Remove existing template with same id (if not built-in)
    templates.removeWhere((t) => t.id == template.id && !t.isBuiltIn);

    // Add updated template
    final updatedTemplate = template.copyWith(
      updatedAt: DateTime.now(),
      isBuiltIn: false,
    );
    templates.add(updatedTemplate);

    // Save to storage
    final updatedTemplatesJson = templates
        .map((t) => jsonEncode(t.toMap()))
        .toList();
    await prefs.setStringList(_templatesKey, updatedTemplatesJson);

    // If this is the default template, save its ID
    if (template.isDefault) {
      await prefs.setString(_defaultTemplateKey, template.id);
    }

    return updatedTemplate; // ADD THIS LINE
  }

  // Delete template
  Future<void> deleteTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getStringList(_templatesKey);

    if (templatesJson == null) return;

    final templates = templatesJson
        .map((json) => WatermarkTemplate.fromMap(jsonDecode(json)))
        .toList();

    // Only delete non-built-in templates
    templates.removeWhere((t) => t.id == templateId && !t.isBuiltIn);

    // Update storage
    final updatedTemplatesJson = templates
        .map((t) => jsonEncode(t.toMap()))
        .toList();
    await prefs.setStringList(_templatesKey, updatedTemplatesJson);

    // Check if we're deleting the default template
    final defaultTemplateId = prefs.getString(_defaultTemplateKey);
    if (defaultTemplateId == templateId) {
      await prefs.remove(_defaultTemplateKey);
    }
  }

  // Set default template
  Future<void> setDefaultTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultTemplateKey, templateId);
  }

  // Get default template
  Future<WatermarkTemplate?> getDefaultTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultTemplateId = prefs.getString(_defaultTemplateKey);

    if (defaultTemplateId == null) return null;

    final allTemplates = await getTemplates();
    return allTemplates.firstWhere(
      (t) => t.id == defaultTemplateId,
      orElse: () => allTemplates.firstWhere(
        (t) => t.isBuiltIn,
        orElse: () => allTemplates.isNotEmpty
            ? allTemplates.first
            : _getBuiltInTemplates().first,
      ),
    );
  }

  // Duplicate template
  Future<WatermarkTemplate> duplicateTemplate(
    WatermarkTemplate template,
  ) async {
    final newTemplate = WatermarkTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${template.name} (Copy)',
      description: template.description,
      elements: template.elements
          .map(
            (e) => WatermarkElement(
              id: '${e.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
              type: e.type,
              text: e.text,
              imagePath: e.imagePath,
              position: e.position,
              scale: e.scale,
              rotation: e.rotation,
              opacity: e.opacity,
              style: e.style,
              backgroundColor: e.backgroundColor,
              alignment: e.alignment,
              isVisible: e.isVisible,
            ),
          )
          .toList(),
      isBuiltIn: false,
      isDefault: false,
      backgroundColor: template.backgroundColor,
      backgroundOpacity: template.backgroundOpacity,
    );

    await saveTemplate(newTemplate);
    return newTemplate;
  }

  // Create new template
  Future<WatermarkTemplate> createNewTemplate(String name) async {
    final newTemplate = WatermarkTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: '',
      elements: [
        WatermarkElement(
          id: 'logo_${DateTime.now().millisecondsSinceEpoch}',
          type: WatermarkElementType.logo,
          imagePath: 'assets/logo.png',
          position: const Offset(0.5, 0.5),
          scale: 0.5,
        ),
      ],
      isBuiltIn: false,
      isDefault: false,
    );

    await saveTemplate(newTemplate);
    return newTemplate;
  }

  // Clear all user templates
  Future<void> clearAllTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_templatesKey);
    await prefs.remove(_defaultTemplateKey);
  }

  // Import templates from JSON
  Future<void> importTemplates(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final importedTemplates = jsonList
          .map((json) => WatermarkTemplate.fromMap(json))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getStringList(_templatesKey) ?? [];

      // Convert existing templates to maps
      final existingMaps = existingJson
          .map((json) => jsonDecode(json))
          .toList();

      // Add imported templates (skip duplicates)
      for (final template in importedTemplates) {
        if (!existingMaps.any((map) => map['id'] == template.id)) {
          existingMaps.add(template.toMap());
        }
      }

      // Save back
      final updatedJson = existingMaps.map((map) => jsonEncode(map)).toList();
      await prefs.setStringList(_templatesKey, updatedJson);
    } catch (e) {
      throw Exception('Failed to import templates: $e');
    }
  }

  // Export templates to JSON
  Future<String> exportTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getStringList(_templatesKey) ?? [];

    // Convert to list of maps
    final templatesList = templatesJson
        .map((json) => jsonDecode(json))
        .toList();

    return jsonEncode(templatesList);
  }
}
