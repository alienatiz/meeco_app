import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode themeMode;
  bool isDark;

  ThemeProvider(
      {String themeModeString = 'ThemeMode.system', this.isDark = false}) {
    switch (themeModeString) {
      case 'ThemeMode.system':
        themeMode = ThemeMode.system;
        break;
      case 'ThemeMode.light':
        themeMode = ThemeMode.light;
        break;
      case 'ThemeMode.dark':
        themeMode = ThemeMode.dark;
    }
  }

  switchTheme(ThemeMode theme) async {
    themeMode = theme;
    isDark = themeMode == ThemeMode.dark;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('themeMode', themeMode.toString());
      prefs.setBool('isDark', isDark);
    });

    notifyListeners();
  }
}
