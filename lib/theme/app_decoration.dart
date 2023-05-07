import 'package:flutter/material.dart';

import '../utils/color_constant.dart';
import '../utils/size_utils.dart';

class AppDecoration {
  static BoxDecoration get txtFillRedA700 => BoxDecoration(
        color: ColorConstant.redA700,
      );
  static BoxDecoration get fillGray900 => BoxDecoration(
        color: ColorConstant.gray900,
      );
  static BoxDecoration get fillGray800 => BoxDecoration(
        color: ColorConstant.gray800,
      );
  static BoxDecoration get gradientGray900Gray90000 => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(
            0.5,
            1,
          ),
          end: Alignment(
            0.5,
            0.09,
          ),
          colors: [
            ColorConstant.gray900,
            ColorConstant.gray900,
            ColorConstant.gray90000,
          ],
        ),
      );
  static BoxDecoration get fillRedA700 => BoxDecoration(
        color: ColorConstant.redA700,
      );
  static BoxDecoration get fillWhiteA700 => BoxDecoration(
        color: ColorConstant.whiteA700,
      );
  static BoxDecoration get txtFillGray90001 => BoxDecoration(
        color: ColorConstant.gray90001,
      );
}

class BorderRadiusStyle {
  static BorderRadius roundedBorder15 = BorderRadius.circular(
    getHorizontalSize(
      15,
    ),
  );

  static BorderRadius roundedBorder5 = BorderRadius.circular(
    getHorizontalSize(
      5,
    ),
  );

  static BorderRadius txtRoundedBorder5 = BorderRadius.circular(
    getHorizontalSize(
      5,
    ),
  );

  static BorderRadius txtRoundedBorder12 = BorderRadius.circular(
    getHorizontalSize(
      12,
    ),
  );
}

// Comment/Uncomment the below code based on your Flutter SDK version.

// For Flutter SDK Version 3.7.2 or greater.

double get strokeAlignInside => BorderSide.strokeAlignInside;

double get strokeAlignCenter => BorderSide.strokeAlignCenter;

double get strokeAlignOutside => BorderSide.strokeAlignOutside;

// For Flutter SDK Version 3.7.1 or less.

// StrokeAlign get strokeAlignInside => StrokeAlign.inside;
//
// StrokeAlign get strokeAlignCenter => StrokeAlign.center;
//
// StrokeAlign get strokeAlignOutside => StrokeAlign.outside;
