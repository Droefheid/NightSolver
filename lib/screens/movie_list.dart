import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:night_solver/screens/home_screen.dart';
import 'package:night_solver/screens/recommendation_screen.dart';
import 'package:night_solver/screens/search_screen.dart';
import 'package:night_solver/screens/settings_screen.dart';
import 'package:night_solver/theme/app_style.dart';
import 'package:night_solver/utils/custom_widgets.dart';
import '../utils/color_constant.dart';
import '../utils/constants.dart';
import '../utils/movie_info.dart';
import '../utils/size_utils.dart';
import 'movie_details.dart';

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<dynamic> movies = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> getData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    List<dynamic>? moviesId = snapshot.data()!['movies_id'];

    List<dynamic> moviesData = [];

    if (moviesId != null) {
      for (String movieId in moviesId) {
        final response = await http.get(Uri.parse(
            'https://api.themoviedb.org/3/movie/$movieId?api_key='+Constants.theMovieDb));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          responseData['can_delete'] = true;
          moviesData.add(responseData);
        }
      }
    }

    setState(() {
      movies = moviesData;
    });
  }

  void _onSearchChanged(String value) async {
    try {
      if (value != '') {
        final url =
            'https://api.themoviedb.org/3/search/movie?api_key='+Constants.theMovieDb+'&query=$value';
        final response = await http.get(Uri.parse(url));
        final responseData = json.decode(response.body);
        resetScrollPosition();
        if (responseData['results'] != null) {
          setState(() {
            movies = responseData['results'];
          });
        } else {
          print('Response data is null');
        }
      } else {
        await getData();
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

  void resetScrollPosition() {
    _scrollController.jumpTo(0.0);
  }

  void onTabTapped(int index) {
    if(index==0) Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen()));
    if(index==1) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen()));
    if(index==2) Navigator.of(context).push(MaterialPageRoute(builder: (_) => Recommendation()));
    if(index==4) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 3;
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
                  text: "Bookmarks",
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
          padding: getPadding(left: 16, top: 16),
          child: ListView.separated(
          itemBuilder: (context, index) => VerticalMovieCard(item: new MovieInfo(movies[index])),
          separatorBuilder: (context, _) => SizedBox(height: getVerticalSize(16),),
          itemCount: movies.length
      )),
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
    )]),
    );
  }
}

class MovieCell extends StatelessWidget {
  final dynamic movie;
  Color mainColor = const Color(0xff3C3261);
  var image_url = 'https://image.tmdb.org/t/p/w500/';

  MovieCell(this.movie);

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
                  image: movie['poster_path'] != null
                      ? new DecorationImage(
                      image: new NetworkImage(
                          image_url + movie['poster_path']),
                      fit: BoxFit.cover)
                      : null,
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
                  child: new Column(
                    children: [
                      new Text(
                        movie['title'] ?? 'Title Not Found',
                        style: new TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Arvo',
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ),
                      new Padding(padding: const EdgeInsets.all(2.0)),
                      new Text(
                        movie['overview'] ?? 'Overview Not Found',
                        maxLines: 3,
                        style: new TextStyle(
                            color: const Color(0xff8785A4), fontFamily: 'Arvo'),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )),
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

class SearchBar extends StatefulWidget {
  final List<dynamic> movieList;

  SearchBar(this.movieList);

  @override
  _SearchBarState createState() => _SearchBarState(movieList);
}

class _SearchBarState extends State<SearchBar> {
  List<dynamic> movieList;

  _SearchBarState(this.movieList);

  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search movies...",
          suffixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
