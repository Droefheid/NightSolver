import 'package:flutter/material.dart';

const COLOR_PRIMARY = Color(0xffab1111);
const COLOR_SECOND = Color(0xffffffff);
const COLOR_ICON = Color(0xff560404);

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light().copyWith(primary: COLOR_PRIMARY),

    iconTheme: IconThemeData(color: COLOR_PRIMARY),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: COLOR_SECOND,
      backgroundColor: COLOR_PRIMARY
    ),





    //############ Elevated Button ##############
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          )
        ),
        //backgroundColor: MaterialStateProperty.all<Color>(COLOR_PRIMARY)
      )
    )
);

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark
);
