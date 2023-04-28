import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:night_solver/screens/movie_details.dart';
import 'package:http/http.dart' as http;
import 'package:night_solver/theme/app_decoration.dart';
import 'package:night_solver/utils/color_constant.dart';
import 'package:night_solver/utils/constants.dart';
import '../theme/app_style.dart';
import '../utils/custom_widgets.dart';
import '../utils/movie_info.dart';
import '../utils/size_utils.dart';

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
  List<dynamic> trending_movies = [];
  List<dynamic> latest_movies = [];
  final controller = ScrollController();
  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  void onTabTapped(int index) {
    if (index==1) Navigator.pushNamed(context, '/search');
    if (index==2) Navigator.pushNamed(context, '/salons');
    if (index==3) Navigator.pushNamed(context, '/friends');
    if (index==4) Navigator.pushNamed(context, '/movieList');
    if (index==5) Navigator.pushNamed(context, '/settings');
  }

  Future<void> getData() async {
    final trending_movies_url =
        'https://api.themoviedb.org/3/trending/movie/week?api_key=' +
            Constants.theMovieDb;
    final trending_movies_response =
    await http.get(Uri.parse(trending_movies_url));
    final Map<String, dynamic> trending_movies_responseData =
    json.decode(trending_movies_response.body);
    final user = FirebaseAuth.instance.currentUser!;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    List<dynamic>? moviesId = null;
    if(snapshot.data() != null){
      moviesId = snapshot.data()!['movies_id'];
    }

    List<dynamic> latest_movies_data = [];

    if (moviesId != null) {
      for (String movieId in moviesId) {
        final response = await http.get(Uri.parse(
            'https://api.themoviedb.org/3/movie/$movieId?api_key=' +
                Constants.theMovieDb));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          responseData['can_delete'] = true;
          latest_movies_data.add(responseData);
        }
      }
    }

    final latest_movies_url =
        'https://api.themoviedb.org/3/discover/movie?api_key=' +
            Constants.theMovieDb +
            '&sort_by=release_date.desc&vote_count.gte=100';
    final latest_movies_response =
    await http.get(Uri.parse(latest_movies_url));
    final Map<String, dynamic> latest_movies_responseData =
    json.decode(latest_movies_response.body);

    for (int i = 0; i < latest_movies_responseData['results'].length; i++) {
      final movie = latest_movies_responseData['results'][i];
      final index =
      latest_movies_data.indexWhere((m) => m['id'] == movie['id']);
      if (index != -1) {
        latest_movies_responseData['results'][i] = latest_movies_data[index];
      }
    }

    setState(() {
      trending_movies = trending_movies_responseData['results'];
      latest_movies = latest_movies_responseData['results'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }



  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
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
              Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) => ShortVerticalCard(context: context ,item: new MovieInfo(trending_movies[index])),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, _) => SizedBox(width: getHorizontalSize(6)),
                      itemCount: trending_movies.length
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
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) => VerticalMovieCard(item: new MovieInfo(latest_movies[index])),
                  separatorBuilder: (context, _) => SizedBox(height: getVerticalSize(16),),
                  itemCount: latest_movies.length,
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
                padding: getPadding(left: 16, right: 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtPoppinsBold20,
                      maxLines: 1,
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


