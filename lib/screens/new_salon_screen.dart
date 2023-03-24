import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'salons.dart';


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
  List<String> salonMembers = [FirebaseAuth.instance.currentUser!.uid];

  Future<void> getData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("movies").doc(user.uid).get();
    List<dynamic> myFriends = [];
    for (String friend in snapshot['friends']){
      myFriends.add(friend);
    }
    setState(() {
      persons = myFriends;
    });
    print(persons);
  }


  @override
  void initState() {
    super.initState();
    getData();
  }

  void _onSearchChanged(String value) async {
    try {
      final int letterCount = value.length;
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
    catch (error) {
      print('Error occurred: $error');
    }
  }

  void addPerson(String value) async {
    final DocumentReference friendDocRef =
    FirebaseFirestore.instance.collection('movies').doc(value);
    DocumentSnapshot snapshot = await friendDocRef.get();
    final String friendName = snapshot['displayName'];
    setState(() {
      salonMembers.add(value);
    });
    var snackBar = SnackBar(duration: const Duration(seconds: 2), content: Text('$friendName added to the room'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void removePerson(String value) async {
    final DocumentReference friendDocRef =
    FirebaseFirestore.instance.collection('movies').doc(value);
    DocumentSnapshot snapshot = await friendDocRef.get();
    final String friendName = snapshot['displayName'];
    setState(() {
      salonMembers.remove(value);
    });
    var snackBar = SnackBar(duration: const Duration(seconds: 2), content: Text('$friendName removed from the room'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _changeSalonName(String value) async {
    setState(() {
      salonName = value;
    });
  }


  void _createSalon(BuildContext context) async {
    for (String member in salonMembers){
      FirebaseFirestore.instance
          .collection('movies')
          .doc(member)
          .set({'salons' : {'$salonName' : {'salon_members' : salonMembers}}}, SetOptions(merge : true));
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Salons()));
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed:() {
              if(salonName == ''){
                var snackBar = SnackBar(content: Text('No room name given'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              else{
                _createSalon(context);
              }
            },
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
            'Creating a new room',
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
                  hintText: "Name of the room",
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
                      onPressed: () async {
                        if (!salonMembers.contains(persons[i])){
                          addPerson(persons[i]);
                        }
                        else{
                          removePerson(persons[i]);
                        }
                      },
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


  Future<String> getFriendName(String friendId) async{
    final DocumentReference friendDocRef =
    FirebaseFirestore.instance.collection('movies').doc(friendId);
    DocumentSnapshot snapshot = await friendDocRef.get();
    return snapshot['displayName'];
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
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
                        FutureBuilder(
                          future: getFriendName(person),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState == ConnectionState.done) {
                              return Text(
                                snapshot.data!,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20
                                ),
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        )
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
      ),
    );
  }
}
