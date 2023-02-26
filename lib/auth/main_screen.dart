import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/auth/auth_screen.dart';
import 'package:night_solver/screens/home_screen.dart';
import 'package:night_solver/screens/signin_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return HomeScreen();
          }else{
            return AuthScreen();
          }
        },
      ),
    );
  }
}
