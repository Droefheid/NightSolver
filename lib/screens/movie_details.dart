import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:night_solver/screens/home_screen.dart';
import 'package:night_solver/screens/recommendation_screen.dart';
import 'package:night_solver/screens/search_screen.dart';
import 'package:night_solver/screens/settings_screen.dart';
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


  MovieDetail({super.key, required this.item});

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  final apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
  Color mainColor = const Color(0xffffffff);
  final user = FirebaseAuth.instance.currentUser!;

  void onTabTapped(int index) {
    if (index==0) Navigator.pushNamed(context, '/');
    if (index==1) Navigator.pushNamed(context, '/search');
    if (index==2) Navigator.pushNamed(context, '/recommendation');
    if (index==3) Navigator.pushNamed(context, '/movieList');
    if (index==4) Navigator.pushNamed(context, '/settings');
  }

  Future<List> recommended(String id) async {
    List<dynamic> RecList = [];
    final result = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$id/recommendations?api_key=$apiKey&language=en-US&page=1'));
    if (result.statusCode == 200) {
      final Map<String, dynamic> resultData = json.decode(result.body);
      ////check if the movie recommended is not in the seen movies list
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      for (int i = 0; i < resultData['results'].length; i++) {
        if (snapshot.data()!['movies_id'] != null) {
          if (!(snapshot
              .data()!['movies_id']
              .contains(resultData["results"][i]["id"].toString()))) {
            if (resultData['results'][i]['genre_ids'].length != 0) {
              final recommended = {
                'id': resultData["results"][i]["id"].toString(),
                'genre': resultData['results'][i]['genre_ids'][0].toString()
              };
              RecList.add(recommended);
            }
          }
        }
      }
    }
    return RecList;
  }

  Future addMovie(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    print(widget.item.id);
    List<dynamic> recommendedMovies = await recommended(widget.item.id);
    docRef.set({
      'recommended': {
        widget.item.id: recommendedMovies,
      },
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
    docRef.update({
      'recommended': FieldValue.arrayRemove([movieId]),
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
      Map<String, dynamic> providers = data['results'];
      Map<String, dynamic> filteredProviders = {};
      providers.forEach((key, value) {
        String link = value['link'];
        if (link.contains('locale=BE')) {
          filteredProviders[key] = value;
        }
      });
      setState(() {
        widget.providers = filteredProviders;
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
            'No providers available in Belgium',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
        ],
      );
    }

    List<Widget> providerWidgets = [];
    Set<String> addedProviders = Set();

    widget.providers.forEach((key, value) {

        if (value['flatrate'] != null && value['flatrate'].isNotEmpty) {
          value['flatrate'].forEach((flatValue) {
            if (flatValue['provider_name'] != null &&
                !addedProviders.contains(flatValue['provider_name'])) {
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
        if (value['rent'] != null && value['rent'].isNotEmpty) {
          value['rent'].forEach((rentValue) {
            if (rentValue['provider_name'] != null &&
                !addedProviders.contains(rentValue['provider_name'])) {
              addedProviders.add(rentValue['provider_name']);
              providerWidgets.add(
                Image.network(
                  'https://image.tmdb.org/t/p/w92${rentValue['logo_path']}',
                  width: 60,
                ),
              );
            }
          });
        }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Providers',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              color: ColorConstant.gray900,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: getVerticalSize(500),
                    width: getHorizontalSize(561),
                    child: Image.network(
                      widget.item.urlImage,
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: getVerticalSize(20)),
                  Text(
                    widget.item.title,
                    style: AppStyle.txtPoppinsBold30,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getVerticalSize(20)),
                  Text.rich(TextSpan(children: [
                    WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                    TextSpan(text: widget.item.rating.toString()),
                    WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                    WidgetSpan(
                      child: RatingBarIndicator(
                        itemBuilder: (context, index) =>
                            Icon(Icons.star_rounded, color: ColorConstant.red900),
                        itemCount: 5,
                        rating: widget.item.rating,
                        itemSize: getSize(28),
                        unratedColor: ColorConstant.gray700,
                      ),
                    )
                  ], style: AppStyle.txtPoppinsMedium22)),
                  SizedBox(height: getVerticalSize(20)),
                  buildProviderList(),
                  SizedBox(height: getVerticalSize(20)),
                  Container(
                    width: getHorizontalSize(379),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorConstant.gray800,
                    ),
                    padding: EdgeInsets.all(getSize(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Synopsis",
                          style: AppStyle.txtPoppinsBold20,
                        ),
                        SizedBox(height: getVerticalSize(10)),
                        Text(
                          widget.item.synopsis,
                          style: AppStyle.txtPoppinsRegular13,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getVerticalSize(20)),
                ],
              ),
            ),
            Positioned(
              top: getVerticalSize(20),
              left: getHorizontalSize(16),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ColorConstant.red900,
                  size: 45,
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
            Positioned(
              top: getVerticalSize(20),
              right: getHorizontalSize(16),
              child: InkWell(
                onTap: () {
                  if (widget.item.canDelete) {
                    deleteMovie(context, widget.item.id);
                  } else {
                    addMovie(context);
                  }
                },
                child: Container(
                  width: getSize(45),
                  height: getSize(45),
                  decoration: BoxDecoration(
                    color: widget.item.canDelete ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(getSize(45)),
                    border: Border.all(
                      color: Colors.white,
                      width: getSize(2),
                    ),
                  ),
                  child: Icon(
                    Icons.bookmark,
                    color: Colors.white,
                    size: getSize(30),
                  ),
                ),
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
        currentIndex: widget.currentIndex,
        onTap: (index) => setState(() {
          widget.currentIndex = index;
          onTabTapped(index);
        }),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.recommend), label: "Recommendation"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: "bookmark"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
