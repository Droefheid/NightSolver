import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:night_solver/screens/home_screen.dart';
import 'package:night_solver/screens/recommendation_screen.dart';
import 'package:night_solver/screens/search_screen.dart';

import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import 'movie_list.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  @override
  void initState() {
    super.initState();
  }

  void onTabTapped(int index) {
    if(index==0) Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen()));
    if(index==1) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen()));
    if(index==2) Navigator.of(context).push(MaterialPageRoute(builder: (_) => Recommendation()));
    if(index==3) Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieList()));
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 4;
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      appBar: AppBar(
          //forceMaterialTransparency: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Settings",
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
      body: Column(
        children: [
          SimpleSettingsTile(
              title: "Logout",
              titleTextStyle: AppStyle.txtPoppinsRegular16Bluegray400,
              leading: Icon(Icons.logout_rounded, color: ColorConstant.red900),
              onTap: () => {
                FirebaseAuth.instance.signOut(),
                Navigator.of(context).pop()
                //TODO
                }
              ,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(child: Icon(Icons.logout_rounded, color: ColorConstant.red900)),
                      TextSpan(
                          text: "Log out"
                      ),
                    ],
                    style: AppStyle.txtPoppinsRegular16WhiteA700,
                  )
              )
          )
        ],
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
              icon: Icon(Icons.bookmark),
              label: "bookmark"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings"
          ),
        ],
      ),
    );
  }
}