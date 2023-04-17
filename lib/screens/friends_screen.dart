import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import 'custom_toast.dart';

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
      child: Text("Ok", style: AppStyle.txtPoppinsMedium18Red,),
      onPressed:  () {
        Navigator.pop(context, true);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text.rich(
          TextSpan(children: [
            TextSpan(
              text:"Help",
              style: AppStyle.txtPoppinsMedium18,
            ),
            TextSpan(
                text: " .",
                style: AppStyle.txtPoppinsMedium18Red
            )
          ])
      ),
      content: Text(
          "To add a friend, type his username in this field, then click the + icon.",
          style: AppStyle.txtPoppinsMedium18GreyLight,
      ),
      actions: [
        okButton,
      ],
      backgroundColor: ColorConstant.gray90001,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
      ),
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


  void onTabTapped(int index) {
    if (index==0) Navigator.pushNamed(context, '/');
    if (index==1) Navigator.pushNamed(context, '/search');
    if (index==2) Navigator.pushNamed(context, '/recommendation');
    if (index==4) Navigator.pushNamed(context, '/movieList');
    if (index==5) Navigator.pushNamed(context, '/settings');
  }


  @override
  Widget build(BuildContext context) {
    int currentIndex = 3;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorConstant.gray900,
        appBar: AppBar(
            backgroundColor: ColorConstant.gray900,
            leading: IconButton(
              icon: ImageIcon(AssetImage("assets/icons/back_arrow_red.png"), color: ColorConstant.red900,),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Friends",
                      style: AppStyle.txtPoppinsBold30
                  ),
                  TextSpan(
                      text: ".",
                      style: AppStyle.txtPoppinsBold30Red
                  ),
                ]),
                textAlign: TextAlign.left
            )
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
                      icon: Icon(Icons.add_circle_outline, color: ColorConstant.red900,),
                      onPressed: () async {
                        if (_addControler.text == user.displayName){
                          CustomToast.showToast(context, "You can't add yourself");
                        }
                        else{
                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").get();
                          final allUsers = querySnapshot.docs.map((doc) => doc.id).toList();
                          bool foundUser = false;
                          for(String friendId in allUsers){
                            String friendName = await getFriendName(friendId);
                            if (_addControler.text == friendName){
                              addFriend(friendId);
                              foundUser = true;
                              CustomToast.showToast(context, '$friendName added as a friend');
                            }
                          }
                          if (!foundUser) CustomToast.showToast(context, 'No user found');
                        }
                      },
                  ),
                  suffixIcon: new IconButton(
                    icon: Icon(Icons.help, color: ColorConstant.gray700,),
                    onPressed: () {showHelpDialog(context);}
                  ),
                  hintText: "Add a friend",
                  hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  filled: true,
                  fillColor: ColorConstant.gray90001
                ),
                style: AppStyle.txtPoppinsMedium18,
                onChanged: null
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_search_rounded, color: ColorConstant.red900),
                  hintText: 'Search a friend',
                  hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                  filled: true,
                  fillColor: ColorConstant.gray90001,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)
                  )
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: ColorConstant.gray900,
            selectedItemColor: ColorConstant.red900,
            unselectedItemColor: ColorConstant.whiteA700,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) => setState(() {
              currentIndex = index;
              onTabTapped(index);
            }),
            items: [
              BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/icons/home_filled.png")),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/icons/search_empty.png")),
                  label: "Search"
              ),
              BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/icons/recomandation_empty.png")),
                  label: "Recommendation"
              ),
              BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/icons/friends_filled.png")),
                  label: "Friends"
              ),
              BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/icons/bookmark_empty.png")),
                  label: "bookmark"
              ),
              BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/icons/settings_empty.png")),
                  label: "Settings"
              ),
            ],
          )
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
      child: Text("Cancel", style: AppStyle.txtPoppinsMedium18),
      onPressed:  () {
        Navigator.pop(context, true);
      },
    );
    Widget proceedButton = MaterialButton(
      child: Text("Proceed", style: AppStyle.txtPoppinsMedium18Red),
      onPressed: () async {
        await removeFriend(friend);
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Friends()));
        Navigator.pop(context, true);
        Navigator.pop(context, true);
        },
    );
    AlertDialog alert = AlertDialog(
      title: Text.rich(
        TextSpan(children: [
          TextSpan(
            text:"Warning",
            style: AppStyle.txtPoppinsMedium18,
          ),
          TextSpan(
              text: " !",
              style: AppStyle.txtPoppinsMedium18Red
          )
        ])),
      content: Text(
      'You are about to unfriend \'$friend\'\n'
      'Do you wish to proceed?', style: AppStyle.txtPoppinsMedium18GreyLight),
      actions: [
        cancelButton,
        proceedButton,
      ],
      backgroundColor: ColorConstant.gray90001,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
      ),
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
                              style: AppStyle.txtPoppinsBold20
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
                color: ColorConstant.red900,
              ),
              onPressed: () {showWarningDialog(context, friend);}
            ),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: ColorConstant.redA700,
          margin: const EdgeInsets.all(16.0),
        )
      ],
    );
  }
}
