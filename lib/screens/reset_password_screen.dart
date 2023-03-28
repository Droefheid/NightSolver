import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      CustomToast.showToast(context, "Password reset email sent.");//Please check your email to reset your password.
    } catch (e) {
      CustomToast.showToast(context, "Failed to send password reset email.");// Please try again.
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              ImageIcon(
                AssetImage("assets/logo_foreground.png"),
                size: 80,
              ),

              SizedBox(height: 10),

              Text('Forgot your password ?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              SizedBox(height: 50),

              //email input
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red.shade900),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Email',
                        fillColor: Colors.grey[100],
                        filled: true,
                      ))),

              SizedBox(height: 30),

              //sign in button
              GestureDetector(
                onTap: resetPassword,
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text('Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ))),
                ),
              ),

                SizedBox(height: 25),
                //register now

                GestureDetector(
                  onTap: (){Navigator.pop(context);},
                  child: Text('Login now',
                      style: TextStyle(
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                ),

            ]),
          ),
        )));
  }
}
