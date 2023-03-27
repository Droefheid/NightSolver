import 'package:flutter/material.dart';
import 'package:night_solver/screens/result_screen.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key,required this.providerStat}) : super(key: key);
  final providerStat;
  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  double actionValue = 50;
  double aventureValue = 50;
  double comedieValue = 50;
  double crimeValue = 50;
  double dramaValue = 50;
  double fantasyValue = 50;
  double horrorValue = 50;
  double scifiValue = 50;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Adventure',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("aventureValue", aventureValue),
            Text('Action',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("actionValue", actionValue),
            Text('Comedy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("comedieValue", comedieValue),
            Text('Crime',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("crimeValue", crimeValue),
            Text('Drama',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("dramaValue", dramaValue),
            Text('Fantasy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("fantasyValue", fantasyValue),
            Text('Horror',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("horrorValue", horrorValue),
            Text('Sci-Fi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            buildSideLabel("scifiValue", scifiValue),
            buildSubmit(),
          ],
        ),
      ),
    );
  }

  Widget buildSideLabel(String field, double value) {
    return Row(
      children: [
        Text('Not at all',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 4,
            onChanged: (newValue) {
              setState(() {
                if (field == "aventureValue") {
                  aventureValue = newValue;
                } else if (field == "actionValue") {
                  actionValue = newValue;
                } else if (field == "comedieValue") {
                  comedieValue = newValue;
                }else if (field == "crimeValue") {
                  crimeValue = newValue;
                }else if (field == "dramaValue") {
                  dramaValue = newValue;
                }else if (field == "fantasyValue") {
                  fantasyValue = newValue;
                }else if (field == "horrorValue") {
                  horrorValue = newValue;
                }else if (field == "scifiValue") {
                  scifiValue = newValue;
                }
              });
            },
          ),
        ),
        Text('A lot',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          //width: MediaQuery.of(context).size.width- 80,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ResultScreen(
                    aventure: aventureValue,
                    action: actionValue,
                    comedie: comedieValue,
                    crime: crimeValue,
                    drama:dramaValue,
                    fantasy: fantasyValue,
                    horror: horrorValue,
                    scifi: scifiValue,
                    providers: widget.providerStat
                ))),
            child: Text('Submit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
