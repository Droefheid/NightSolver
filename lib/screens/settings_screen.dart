import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import '../theme/app_style.dart';
import '../utils/color_constant.dart';

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
    if (index==0) Navigator.pushNamed(context, '/');
    if (index==1) Navigator.pushNamed(context, '/search');
    if (index==2) Navigator.pushNamed(context, '/salons');
    if (index==3) Navigator.pushNamed(context, '/friends');
    if (index==4) Navigator.pushNamed(context, '/movieList');
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 5;
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      appBar: AppBar(
          backgroundColor: ColorConstant.gray900,
          leading: IconButton(
            icon: ImageIcon(AssetImage("assets/icons/back_arrow_red.png"), color: ColorConstant.red900,),
              onPressed: () => Navigator.of(context).pop()
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
          TextField(
              readOnly: true,
              onTap: () => {
                FirebaseAuth.instance.signOut(),
                Navigator.of(context).popUntil((route) => route.isFirst)
                //TODO
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.logout_rounded, color: ColorConstant.red900),
                hintText: "Log out",
                hintStyle: AppStyle.txtPoppinsRegular16WhiteA700,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstant.red900),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstant.red900),
                ),
              ),
          ),
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
    );
  }
}