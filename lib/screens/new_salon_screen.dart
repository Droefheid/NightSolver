import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_solver/utils/size_utils.dart';
import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import 'custom_toast.dart';
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
    final snapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    List<dynamic> myFriends = [];
    if (snapshot.data()!['friends'] != null){
      for (String friend in snapshot['friends']){
        myFriends.add(friend);
      }
      setState(() {
        persons = myFriends;
      });
    }
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
    FirebaseFirestore.instance.collection('users').doc(value);
    DocumentSnapshot snapshot = await friendDocRef.get();
    final String friendName = snapshot['displayName'];
    setState(() {
      salonMembers.add(value);
    });
    CustomToast.showToast(context, '$friendName added to the room');
  }
  void removePerson(String value) async {
    final DocumentReference friendDocRef =
    FirebaseFirestore.instance.collection('users').doc(value);
    DocumentSnapshot snapshot = await friendDocRef.get();
    final String friendName = snapshot['displayName'];
    setState(() {
      salonMembers.remove(value);
    });
    CustomToast.showToast(context, '$friendName removed from the room');
  }

  void _changeSalonName(String value) async {
    setState(() {
      salonName = value;
    });
  }


  void _createSalon(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance.collection('users')
        .doc(user.uid)
        .get();
    if (snapshot.data()!['salons'] != null){
      if (snapshot.data()!['salons'].keys.toList().contains(salonName)){
        CustomToast.showToast(context, 'This room name is already used');
      }
      else{
        for (String member in salonMembers){
          FirebaseFirestore.instance
              .collection('users')
              .doc(member)
              .set({'salons' : {'$salonName' : {'salon_members' : salonMembers, 'salon_creator' : user.uid}}}, SetOptions(merge : true));
        }
        Navigator.pop(context, true);
      }
    }
    else{
      for (String member in salonMembers){
        FirebaseFirestore.instance
            .collection('users')
            .doc(member)
            .set({'salons' : {'$salonName' : {'salon_members' : salonMembers, 'salon_creator' : user.uid}}}, SetOptions(merge : true));
      }
      Navigator.pop(context, true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorConstant.gray900,
        floatingActionButton: FloatingActionButton.extended(
            onPressed:() {
              if(salonName == ''){
                CustomToast.showToast(context, 'No room name given');
              }
              else{
                _createSalon(context);
              }
            },
            label: Text(
                "Create",
                style: AppStyle.txtPoppinsMedium18Grey,
            ),
            backgroundColor: ColorConstant.red900,
        ),
        appBar: AppBar(
            backgroundColor: ColorConstant.gray900,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Create a new room",
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
          padding: getPadding(all: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLength: 30,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.abc_rounded, color: ColorConstant.red900,),
                  helperStyle: AppStyle.txtPoppinsRegular12,
                  hintText: "Name of the room",
                  hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  filled: true,
                  fillColor: ColorConstant.gray90001,
                ),
                style: AppStyle.txtPoppinsMedium18,
                onChanged: _changeSalonName
              ),
              Padding(padding: getPadding(all: 16)),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_add_alt_rounded, color: ColorConstant.red900,),
                  hintText: 'Add a friend',
                  hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)
                  ),
                  filled: true,
                  fillColor: ColorConstant.gray90001,
                ),
                style: AppStyle.txtPoppinsMedium18,
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
    FirebaseFirestore.instance.collection('users').doc(friendId);
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
