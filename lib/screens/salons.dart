import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/custom_toast.dart';
import 'package:night_solver/screens/preference_page.dart';
import 'package:night_solver/screens/result_screen.dart';
import 'package:night_solver/utils/size_utils.dart';
import '../utils/movie_info.dart';
import 'movie_details.dart';
import 'package:night_solver/screens/search_screen.dart';
import 'package:night_solver/screens/settings_screen.dart';
import 'package:night_solver/screens/watch_providers.dart';
import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import 'home_screen.dart';
import 'movie_list.dart';
import 'new_salon_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;




class Salons extends StatefulWidget {
  @override
  _SalonsState createState() => _SalonsState();
}

class _SalonsState extends State<Salons> {
  List<dynamic> salons = [];
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';


  Future<void> getData() async {
    final snapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    List<dynamic> newSalons = [];
    if (snapshot.data()!['salons'] != null){
      for (String key in snapshot['salons'].keys){
        newSalons.add({key : snapshot['salons'][key]});
      }
      setState(() {
        salons = newSalons;
      });
    }
  }

  void _onSearchChanged(String value) async {
    try {
      final int letterCount = value.length;
      final snapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      List<dynamic> searchSalons = [];
      if (snapshot.data()!['salons'] != null){
        for (String key in snapshot['salons'].keys){
          if(key.substring(0,letterCount).toLowerCase() == value.toLowerCase()){
            searchSalons.add({key : snapshot['salons'][key]});
          }
        }
        setState(() {
          salons = searchSalons;
        });
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }



  @override
  void initState() {
    super.initState();
    getData();
  }

  void onTabTapped(int index) {
    if (index==0) Navigator.pushNamed(context, '/');
    if (index==1) Navigator.pushNamed(context, '/search');
    if (index==3) Navigator.pushNamed(context, '/friends');
    if (index==4) Navigator.pushNamed(context, '/movieList');
    if (index==5) Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 2;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child : Scaffold(
          backgroundColor: ColorConstant.gray900,
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(context,PageRouteBuilder(pageBuilder: (_,__,___) => const NewSalon()));
                getData();
              },
              label: Text(
                  "New room",
                  style: AppStyle.txtPoppinsRegular14Gray900,
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
                        text: "Rooms",
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
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: ColorConstant.red900),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                    hintText: 'Search room',
                    filled: true,
                    fillColor: ColorConstant.gray90001
                  ),
                  style: AppStyle.txtPoppinsMedium18,
                  controller: _controller,
                  onChanged: _onSearchChanged,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: salons.length,
                    itemBuilder: (context, i) {
                      return MaterialButton(
                        child: RoomInfo(salon:salons[i]),
                        padding: getPadding(top: 16, bottom: 16),
                        onPressed: () async {
                          String salonName = salons[i].keys.first;
                          var members = salons[i].values.first['salon_members'];
                          var votes = salons[i].values.first['votes'];
                          if(votes != null){
                            if(votes.keys.length == members.length){
                              dynamic mostFrequent = votes.values.fold(null, (dynamic mostFrequent, dynamic current) =>
                              mostFrequent == null || votes.values.where((dynamic e) => e == current).length > votes.values.where((dynamic e) => e == mostFrequent).length
                                  ? current
                                  : mostFrequent
                              );
                              final result = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$mostFrequent?api_key=$apiKey'));
                              if (result.statusCode == 200) {
                                final Map<String, dynamic> resultData = json.decode(result.body);
                                CustomToast.showToast(context, 'Everyone has voted. This is the most voted movie');
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetail(item: new MovieInfo(resultData))));
                          }
                            }

                            else if(votes.keys.contains(user.uid)){
                              List waitingForId = members.where((element) => !votes.keys.contains(element)).toList();
                              List waitingForNames = [];
                              for (int i = 0; i < waitingForId.length; i++){
                                final DocumentReference friendDocRef =
                                FirebaseFirestore.instance.collection('users').doc(waitingForId[i]);
                                DocumentSnapshot snapshot = await friendDocRef.get();
                                final String friendName = snapshot['displayName'];
                                waitingForNames.add(friendName);
                              }
                              CustomToast.showToast(context, 'waiting for $waitingForNames to vote for their movie');
                            }
                            else{
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(salonName: salonName, IdList: members, providers: salons[i].values.first['providers'])));
                            }
                          }
                          else{
                            if(!salons[i].values.first.keys.contains('providers')){
                              if(salons[i].values.first['salon_creator'] != user.uid){
                                CustomToast.showToast(context, "No providers chosen by room creator yet");
                              }
                              else{
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => Providers(IdList: members, salonName : salonName)));
                              }
                            }
                            else{
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => Preferences(salonName: salonName, IdList: members, providerStat: salons[i].values.first['providers'])));
                            }
                          }
                        },
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
                  icon: Icon(Icons.home),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "Search"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.recommend),
                  label: "Recommendation"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.group_rounded),
                  label: "Friends"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: "bookmark"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Settings"
              ),
            ],
          ),
        )
    );
  }
}



class RoomInfo extends StatelessWidget {

  final dynamic salon;
  final user = FirebaseAuth.instance.currentUser!;

  RoomInfo({required this.salon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getHorizontalSize(381),
      height: getVerticalSize(146),
      child: Row(
        children: [
          Container(
            width: getHorizontalSize(146),
            height: getVerticalSize(146),
            child: Stack(
              children: [
                Image.network(
                  "https://media.istockphoto.com/id/1248991874/vector/cinema-dark-hall-auditorium-with-red-seats-white-empty-screen-realistic-mock-up-template.jpg?s=612x612&w=0&k=20&c=yOAEDLYKAxDrqNmG1et3DNHQbF4zCpwuEzFRUPIGIX4=",
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
                /*Positioned(
                    child: Icon(Icons.star_rounded, color: ColorConstant.red900)
                )*/
              ],
            ),
          ),
          SizedBox(width: getHorizontalSize(18)),
          Container(
            width: getHorizontalSize(214),
            height: getVerticalSize(141),
            child: Column(
              children: [
                Padding(
                    padding: getPadding(top: 16, bottom: 6),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          salon.keys.toList().first,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.txtPoppinsBold20,
                        )
                    )
                ),
                Padding(
                    padding: getPadding(top: 16),
                    child: Row(
                      children: [
                        Padding(
                            padding: getPadding(left: 100, right: 16),
                            child: IconButton(
                                icon: Icon(Icons.person_outline_rounded, color: ColorConstant.whiteA700),
                              onPressed: () {
                                showMembersDialog(context, salon[salon.keys.toList().first]['salon_members']);
                              },
                            )
                        ),
                        IconButton(
                            onPressed: () {
                              showWarningDialog(context, salon);
                            },
                            icon:  Icon(Icons.logout_sharp, color: ColorConstant.red900)
                        )
                      ],
                    )
                )
              ],
            ),
          )
        ],
      ),
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

  void leaveSalon(dynamic salon) async {
    String salonName = salon.keys.toList().first;
    for (String member in salon[salon.keys.toList().first]['salon_members']){
      final DocumentReference ownDocRef = FirebaseFirestore.instance.collection('users').doc(member);
      ownDocRef.update({'salons.$salonName.salon_members': FieldValue.arrayRemove([user.uid])});
      ownDocRef.update({'salons.$salonName.preferences.${user.uid}' : FieldValue.delete()});
      ownDocRef.update({'salons.$salonName.votes.${user.uid}' : FieldValue.delete()});

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

  showMembersDialog(BuildContext context, List salonMembers) {
    Widget okButton = MaterialButton(
      child: Text("Ok", style: AppStyle.txtPoppinsMedium18Red),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorConstant.gray90001,
      title: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: "Members",
            style: AppStyle.txtPoppinsBold20
          ),
          TextSpan(
            text: ".",
            style: AppStyle.txtPoppinsBold20Red
          )
        ]
        )
      ),
      content: FutureBuilder(
        future: joinStrings(salonMembers),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Text(
                snapshot.data!,
              style: AppStyle.txtPoppinsMedium18,
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
      ownDocRef.update({'salons.$salonName.preferences.${user.uid}' : FieldValue.delete()});
      ownDocRef.update({'salons.$salonName.votes.${user.uid}' : FieldValue.delete()});

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
                      icon: Icon(Icons.person_outline_rounded),
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
