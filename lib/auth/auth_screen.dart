import 'package:flutter/material.dart';
import 'package:night_solver/screens/signin_screen.dart';
import 'package:night_solver/screens/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  bool showSignInScreen = true;

  void toggleScreens(){
    setState(() {
      showSignInScreen = !showSignInScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showSignInScreen){
      return SignInScreen(showSignUpScreen: toggleScreens);
    }else{
      return SignUpScreen(showSignInScreen: toggleScreens);
    }
  }
}
