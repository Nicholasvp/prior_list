import 'package:flutter/material.dart';

class NavigationController {
  /// index da tab atual
  final ValueNotifier<int> currentIndex = ValueNotifier(0);

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
  }

  void dispose() {
    currentIndex.dispose();
  }
}