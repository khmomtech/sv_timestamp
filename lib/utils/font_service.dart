import 'dart:typed_data';
import 'package:flutter/services.dart';

class FontService {
  static final Map<String, bool> _loadedFonts = {};

  static Future<void> loadFont(String fontName, String fontPath) async {
    if (_loadedFonts[fontName] == true) return;

    final ByteData data = await rootBundle.load(fontPath);
    final loader = FontLoader(fontName)..addFont(Future.value(data));

    await loader.load();
    _loadedFonts[fontName] = true;
  }
}
