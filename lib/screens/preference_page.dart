import 'package:flutter/material.dart';
import 'package:night_solver/screens/result_screen.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key }): super(key: key);

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences>{
  double aventureValue = 50;
  double actionValue = 50;
  double comedieValue = 50;
  Color mainColor = const Color(0xff3C3261);

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
          'Select preferences',
          style: TextStyle(
            color: mainColor,
            fontFamily: 'Arvo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Aventure',textAlign: TextAlign.left, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          buildSideLabel(this.aventureValue),
          Text('Action', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          buildSideLabel(this.actionValue),
          Text('Comédie', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          buildSideLabel(this.comedieValue),
          buildSubmit(),
        ],
      ),
    );
  }

  Widget buildSideLabel(double Value){
    return Row(
      children: [
        Text('Not at all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Expanded(
          child: Slider(
            value: Value,
            min: 0,
            max: 100,
            divisions: 4,
            onChanged: (NewValue) {
              setState(() {
                Value = NewValue;
              });
            },
          ),
        ),
        Text('A lot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          //width: MediaQuery.of(context).size.width- 80,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultScreen(aventure : aventureValue, action : actionValue, comedie : comedieValue))),
            child: Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }


}




