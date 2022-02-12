import 'package:flutter/material.dart';

class TabProvider extends ChangeNotifier {
  int _currentIndex;

  int get currentIndex => _currentIndex;

  TabProvider({int initialIndex = 0}) : _currentIndex = initialIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
