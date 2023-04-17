import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/utils/color_constant.dart';
import '../theme/app_style.dart';
import '../utils/size_utils.dart';
import 'custom_toast.dart';

class ResetPasswordScreen extends StatefulWidget {

  const ResetPasswordScreen({Key? key})
      : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }


  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      CustomToast.showToast(context, "Password reset email sent. Please check your email to reset your password.");
    } catch (e) {
      CustomToast.showToast(context, "Failed to send password reset email. Please try again.");
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.gray900,
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Padding(
                  padding: getPadding(bottom: 50),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: (){Navigator.pop(context);},
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900, size: getSize(50),)
                      )
                  )
              ),

              ImageIcon(
                AssetImage("assets/logo_foreground.png"),
                size: 100,
                color: ColorConstant.red900,
              ),
              Text("NightSolver", style: AppStyle.txtPoppinsBold30),

              SizedBox(height: getVerticalSize(50),),

              Padding(
                  padding: getPadding(left: 18, top: 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                          TextSpan( children: [
                            TextSpan(text: "Forgot\npassword", style: AppStyle.txtPoppinsBold36),
                            TextSpan(text: "?", style: AppStyle.txtPoppinsBold36Red)
                          ])
                      )
                  )
              ),

              //email input
              Padding(
                  padding: getPadding(all: 16),
                  child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_rounded, color: ColorConstant.red900),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)
                        ),
                        hintText: 'Enter your email address',
                        hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                        fillColor: ColorConstant.gray90001,
                        filled: true,
                      ))),

              Padding(
                  padding: getPadding(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                        TextSpan( children: [
                          TextSpan(
                              text: "*",
                              style: AppStyle.txtPoppinsRegular12
                          ),
                          TextSpan(
                              text: " We will send you an email to reset your password",
                              style: AppStyle.txtPoppinsRegular13
                          )
                        ])
                    )
                  )
              ),

              //sign in button
              GestureDetector(
                onTap: resetPassword,
                child: Container(
                  padding: getPadding(all: 16),
                  margin: getMargin(all: 16),
                  decoration: BoxDecoration(
                      color: ColorConstant.red900,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text('Reset Password',
                          style: AppStyle.txtPoppinsMedium18Grey)),
                ),
              ),



            ]),
          ),
        )));
  }
}
