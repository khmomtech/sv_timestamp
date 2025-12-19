import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<ui.Image> loadUiImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

Future<ui.Image?> loadLogoImage() async {
  try {
    final ByteData data = await rootBundle.load('assets/logo.png'); // logo path
    final Uint8List bytes = data.buffer.asUint8List();
    return loadUiImage(bytes);
  } catch (e) {
    print("Error loading logo: $e");
    return null;
  }
}
