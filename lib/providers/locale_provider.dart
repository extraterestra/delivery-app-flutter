import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('pl'); // Idioma por defecto

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'pl'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'pl') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('pl');
    }
    notifyListeners();
  }
}
