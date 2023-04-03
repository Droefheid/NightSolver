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
import 'package:night_solver/theme/app_decoration.dart';
import 'package:night_solver/utils/color_constant.dart';
import 'package:night_solver/utils/image_constant.dart';

import '../theme/app_style.dart';
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
  void signOut(){
    FirebaseAuth.instance.signOut();
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
                            style: TextStyle(
                                color: ColorConstant.whiteA700,
                                fontSize: getFontSize(30),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700
                            )
                        ),
                        TextSpan(
                            text: ".",
                            style: TextStyle(
                                color: ColorConstant.redA700,
                                fontSize: getFontSize(33),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700
                            )
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
                              style: TextStyle(
                                  color: ColorConstant.whiteA700,
                                  fontSize: getFontSize(30),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700
                              )
                          ),
                          TextSpan(
                              text: ".",
                              style: TextStyle(
                                  color: ColorConstant.redA700,
                                  fontSize: getFontSize(33),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700
                              )
                          )
                        ]),
                        textAlign: TextAlign.left
                    )
                )
            ),
            Container(
              height: 300,
              child: ListView.separated(
                  itemBuilder: (context, index) => buildVerticalCard(item: new MovieInfo(movies[index])),
                  separatorBuilder: (context, _) => SizedBox(width: getVerticalSize(16)),
                  itemCount: movies.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildHorizontalCard({required MovieInfo item}) => Container(
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
              alignment: Alignment.topCenter,
              child: Text(
                item.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtPoppinsBold20,
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
            style: TextStyle(
                color: ColorConstant.whiteA700,
                fontSize: getFontSize(22),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700
            ),
          ))
        )
      ],
    ),
  );

  Widget buildVerticalCard({required MovieInfo item}) => Container(
    width: getHorizontalSize(379),
    height: getVerticalSize(273),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(item.urlImage),
        Column(
          children: [
            Text(
              item.title,
              style: TextStyle(
                  color: ColorConstant.whiteA700,
                  fontSize: getFontSize(20),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700
              ),
            ),

            Text.rich(
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
                  style: TextStyle(
                      color: ColorConstant.whiteA700,
                      fontSize: getFontSize(22),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700
                  ),
                )
            ),
            Expanded(child:
            Text(
              item.synopsis,
              style: TextStyle(
                  color: ColorConstant.gray90000,
                  fontSize: getFontSize(22),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis
              ),
            )
            )
          ])
      ],
    ),
  );
}

class MovieInfo {
  final String movies_url = "https://image.tmdb.org/t/p/w500/";
  late String title;
  late String urlImage;
  late double rating;
  late String synopsis;
  late List<dynamic> genres;
  MovieInfo(dynamic movie) {
    this.title = movie["title"];
    this.urlImage = movies_url + movie["poster_path"];
    this.rating = CustomRound(movie["vote_average"]/2);
    this.synopsis = movie["overview"];
    this.genres = movie["genre_ids"];
  }
}
