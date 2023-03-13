import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  List<String> testList = [];
  List<String> printTestList = [];


  Future<void> getData() async {
    final snapshot = await FirebaseFirestore.instance.collection('movies').doc(user.uid).get();
    setState(() {
      snapshot.data()!['salons'].forEach((key, value) => salons.add(key));
    });
  }

  void _onSearchChanged(String value) async {
    try {
      final int letterCount = value.length;
      final snapshot = await FirebaseFirestore.instance.collection('movies').doc(user.uid).get();
      List<dynamic> searchSalons = [];
      snapshot.data()!['salons'].forEach((k, v) {
        if(k.substring(0,letterCount).toLowerCase() == value.toLowerCase()){
          searchSalons.add(k);
        }
      });
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
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,PageRouteBuilder(pageBuilder: (_,__,___) => const NewSalon()
              )
            );
          },
        label: const Text(
          "New salon"
        )
      ),
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
          'Salons',
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
                hintText: 'Search salon',
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
                    onPressed: () => null,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SalonCell extends StatelessWidget {
  final dynamic salon;
  Color mainColor = const Color(0xff3C3261);
  SalonCell(this.salon);

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
                  child: new Column(
                    children: [
                      new Text(
                        salon
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )
            ),
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
