import 'package:flutter/material.dart';
import 'package:night_solver/screens/preference_page.dart';

class Providers extends StatefulWidget {
  const Providers({Key? key}) : super(key: key);
  @override
  State<Providers> createState() => _ProvidersState();
}

class _ProvidersState extends State<Providers>{
  Color mainColor = const Color(0xff3C3261);
  var providers = {
  "Netflix":0,
  "Amazon Prime Video" : 0,
  "Disney Plus" : 0,
  "BeTV" : 0,
  "Apple TV":0,
    "Pirate":0
  };
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
          'Movie Providers',
          style: TextStyle(
            color: mainColor,
            fontFamily: 'Arvo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          ProvideroCell("Netflix"),
          ProvideroCell("Amazon Prime Video"),
          ProvideroCell("Disney Plus"),
          ProvideroCell("BeTV"),
          ProvideroCell("Apple TV"),
          ProvideroCell("Pirate"),
        ],
      ),
        bottomSheet: buildSubmit(),
    );
  }
  Widget ProvideroCell( String field){
    return Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: (providers[field]==0)?Colors.white : mainColor,
              minimumSize: Size(100, 80),
            ),
            onPressed: (){
              setState(() {
                if(providers[field]==0){
                  providers[field]=1;
                }else{
                  providers[field]=0;
                }
              }
              );
              },
            child: Text(
              field,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: (providers[field]==0)?Colors.black:Colors.white),
            )
        )
    );
  }
  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Preferences(
                  providerStat : providers
              ))),
            child: Text('Next',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}