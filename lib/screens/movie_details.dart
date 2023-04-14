import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:night_solver/screens/home_screen.dart';
import 'package:night_solver/theme/app_style.dart';
import 'package:night_solver/utils/color_constant.dart';
import 'package:night_solver/utils/movie_info.dart';
import 'package:night_solver/utils/size_utils.dart';
import 'dart:convert';

import 'custom_toast.dart';
import 'movie_list.dart';

class MovieDetail extends StatefulWidget {
  final MovieInfo item;
  int currentIndex = 2;

  var image_url = 'https://image.tmdb.org/t/p/w500/';
  var apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
  Map<String, dynamic> providers = {};

  MovieDetail({
    super.key,
    required this.item
  });

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  Color mainColor = const Color(0xffffffff);
  void onTabTapped(int index) {
    if(index == 0) Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) =>  HomeScreen()));
    if(index==3) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) =>  MovieList()));
    }
  }

  Future addMovie(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    docRef.set({
      'movies_id': FieldValue.arrayUnion([widget.item.id]),
    }, SetOptions(merge: true));
    CustomToast.showToast(context, 'Movie added to watched list');
    // Navigate back to the previous screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context, true);
  }

  Future deleteMovie(BuildContext context, String movieId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    docRef.update({
      'movies_id': FieldValue.arrayRemove([movieId]),
    });
    CustomToast.showToast(context, 'Movie removed from watched list');
    // Navigate back to the previous screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context, true);
  }

  Future<void> getWatchProviders() async {
    var url =
        'https://api.themoviedb.org/3/movie/${widget.item.id}/watch/providers?api_key=${widget.apiKey}';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        widget.providers = data['results'];
      });
    } else {
      throw Exception('Failed to load providers');
    }
  }

  Widget buildProviderList() {
    if (widget.providers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'No providers available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
        ],
      );
    }

    List<Widget> providerWidgets = [];
    Set<String> addedProviders = Set();

    widget.providers.forEach((key, value) {
      if (value['rent'] != null && value['rent'].isNotEmpty) {
        value['rent'].forEach((rentValue) {
          if (rentValue['provider_name'] != null && !addedProviders.contains(rentValue['provider_name'])) {
            addedProviders.add(rentValue['provider_name']);
            providerWidgets.add(
              Image.network(
                'https://image.tmdb.org/t/p/w92${rentValue['logo_path']}',
                width: 60,
              ),
            );
          }
        });
      } else {
        if (value['flatrate'] != null && value['flatrate'].isNotEmpty) {
          value['flatrate'].forEach((flatValue) {
            if (flatValue['provider_name'] != null && !addedProviders.contains(flatValue['provider_name'])) {
              addedProviders.add(flatValue['provider_name']);
              providerWidgets.add(
                Image.network(
                  'https://image.tmdb.org/t/p/w92${flatValue['logo_path']}',
                  width: 60,
                ),
              );
            }
          });
        }

      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Providers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: providerWidgets.map((widget) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: widget,
              );
            }).toList(),
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    getWatchProviders();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      /*appBar: new AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),*/
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            color: ColorConstant.gray900,
          ),
          Container(
            height: getVerticalSize(581),
            width: getHorizontalSize(561),
            child: Image.network(
                widget.item.urlImage,
              height: MediaQuery.of(context).size.height *0.5,
              fit: BoxFit.cover,
            ),
          ),
          /*const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              Color(0x111111)
            ],
            begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 0.5]
            ),
          ))),*/
          Positioned(
            child: Text(widget.item.title, style: AppStyle.txtPoppinsBold30, textAlign: TextAlign.center,),
            top: getVerticalSize(540),
            left: getHorizontalSize(32),
          ),
          Positioned(
              child: Text.rich(
                  TextSpan(children: [
                    WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                    TextSpan( text: widget.item.rating.toString()),
                    WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                    WidgetSpan(child: RatingBarIndicator(
                      itemBuilder: (context, index) => Icon(Icons.star_rounded, color: ColorConstant.red900),
                      itemCount: 5,
                      rating: widget.item.rating,
                      itemSize: getSize(28),
                      unratedColor: ColorConstant.gray700,
                    ),
                    )
                  ],
                      style: AppStyle.txtPoppinsMedium22
                  )
              ),
            top: getVerticalSize(600),
          ),
          Positioned(
              child: Container(
                  height: getVerticalSize(120),
                  width: getHorizontalSize(379),
                  child: Text(
                      widget.item.synopsis,
                      style: AppStyle.txtPoppinsRegular13
                  )
              ),
            top: getVerticalSize(660),
            left: getHorizontalSize(16),
          ),
          IconButton(onPressed: () => Navigator.pop(context, true), icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900, size: 45)),
          Positioned(
              child: IconButton(
                icon: Icon(Icons.bookmark_border, color: ColorConstant.whiteA700, size: 45,),
                onPressed: () => addMovie(context),
              ),
            right: getHorizontalSize(16),
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
        currentIndex: widget.currentIndex,
        onTap: (index) => setState(() {
          widget.currentIndex = index;
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
