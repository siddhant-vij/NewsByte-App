import 'dart:math';

import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }
}

double getHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 - Figma Android Large Height
  return min(inputHeight, (inputHeight / 812.0) * screenHeight);
}

double getWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 - Figma Android Large Width
  return min(inputWidth, (inputWidth / 375.0) * screenWidth);
}

double getRadius(double inputRadius) {
  double screenWidth = SizeConfig.screenWidth;
  double screenHeight = SizeConfig.screenHeight;
  double scaleFactor = min(screenWidth, screenHeight) / 375.0;
  return min(inputRadius, inputRadius * scaleFactor);
}
