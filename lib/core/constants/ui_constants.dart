import 'package:flutter/material.dart';

class UIConstants {
  static final UIConstants _instance = UIConstants._internal();

  factory UIConstants() {
    return _instance;
  }

  UIConstants._internal();

  late double screenWidth;
  late double screenHeight;

  void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }
}
