import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  
  /// Font Awesome icon for digits 0-9; null for 10+ (use text instead).
  
  IconData? figureToFontAwesomeIcon(int n, [String? style = 'regular']) {
    switch (n) {
      case 0: return style == 'thin' ? FontAwesomeIcons.thinZero : FontAwesomeIcons.zero;
      case 1: return style == 'thin' ? FontAwesomeIcons.thinOne : FontAwesomeIcons.one;
      case 2: return style == 'thin' ? FontAwesomeIcons.thinTwo : FontAwesomeIcons.two;
      case 3: return style == 'thin' ? FontAwesomeIcons.thinThree : FontAwesomeIcons.three;
      case 4: return style == 'thin' ? FontAwesomeIcons.thinFour : FontAwesomeIcons.four;
      case 5: return style == 'thin' ? FontAwesomeIcons.thinFive : FontAwesomeIcons.five;
      case 6: return style == 'thin' ? FontAwesomeIcons.thinSix : FontAwesomeIcons.six;
      case 7: return style == 'thin' ? FontAwesomeIcons.thinSeven : FontAwesomeIcons.seven;
      case 8: return style == 'thin' ? FontAwesomeIcons.thinEight : FontAwesomeIcons.eight;
      case 9: return style == 'thin' ? FontAwesomeIcons.thinNine : FontAwesomeIcons.nine;
      default: return null;
    }
  }

  List<IconData?> numberToFontAwesomeIcons(int n, [String? style = 'regular']) {
    if (n > 9) {
      final tens = figureToFontAwesomeIcon(n ~/ 10, style);
      final units = figureToFontAwesomeIcon(n % 10, style);
      return [if (tens != null) tens, if (units != null) units];
    }
    final icon = figureToFontAwesomeIcon(n, style);
    return [if (icon != null) icon];
  }