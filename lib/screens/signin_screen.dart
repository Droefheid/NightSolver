import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:night_solver/screens/reset_password_screen.dart';
import 'package:night_solver/theme/app_style.dart';
import 'package:night_solver/utils/color_constant.dart';
import 'package:night_solver/utils/size_utils.dart';

import 'custom_toast.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback showSignUpScreen;

  const SignInScreen({Key? key, required this.showSignUpScreen})
      : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = "An error has occurred";
      if (e.code == 'wrong-password') {
        errorMsg = "The password provided is invalid.";
      } else if (e.code == 'user-not-found') {
        errorMsg = "No user was found for the email address provided.";
      } else if (e.code == 'invalid-email'){
        errorMsg = "The email provided is invalid.";
      }
      CustomToast.showToast(context, errorMsg);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

              ImageIcon(
                AssetImage("assets/logo_foreground.png"),
                size: 100,
                color: ColorConstant.red900,
              ),
              //Text("NightSolver", style: AppStyle.txtPoppinsBold30,),


              SizedBox(height: getVerticalSize(110)),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                      TextSpan( children: [
                        WidgetSpan(child: SizedBox(width: getHorizontalSize(24))), 
                        TextSpan(
                            text: "Welcome ",
                            style: AppStyle.txtPoppinsBold36
                        ), 
                        TextSpan(
                            text: "!", 
                            style: AppStyle.txtPoppinsBold36Red
                        ),
                      ]
                      )
                  )
              ),
              SizedBox(height: getVerticalSize(16)),

              //email input
              Padding(
                  padding: getPadding(all: 16),
                  child: TextField(
                      controller: _emailController,
                      cursorColor: ColorConstant.red900,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_rounded, color: ColorConstant.red900),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorConstant.red900),
                            borderRadius: BorderRadius.circular(16)
                        ),
                        hintText: 'Email',
                        hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                        fillColor: ColorConstant.gray90001,
                        filled: true,
                      ),
                      style: AppStyle.txtPoppinsMedium18,
                  )
              ),

              //password input
              Padding(
                  padding: getPadding(all: 16),
                  child: TextField(
                    controller: _passwordController,
                    cursorColor: ColorConstant.red900,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_rounded, color: ColorConstant.red900),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ColorConstant.red900),
                          borderRadius: BorderRadius.circular(16)
                      ),
                      hintText: 'Password',
                      hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                      fillColor: ColorConstant.gray90001,
                      filled: true,
                    ),
                    style: AppStyle.txtPoppinsMedium18,
                    obscureText: true,
                  )),


              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                      );
                    },
                    child: Text('Forgot Password ?',
                        style: AppStyle.txtPoppinsRegular12
                    ),
                  ),
                  SizedBox(width: getHorizontalSize(16),)
                ],
              ),

              SizedBox(height: getVerticalSize(16),),

              //sign in button
              GestureDetector(
                onTap: signIn,
                child: Container(
                  padding: getPadding(all: 16),
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                      color: ColorConstant.red900,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text(
                          'SIGN IN',
                          style: AppStyle.txtPoppinsMedium18Grey
                      )),
                ),
              ),
              SizedBox(height: getVerticalSize(16),),
              GestureDetector(
                onTap: widget.showSignUpScreen,
                child: Container(
                  padding: getPadding(all: 16),
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                      color: ColorConstant.red900,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text(
                          'REGISTER',
                          style: AppStyle.txtPoppinsMedium18Grey
                      )
                  ),
                ),
              )
            ]),
          ),
        )));
  }
}
