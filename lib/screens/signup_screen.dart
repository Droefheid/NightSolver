import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      Fluttertoast.showToast(
          msg: "This username is already taken",
          gravity: ToastGravity.TOP,
          fontSize: 18,
          backgroundColor: Colors.red.shade900);

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
        Fluttertoast.showToast(
            msg: errorMsg,
            gravity: ToastGravity.TOP,
            fontSize: 18,
            backgroundColor: Colors.red.shade900
        );
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

              Text('Create an account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              SizedBox(height: 30),

              //username input
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red.shade900),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Username',
                        fillColor: Colors.grey[100],
                        filled: true,
                      ))),

                  SizedBox(height: 10),


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

              SizedBox(height: 10),

              //password input
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade900),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Password',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                    obscureText: true,
                  )),

              SizedBox(height: 10),
              //confirm password input
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade900),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Confirm Password',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                    obscureText: true,
                  )),

              SizedBox(
                height: 30,
              ),
              //sign in button
              GestureDetector(
                onTap: signUp,
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text('Sign Up',
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
                onTap: widget.showSignInScreen,
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
