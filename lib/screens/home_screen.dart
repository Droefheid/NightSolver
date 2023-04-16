import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:night_solver/screens/NavBar.dart';
import 'package:night_solver/screens/movie_details.dart';
import 'package:night_solver/screens/new_salon_screen.dart';
import 'package:night_solver/screens/preference_page.dart';
import 'package:http/http.dart' as http;
import 'package:night_solver/screens/recommendation_screen.dart';
import 'package:night_solver/screens/search_screen.dart';
import 'package:night_solver/screens/settings_screen.dart';
import 'package:night_solver/theme/app_decoration.dart';
import 'package:night_solver/utils/color_constant.dart';
import 'package:night_solver/utils/image_constant.dart';

import '../theme/app_style.dart';
import '../utils/custom_widgets.dart';
import '../utils/movie_info.dart';
import '../utils/size_utils.dart';
import 'movie_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text("Trending movies");
  String searchValue = "";
  List<dynamic> movies = [];
  final controller = ScrollController();
  int currentIndex = 0;
  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  void onTabTapped(int index) {
    if(index==1) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen()));
    if (index==2) Navigator.of(context).push(MaterialPageRoute(builder: (_) => Recommendation()));
    if(index==3) Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieList()));
    if(index==4) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingScreen()));
  }

  Future<void> getData() async {
    final url =
        'https://api.themoviedb.org/3/trending/movie/week?api_key=9478d83ca04bd6ee25b942dd7a0ad777';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> responseData = json.decode(response.body);
    setState(() {
      movies = responseData['results'];
    });
  }


  @override
  void initState() {
    super.initState();
    getData();
  }



  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      body: Container(
        width: double.infinity,
        decoration: AppDecoration.fillGray900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: getPadding(left: 16, top: 73),
                  child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: "Trending",
                            style: AppStyle.txtPoppinsBold30
                        ),
                        TextSpan(
                            text: ".",
                            style: AppStyle.txtPoppinsBold30Red
                        )
                      ]),
                      textAlign: TextAlign.left
                  )
              )
            ),
            SizedBox(height: getVerticalSize(20)),
            Container(
              height: 300,
              child: ListView.separated(
                  itemBuilder: (context, index) => buildHorizontalCard(item: new MovieInfo(movies[index])),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, _) => SizedBox(width: getHorizontalSize(16)),
                  itemCount: movies.length
              )
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: getPadding(left: 16),
                    child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Latest",
                              style: AppStyle.txtPoppinsBold30
                          ),
                          TextSpan(
                              text: ".",
                              style: AppStyle.txtPoppinsBold30Red
                          )
                        ]),
                        textAlign: TextAlign.left
                    )
                )
            ),
            Container(
              height: 190,
              child: ListView.separated(
                  itemBuilder: (context, index) => VerticalMovieCard(item: new MovieInfo(movies[index])),
                  separatorBuilder: (context, _) => SizedBox(height: getVerticalSize(16),),
                  itemCount: movies.length,
              ),
            )
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
              icon: Icon(Icons.bookmark),
              label: "bookmark"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings"
          ),
        ],
      )
    );
  }

  Widget buildHorizontalCard({required MovieInfo item}) => InkWell(
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetail(item: item))),
      child: Container(
    width: getHorizontalSize(300),
    height: getVerticalSize(266),
    child: Column(
      children: [
        AspectRatio(
          aspectRatio: 3/2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(item.urlImage, fit: BoxFit.fill, filterQuality: FilterQuality.high,)
          )
        ),
        Padding(
            padding: getPadding(all: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtPoppinsBold20,
                maxLines: 2,
              )
            )
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                TextSpan( text: item.rating.toString()),
                WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                WidgetSpan(child: RatingBarIndicator(
                  itemBuilder: (context, index) => Icon(Icons.star_rounded, color: ColorConstant.red900),
                  itemCount: 5,
                  rating: item.rating,
                  itemSize: getSize(28),
                  unratedColor: ColorConstant.gray700,
                ),
                )
              ],
            style: AppStyle.txtPoppinsMedium22
          ))
        )
      ],
    ),
  ));

}


