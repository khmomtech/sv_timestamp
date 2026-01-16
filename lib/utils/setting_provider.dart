import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('km');
  Locale get currentLocale => _currentLocale;

  void changeLocale(Locale newLocale) {
    _currentLocale = newLocale;
    notifyListeners();
  }
}
