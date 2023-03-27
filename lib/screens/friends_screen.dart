import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_solver/screens/home_screen.dart';


class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final TextEditingController _SearchController = TextEditingController();
  final TextEditingController _addControler = TextEditingController();
  List<dynamic> friends = [];
  final user = FirebaseAuth.instance.currentUser!;


  Future<void> getData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    List<dynamic> myFriends = [];

    if (snapshot.data()!['friends'] != null) {
      for (String friend in snapshot.data()!['friends']) {
        final DocumentReference friendDocRef =
        FirebaseFirestore.instance.collection('users').doc(friend);
        DocumentSnapshot snapshot = await friendDocRef.get();
        final String friendName = snapshot['displayName'];
        myFriends.add(friendName);
      }
    }
    setState(() {
      friends = myFriends;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void _onSearchChanged(String value) async {
    try {
      final int letterCount = value.length;
      final snapshot = await FirebaseFirestore.instance.collection('users')
          .doc(user.uid)
          .get();
      List<dynamic> searchFriends = [];
      if(snapshot.data()!['friends'] != null) {
        for (String friend in snapshot.data()!['friends']) {
          final DocumentReference friendDocRef =
          FirebaseFirestore.instance.collection('users').doc(friend);
          DocumentSnapshot snapshot = await friendDocRef.get();
          final String friendName = snapshot['displayName'];
          if (friendName.substring(0, letterCount).toLowerCase() == value.toLowerCase()) {
            searchFriends.add(friendName);
          }
        }
      }
      setState(() {
        friends = searchFriends;
      });
    }
    catch (error) {
      print('Error occurred: $error');
    }
  }

  void addFriend(String value) async {
    final DocumentReference friendDocRef =
    FirebaseFirestore.instance.collection('users').doc(value);
    friendDocRef.set({
      'friends': FieldValue.arrayUnion([user.uid]),
    }, SetOptions(merge: true));

    final DocumentReference ownDocRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    ownDocRef.set({
      'friends': FieldValue.arrayUnion([value]),
    }, SetOptions(merge: true));


    FocusScope.of(context).unfocus();
    getData();
  }


  showHelpDialog(BuildContext context) {
    Widget okButton = MaterialButton(
      child: Text("Ok"),
      onPressed:  () {
        Navigator.pop(context, true);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Help"),
      content: Text(
          "To add a friend, type his username in this field, then click the + icon."
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

  Future getFriendName(String friendId) async {
      final DocumentReference friendDocRef =
      FirebaseFirestore.instance.collection('users').doc(friendId);
      DocumentSnapshot snapshot = await friendDocRef.get();
      final String friendName = snapshot['displayName'];
    return friendName;
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.3,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, true)
          ),
          title: Text(
            'Friends',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _addControler,
                decoration: InputDecoration(
                  prefixIcon: new IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () async {
                        if (_addControler.text == user.displayName){
                          var snackBar = SnackBar(content: Text('This is yourself silly'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        else{
                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").get();
                          final allUsers = querySnapshot.docs.map((doc) => doc.id).toList();
                          for(String friendId in allUsers){
                            String friendName = await getFriendName(friendId);
                            if (_addControler.text == friendName){
                              var snackBar = SnackBar(content: Text('$friendName added as a friend'));
                              addFriend(friendId);
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          }
                          var snackBar = SnackBar(content: Text('No user found'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                  ),
                  suffixIcon: new IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () {showHelpDialog(context);}
                  ),
                  hintText: "Add a friend",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)
                  )
                ),
                onChanged: null
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Search a friend',
                ),
                controller: _SearchController,
                onChanged: _onSearchChanged,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, i) {
                    return MaterialButton(
                      child: FriendCell(friends[i]),
                      padding: const EdgeInsets.all(0.0),
                      onPressed: null,
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

class FriendCell extends StatelessWidget {
  final dynamic friend;
  Color mainColor = const Color(0xff3C3261);
  FriendCell(this.friend);
  final user = FirebaseAuth.instance.currentUser!;

  Future<String> getFriendName(String friendId) async{


    print(friendId);
    final DocumentReference friendDocRef =
    FirebaseFirestore.instance.collection('users').doc(friendId);
    DocumentSnapshot snapshot = await friendDocRef.get();
    return snapshot['displayName'];
  }


  Future removeFriend(String friendName) async {
    String friendId = '';
    final DocumentReference ownDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot mySnapshot = await ownDocRef.get();
    for(String someFriendId in mySnapshot['friends']){
      final DocumentReference friendDocRef = FirebaseFirestore.instance.collection('users').doc(someFriendId);
      DocumentSnapshot snapshot = await friendDocRef.get();
      if (snapshot['displayName'] == friendName){
        friendId = someFriendId;
      }
    }

    final DocumentReference myDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    myDocRef.update({'friends': FieldValue.arrayRemove([friendId])});

    final DocumentReference myFriendDocRef = FirebaseFirestore.instance.collection('users').doc(friendId);
    myFriendDocRef.update({'friends': FieldValue.arrayRemove([user.uid])});

  }

  showWarningDialog(BuildContext context, String friend) {

    Widget cancelButton = MaterialButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, true);
      },
    );
    Widget proceedButton = MaterialButton(
      child: Text("Proceed"),
      onPressed: () async {
        await removeFriend(friend);
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Friends()));
        Navigator.pop(context, true);
        Navigator.pop(context, true);
        },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text(
      'You are about to unfriend \'$friend\'\n'
      'Do you wish to proceed?'),
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
                  margin: const EdgeInsets.fromLTRB(0, 0.0, 0, 0.0),
                  child: new Column(
                    children: [
                            Text(
                              friend,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20
                              ),
                            )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )
            ),
            new IconButton(
              highlightColor: Colors.red,
              icon: Icon(
                Icons.heart_broken,
                color: Colors.black,
              ),
              onPressed: () {showWarningDialog(context, friend);}
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
