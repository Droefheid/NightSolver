import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color gray90002 = fromHex('#262626');

  static Color gray700 = fromHex('#676767');

  static Color blueGray400 = fromHex('#888888');

  static Color gray800 = fromHex('#414141');

  static Color gray90000 = fromHex('#00111111');

  static Color red900 = fromHex('#990f0f');

  static Color gray900 = fromHex('#111111');

  static Color gray90001 = fromHex('#2a2a2a');

  static Color whiteA70033 = fromHex('#33ffffff');

  static Color black900 = fromHex('#0a0a0a');

  static Color bluegray400 = fromHex('#888888');

  static Color black901 = fromHex('#000000');

  static Color whiteA700 = fromHex('#ffffff');

  static Color redA700 = fromHex('#c30c0c');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
