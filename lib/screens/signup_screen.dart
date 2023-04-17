import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:night_solver/utils/color_constant.dart';
import 'package:night_solver/utils/size_utils.dart';

import '../theme/app_style.dart';
import 'custom_toast.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback showSignInScreen;

  const SignUpScreen({Key? key, required this.showSignInScreen})
      : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future signUp() async {
    String username = _usernameController.text.trim();
    FirebaseFirestore fInstance = FirebaseFirestore.instance;

    // Check if username is unique
    QuerySnapshot querySnapshot = await fInstance
        .collection('users')
        .where('displayName', isEqualTo: username)
        .get();
    if (querySnapshot.docs.length > 0) {
      CustomToast.showToast(context, "This username is already taken");
    }else if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {

      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());

        await credential.user?.updateDisplayName(_usernameController.text.trim());
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({'displayName' : _usernameController.text.trim()}, SetOptions(merge : true));

      } on FirebaseAuthException catch (e) {
        String errorMsg = "An error has occurred";
        if (e.code == 'weak-password') {
          errorMsg = "The password provided is too weak.";
        } else if (e.code == 'email-already-in-use') {
          errorMsg = "The account already exists for that email.";
        } else if (e.code == 'invalid-email'){
          errorMsg = "The email provided is invalid.";
        }
        CustomToast.showToast(context, errorMsg);
      } catch (e) {
        print(e);
      }

    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

                  Padding(
                      padding: getPadding(bottom: 0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: widget.showSignInScreen,
                              icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900, size: getSize(50),)
                          )
                      )
                  ),
                  SizedBox(height: getVerticalSize(90),),

              ImageIcon(
                AssetImage("assets/logo_foreground.png"),
                size: 100,
                color: ColorConstant.red900,
              ),
              //Text("NightSolver", style: AppStyle.txtPoppinsBold30,),
              
              SizedBox(height: getVerticalSize(30),),

              Padding(
                  padding: getPadding(left: 18, top: 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                          TextSpan( children: [
                            TextSpan(text: "Create an\naccount", style: AppStyle.txtPoppinsBold36),
                            TextSpan(text: ".", style: AppStyle.txtPoppinsBold36Red)
                          ]
                          )
                      )
                  )
              ),

              //username input
              Padding(
                  padding: getPadding(all: 16),
                  child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_2_rounded, color: ColorConstant.red900),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)
                        ),
                        hintText: 'Username',
                        hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                        fillColor: ColorConstant.gray90001,
                        filled: true,
                      ),
                      style: AppStyle.txtPoppinsMedium18,
                  )
              ),

              //email input
              Padding(
                  padding: getPadding(bottom: 16, left: 16, right: 16),
                  child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_rounded, color: ColorConstant.red900),
                        border: OutlineInputBorder(
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
                  padding: getPadding(bottom: 16, left: 16, right: 16),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_rounded, color: ColorConstant.red900),
                      border: OutlineInputBorder(
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

              //confirm password input
              Padding(
                  padding: getPadding(bottom: 16, left: 16, right: 16),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_rounded, color: ColorConstant.red900),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)
                      ),
                      hintText: 'Confirm Password',
                      hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                      fillColor: ColorConstant.gray90001,
                      filled: true,
                    ),
                    style: AppStyle.txtPoppinsMedium18,
                    obscureText: true,
                  )),

              
              //sign in button
              GestureDetector(
                onTap: signUp,
                child: Container(
                  padding: getPadding(all: 16),
                  margin: getMargin(left: 16, right: 16),
                  decoration: BoxDecoration(
                      color: ColorConstant.red900,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text('REGISTER',
                          style: AppStyle.txtPoppinsMedium18Grey)),
                ),
              ),
            ]),
          ),
        )));
  }
}
