import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/salons.dart';
import 'package:night_solver/utils/movie_info.dart';
import 'package:http/http.dart' as http;
import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import '../utils/constants.dart';
import '../utils/custom_widgets.dart';
import '../utils/genre_utils.dart';
import '../utils/size_utils.dart';
import 'movie_details.dart';

class Recommendation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecommendationState();
}

class RecommendationState extends State<Recommendation> {
  final List<String> _selectedGenres = ["ALL"];
  List<dynamic> movies = [];
  List<dynamic> movies_to_filter = [];

  final user = FirebaseAuth.instance.currentUser!;
  bool no_recommendations = false;

  void onSelectedGenre(String genre, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (genre == "ALL") {
          _selectedGenres.clear();
        } else if (_selectedGenres.contains("ALL")) {
          _selectedGenres.remove("ALL");
        }
        _selectedGenres.add(genre);
      } else {
        _selectedGenres.remove(genre);
        if (_selectedGenres.isEmpty) {
          _selectedGenres.add("ALL");
        }
      }
    });
    List<int> selectedGenreIds = _selectedGenres
        .map((genre) => genreToId(genre))
        .where((id) => id != -1)
        .toList();

    if (!selectedGenreIds.isEmpty && !movies.isEmpty && !movies_to_filter.isEmpty) {
      List<dynamic> filteredMovies = movies_to_filter.where((movie) {
        List<dynamic> genres = movie['genres'];
        return selectedGenreIds.every((id) => genres.any((genre) => genre['id'] == id));
      }).toList();
      setState(() {
        movies = filteredMovies;
        no_recommendations = movies.isEmpty;
      });
    } else {
      getData();
    }
  }

  Future<void> getData() async {
    List<dynamic> moviesData = [];
    List<dynamic> RecmovieIds = [];
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    Map<String,dynamic> Res = snapshot.data()!['recommended'];
    for( List<dynamic> Values in Res.values){
      //check of list not empty
      if(Values.length !=0){
        for(int i=0; i<Values.length;i++){
          //check if the movie recommended is not in the seen movies list
          if(!(snapshot.data()!['movies_id'].contains(Values[i]['id'].toString()))){
            //Check if recommended list is unique
            if(!(RecmovieIds.contains(Values[i]['id']))){
              // add recommended movies
              RecmovieIds.add(Values[i]['id']);
              moviesData.add(Values[i]);
            }
          }
        }
      }
    }

    setState(() {
      movies = moviesData;
      movies_to_filter = moviesData;
      no_recommendations = movies.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void onTabTapped(int index) {
    if (index == 0) Navigator.pushNamed(context, '/');
    if (index == 1) Navigator.pushNamed(context, '/search');
    if (index == 2) Navigator.pushNamed(context, '/recommendation');
    if (index == 3) Navigator.pushNamed(context, '/friends');
    if (index == 4) Navigator.pushNamed(context, '/movieList');
    if (index == 5) Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    final List<String> genres = [
      "ALL",
      "ACTION",
      "ADVENTURE",
      "ANIMATION",
      "COMEDY",
      "CRIME",
      "DOCUMENTARY",
      "DRAMA",
      "FAMILY",
      "FANTASY",
      "HISTORY",
      "HORROR",
      "MUSIC",
      "MYSTERY",
      "ROMANCE",
      "SCIENCE FICTION",
      "THRILLER",
      "TV MOVIE",
      "WAR",
      "WESTERN"
    ];
    int currentIndex = 2;
    return Scaffold(
        backgroundColor: ColorConstant.gray900,
        appBar: AppBar(
          backgroundColor: ColorConstant.gray900,
          leading: IconButton(
              icon: ImageIcon(
                AssetImage("assets/icons/back_arrow_red.png"),
                color: ColorConstant.red900,
              ),
              onPressed: () => Navigator.of(context).pop()),
          title: RichText(
              text: TextSpan(children: [
                TextSpan(text: "Movies For ", style: AppStyle.txtPoppinsBold30),
                TextSpan(text: "You", style: AppStyle.txtPoppinsItalic30red),
                TextSpan(text: ".", style: AppStyle.txtPoppinsBold30Red)
              ]),
              textAlign: TextAlign.left),
          actions: [
            //IconButton(onPressed: null, icon: Icon(Icons.help_outline_rounded, color: ColorConstant.red900))
          ],
        ),
        body: Column(
          children: [
            Padding(
                padding: getPadding(left: 16, bottom: 16),
                child: Container(
                  height: getVerticalSize(45),
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => GenreButton(
                            title: genres[index],
                            onSelectedGenre: onSelectedGenre,
                            isSelected: _selectedGenres.contains(genres[index]),
                          ),
                      separatorBuilder: (context, _) =>
                          SizedBox(width: getHorizontalSize(8)),
                      itemCount: genres.length),
                )),
            movies.isEmpty && no_recommendations ?
            Center(child:
              Text(
                'Sorry, no recommendations are available.',
                style: AppStyle.txtPoppinsMedium18,
              ),
            ) : movies.isEmpty ?
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorConstant.red900),
              ),
            ) :
            Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: getVerticalSize(10),
                      crossAxisSpacing: 0),
                  itemBuilder: (context, index) => ShortVerticalCard(context: context, item: new MovieInfo(movies[index])),
                  itemCount: movies.length,
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
                icon: ImageIcon(AssetImage("assets/icons/home_filled.png")),
                label: "Home"),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icons/search_empty.png")),
                label: "Search"),
            BottomNavigationBarItem(
                icon: ImageIcon(
                    AssetImage("assets/icons/recomandation_filled_point.png")),
                label: "Recommendation"),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icons/friends_filled.png")),
                label: "Friends"),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icons/bookmark_empty.png")),
                label: "bookmark"),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icons/settings_empty.png")),
                label: "Settings"),
          ],
        ));
  }

}
