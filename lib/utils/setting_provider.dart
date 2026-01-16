import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  // Default to Khmer (include country for consistency with other code)
  Locale _currentLocale = const Locale('km', 'KH');
  Locale get currentLocale => _currentLocale;

  void changeLocale(Locale newLocale) {
    _currentLocale = newLocale;
    notifyListeners();
  }
}
