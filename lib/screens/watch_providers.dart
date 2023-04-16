import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/preference_page.dart';

class Providers extends StatefulWidget {
  const Providers({Key? key,required this.IdList, required this.salonName} ) : super(key: key);
  final IdList;
  final salonName;
  @override
  State<Providers> createState() => _ProvidersState();
}
//TODO fais en logo
class _ProvidersState extends State<Providers>{
  Color mainColor = const Color(0xff3C3261);
  var providers = {
  "Netflix":0,
  "Amazon Prime Video" : 0,
  "Disney Plus" : 0,
  "Apple TV":0,
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
      body: Wrap(
        children: [
          ProvideroCell("Netflix"),
          ProvideroCell("Amazon Prime Video"),
          ProvideroCell("Disney Plus"),
          ProvideroCell("Apple TV"),
        ],
      ),
        bottomSheet: buildSubmit(),
    );
  }
  Widget ProvideroCell( String field){
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(10),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: (providers[field]==0)?Colors.black:Colors.white),
            )
        )
    );
  }
  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              for (String member in widget.IdList){
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(member)
                    .set({'salons' : {widget.salonName : {'providers' : providers}}}, SetOptions(merge : true));
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Preferences(salonName: widget.salonName, IdList : widget.IdList, providerStat : providers)));
            },
            child: Text('Next',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}