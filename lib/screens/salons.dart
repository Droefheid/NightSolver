import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/watch_providers.dart';
import 'new_salon_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Salons extends StatefulWidget {
  @override
  _SalonsState createState() => _SalonsState();
}

class _SalonsState extends State<Salons> {
  List<dynamic> salons = [];
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
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(context,PageRouteBuilder(pageBuilder: (_,__,___) => const NewSalon()));
                getData();
              },
              label: const Text(
                  "New room"
              )
          ),
          appBar: AppBar(
            elevation: 0.3,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            ),
            title: Text(
              'Rooms',
              style: TextStyle(
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
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Providers())),
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
      final DocumentReference ownDocRef = FirebaseFirestore.instance.collection('users').doc(member);
      ownDocRef.update({'salons.$salonName.salon_members': FieldValue.arrayRemove([user.uid])});
    }
    final DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
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
      onPressed:  () async {
        leaveSalon(salon);
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Salons()));
        Navigator.pop(context, true);
        Navigator.pop(context, true);
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


  Future joinStrings(List<dynamic> list) async {
    List resultList = [];
    for (int i = 0; i < list.length; i++){
      final DocumentReference friendDocRef =
      FirebaseFirestore.instance.collection('users').doc(list[i]);
      DocumentSnapshot snapshot = await friendDocRef.get();
      final String friendName = snapshot['displayName'];
      resultList.add(friendName);
    }
    String allStrings = resultList.join("\n");
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
      content: FutureBuilder(
        future: joinStrings(salonMembers),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Text(
              snapshot.data!
            );
          }
          return CircularProgressIndicator();
        },
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
