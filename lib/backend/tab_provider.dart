import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabProvider extends ChangeNotifier {
  int _currentIndex;

  int get currentIndex => _currentIndex;

  TabProvider({int initialIndex = 0}) : _currentIndex = initialIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('currentIndex', index);
    });
    notifyListeners();
  }
}
