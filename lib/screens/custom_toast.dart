import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:night_solver/utils/color_constant.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final IconData iconData;

  const CustomToast({
    required this.message,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.iconData = Icons.local_movies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: backgroundColor,
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: ColorConstant.redA700,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
              child:Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                ),
              ),
          )

        ],
      ),
    );
  }

  static void showToast(BuildContext context, String message,
      {Color backgroundColor = const Color(0xFF2C2B2B),
        Color textColor = const Color(0xFFFFFFFF),
        double fontSize = 16,
        IconData iconData = Icons.local_movies}) {
    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      child: CustomToast(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
        iconData: iconData,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 3),
    );
  }
}
