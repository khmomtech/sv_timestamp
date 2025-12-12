import 'package:flutter/material.dart';

class TemplateModel with ChangeNotifier {
  bool showTimestamp = true;
  bool showAddress = true;
  bool showCoords = false;
  bool showAltitude = false;
  bool showMap = false; // placeholder for future
  bool showLogo = true;

  void toggleTimestamp() {
    showTimestamp = !showTimestamp;
    notifyListeners();
  }

  void toggleAddress() {
    showAddress = !showAddress;
    notifyListeners();
  }

  void toggleCoords() {
    showCoords = !showCoords;
    notifyListeners();
  }

  void toggleAltitude() {
    showAltitude = !showAltitude;
    notifyListeners();
  }

  void toggleMap() {
    showMap = !showMap;
    notifyListeners();
  }

  void toggleLogo() {
    showLogo = !showLogo;
    notifyListeners();
  }
}
