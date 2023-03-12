import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget{
  Color mainColor = const Color(0xff3C3261);
  double aventure;
  double action;
  double comedie;
  ResultScreen({required this.aventure, required this.action, required this.comedie});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: mainColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Recomended Movies',
          style: TextStyle(
            color: mainColor,
            fontFamily: 'Arvo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

  }

}


