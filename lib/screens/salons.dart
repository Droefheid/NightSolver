import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/preference_page.dart';
import 'home_screen.dart';
import 'new_salon_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Salons extends StatefulWidget {
  @override
  _SalonsState createState() => _SalonsState();
}

class _SalonsState extends State<Salons> {
  List<dynamic> salons = [];
  Color mainColor = const Color(0xff3C3261);
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;



  Future<void> getData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("movies").doc(user.uid).get();
    List<dynamic> newSalons = [];
    for (String key in snapshot['salons'].keys){
      newSalons.add({key : snapshot['salons'][key]});
    }
    setState(() {
      salons = newSalons;
    });
  }

  void _onSearchChanged(String value) async {
    try {
      final int letterCount = value.length;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("movies").doc(user.uid).get();

      List<dynamic> searchSalons = [];
      for (String key in snapshot['salons'].keys){
        if(key.substring(0,letterCount).toLowerCase() == value.toLowerCase()){
          searchSalons.add({key : snapshot['salons'][key]});
        }
      }
      setState(() {
        salons = searchSalons;
      });
    } catch (error) {
      print('Error occurred: $error');
    }
  }
  


  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child : Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              Navigator.push(context,PageRouteBuilder(pageBuilder: (_,__,___) => const NewSalon()));
            },
          label: const Text(
            "New room"
          )
        ),
        appBar: AppBar(
          elevation: 0.3,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: mainColor,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen())),
          ),
          title: Text(
            'Rooms',
            style: TextStyle(
              color: mainColor,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search room',
                ),
                controller: _controller,
                onChanged: _onSearchChanged,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: salons.length,
                  itemBuilder: (context, i) {
                    return MaterialButton(
                      child: SalonCell(salons[i]),
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Preferences())),
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}



class SalonCell extends StatelessWidget {
  final dynamic salon;
  final Color mainColor = const Color(0xff3C3261);
  SalonCell(this.salon);
  final user = FirebaseAuth.instance.currentUser!;


  void leaveSalon(dynamic salon) async {
    String salonName = salon.keys.toList().first;
    for (String member in salon[salon.keys.toList().first]['salon_members']){
      final DocumentReference ownDocRef = FirebaseFirestore.instance.collection('movies').doc(member);
      ownDocRef.update({'salons.$salonName.salon_members': FieldValue.arrayRemove([user.uid])});
    }
    final DocumentReference docRef = FirebaseFirestore.instance.collection('movies').doc(user.uid);
    docRef.update({'salons.$salonName' : FieldValue.delete()});
  }
  showWarningDialog(BuildContext context, dynamic salon){
    String salonName = salon.keys.toList().first;
    Widget cancelButton = MaterialButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget proceedButton = MaterialButton(
      child: Text("Proceed"),
      onPressed:  () {
        leaveSalon(salon);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Salons()));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text(
        "You are about to leave the room \'$salonName\'.\n"
        "Do you wish to proceed?"
      ),
      actions: [
        cancelButton,
        proceedButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  String joinStrings(List<dynamic> list){
    String allStrings = list.join("\n");
    return allStrings;
  }

  showMembersDialog(BuildContext context, List salonMembers) {
    Widget okButton = MaterialButton(
      child: Text("Ok"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("List of members"),
      content: Text(
        joinStrings(salonMembers)
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Container(
                  width: 70.0,
                  height: 70.0,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.grey,
                  image: new DecorationImage(
                      image: new NetworkImage(
                        'https://spng.pngfind.com/pngs/s/243-2435837_free-png-initiate-group-chat-icon-group-chat.png'),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: mainColor,
                        blurRadius: 5.0,
                        offset: new Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            new Expanded(
              child: new Container(
                margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: new Text(
                  salon.keys.toList().first,
                  style: TextStyle(
                    fontSize: 20.0
                  ),
                ),
              )
            ),
            new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: [
                  new IconButton(
                    highlightColor: Colors.blue,
                    icon: Icon(Icons.person),
                    onPressed: () {
                      showMembersDialog(context, salon[salon.keys.toList().first]['salon_members']);
                    },
                  ),
                  new IconButton(
                    highlightColor: Colors.red,
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      showWarningDialog(context, salon);
                      },
                  ),
                ],
              )
            )
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.all(16.0),
        )
      ],
    );
  }
}
