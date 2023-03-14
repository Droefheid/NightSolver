import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class NewSalon extends StatefulWidget {
  const NewSalon({Key? key}) : super(key: key);

  @override
  State<NewSalon> createState() => _NewSalonState();
}

class _NewSalonState extends State<NewSalon> {
  Color mainColor = const Color(0xff3C3261);
  final TextEditingController _controller = TextEditingController();
  List<dynamic> persons = [];
  final user = FirebaseAuth.instance.currentUser!;
  String salonName = '';
  bool editableName = true;
  List<String> salonMembers = [];



  void _onSearchChanged(String value) async {
    try {
      final int letterCount = value.length;
      if (letterCount == 0){
        setState(() {
          persons = [];
        });
      }
      else {
        final snapshot = await FirebaseFirestore.instance.collection('movies')
            .doc(user.uid)
            .get();
        List<dynamic> searchPersons = [];
        if(snapshot.data()!['friends'] != null) {
          for (String friend in snapshot.data()!['friends']) {
            if (friend.substring(0, letterCount).toLowerCase() ==
                value.toLowerCase()) {
              searchPersons.add(friend);
            }
          }
        }
        setState(() {
          persons = searchPersons;
        });
      }
    }
    catch (error) {
      print('Error occurred: $error');
    }
  }

  void _addPerson(String value) async {
    setState(() {
      salonMembers.add(value);
    });
  }
  void _removePerson(String value) async {
    setState(() {
      salonMembers.remove(value);
    });
  }

  void _changeSalonName(String value) async {
    setState(() {
      salonName = value;
    });
  }


  void _createSalon(BuildContext context) async {
    final snapshot1 = await FirebaseFirestore.instance.collection("movies").doc(user.uid).get();
    FirebaseFirestore.instance.collection('movies').doc(user.uid).set({'salons' : {'$salonName' : {'salon_members' : salonMembers}}}, SetOptions(merge : true));

    //for (String member in salonMembers){
    //  salons["salons"][salonName].set({'salon_members': FieldValue.arrayUnion([member])});
    //}
    Navigator.pop(context, true);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed:() {_createSalon(context);},
            label: Text("Create")
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
            'Creating a new salon',
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
              TextFormField(
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 30,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Name of the salon",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)
                  )
                ),
                onChanged: _changeSalonName
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Search person to add',
                ),
                controller: _controller,
                onChanged: _onSearchChanged,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, i) {
                    return MaterialButton(
                      child: PersonCell(persons[i]),
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () => _addPerson(persons[i]),
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class PersonCell extends StatelessWidget {
  final dynamic person;
  Color mainColor = const Color(0xff3C3261);
  PersonCell(this.person);

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
                          "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png"),
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
                          person
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: mainColor,
                  width: 2.5
                ),
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.done,
                  color: mainColor,
                  size: 10,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(10))
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
