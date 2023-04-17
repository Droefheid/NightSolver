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
import '../utils/custom_widgets.dart';
import '../utils/size_utils.dart';
import 'movie_details.dart';

class Recommendation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecommendationState();
}

class RecommendationState extends State<Recommendation> {
  final apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
  List<dynamic> movies = [];
  final user = FirebaseAuth.instance.currentUser!;
  void handleSelectedGenre(String genre, bool onSelect) {

  }

  Future<void> getData() async {
    List<dynamic> Recmovie = [];
    List<dynamic> moviesData = [];
    List<dynamic> RecmovieIds = [];
    final snapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    if (snapshot.data()!['recommended'] != null) {
      for (var item in snapshot.data()!['recommended'].entries) {
        Recmovie.addAll(item.value);
      }
    }
    for(int i=0;i<Recmovie.length;i++){
      RecmovieIds.add(Recmovie[i]["id"]);
    }
    for(var movieId in RecmovieIds){
      final url = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey'));
      if(url.statusCode == 200){
        final Map<String, dynamic> finalCard =
        json.decode(url.body);
        moviesData.add(finalCard);
      }
    }

    setState(() {
      movies = moviesData;
    });
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
    final List<String> genres = ["ALL"," ACTION", "ADVENTURE", "ANIMATION", "COMEDY", "CRIME", "DOCUMENTARY", "DRAMA", "FAMILY", "FANTASY", "HISTORY", "HORROR", "MUSIC", "MYSTERY", "ROMANCE", "SCIENCE FICTION", "THRILLER", "TV MOVIE", "WAR", "WESTERN"];
    int currentIndex = 2;
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      appBar: AppBar(
          backgroundColor: ColorConstant.gray900,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.red900),
              onPressed: () => Navigator.of(context).pop()),
          title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Movies For ",
                    style: AppStyle.txtPoppinsBold30
                ),
                TextSpan(
                  text: "You",
                  style: AppStyle.txtPoppinsItalic30red
                ),
                TextSpan(
                    text: ".",
                    style: AppStyle.txtPoppinsBold30Red
                )
              ]),
              textAlign: TextAlign.left
          ),
          actions: [
            IconButton(onPressed: null, icon: Icon(Icons.help_outline_rounded, color: ColorConstant.red900))
          ],
      ),
        body: Column(
          children: [
            Padding(
                padding: getPadding(left: 16),
                child: Container(
                  height: getVerticalSize(45),
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => GenreButton(
                      title: genres[index],
                      isSelected: false,
                      onSelectedGenre: handleSelectedGenre,
                    ),
                    separatorBuilder: (context, _) => SizedBox(width: getHorizontalSize(8)),
                    itemCount: genres.length),
                )
            ),
            Padding(
                padding: getPadding(top: 16) ,
                child: Container(
                    height: getVerticalSize(589),
                    child: Stack(children: [
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            mainAxisSpacing:getVerticalSize(2),
                            crossAxisSpacing: getHorizontalSize(0)
                        ),
                        itemBuilder: (context, index) => ShortVerticalCard(item: new MovieInfo(movies[index])),
                        itemCount: movies.length,
                      ),
                      Positioned(
                          top: getVerticalSize(541),
                          left: getHorizontalSize(350),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent)
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/salons'),
                              child: Icon(Icons.add_circle_sharp, color: ColorConstant.red900, size: getSize(38),))
                      )
                    ])
                )
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
        )
    );
  }

  Widget ShortVerticalCard({required MovieInfo item}) => InkWell(
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetail(item: item))),
    child: Column(
      children: [
        Container(
            height: getVerticalSize(273),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack( children:[
                  Image.network(item.urlImage, fit: BoxFit.fill, filterQuality: FilterQuality.high),
                  Positioned(
                      right: getHorizontalSize(-1),
                      child: IconButton(onPressed: null, icon: Icon(Icons.bookmark_border, color: ColorConstant.whiteA700))
                  )
                ])
            )
        ),
        SizedBox(height: getVerticalSize(16),),
        Padding(
            padding: getPadding(left: 10),
            child: Container(
                width: getHorizontalSize(160),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                    style: AppStyle.txtPoppinsSemiBold18,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    )
                )
            )
        ),
        Padding(
            padding: getPadding(left: 27),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                    TextSpan(
                        children: [
                          TextSpan(text: item.rating.toString()),
                          WidgetSpan(child: Icon(Icons.star_rounded, color: ColorConstant.red900,))
                        ],
                      style: AppStyle.txtPoppinsMedium18
                    )
                )
            )
        )
      ],
    )
  );

}