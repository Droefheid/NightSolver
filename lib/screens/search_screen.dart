import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:night_solver/screens/home_screen.dart';
import 'package:night_solver/screens/recommendation_screen.dart';
import 'package:night_solver/screens/settings_screen.dart';

import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import '../utils/constants.dart';
import '../utils/custom_widgets.dart';
import '../utils/genre_utils.dart';
import '../utils/movie_info.dart';
import '../utils/size_utils.dart';
import 'movie_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final List<String> genres = ["ALL","ACTION", "ADVENTURE", "ANIMATION", "COMEDY", "CRIME", "DOCUMENTARY", "DRAMA", "FAMILY", "FANTASY", "HISTORY", "HORROR", "MUSIC", "MYSTERY", "ROMANCE", "SCIENCE FICTION", "THRILLER", "TV MOVIE", "WAR", "WESTERN"];
  List<dynamic> searched_movies = [];
  List<dynamic> filtered_movies_genre = [];

  int nb_movies = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void _onSearchChanged(String value) async {
    try {
      if (value != '') {
        final url = 'https://api.themoviedb.org/3/search/movie?api_key='+Constants.theMovieDb+'&query=$value';
        final response = await http.get(Uri.parse(url));
        final responseData = json.decode(response.body);
        if (responseData['results'] != null) {
          setState(() {
            searched_movies = responseData['results'];
            nb_movies = searched_movies.length;
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

  void handleSelectedGenre(String genre, bool onSelect) {

    int id = genreToId(genre);
    List<dynamic> filteredMovies;
    if (id != -1 && !searched_movies.isEmpty && onSelect){

      // filter movies based on selected genre
      List<dynamic> filteredMovies = searched_movies
          .where((movie) =>
          movie['genre_ids'].contains(id))
          .toList();

      setState(() {
        searched_movies = filteredMovies;
        nb_movies = filteredMovies.length;
      });
    }else if(!onSelect){
      getData();
    }
  }

  Future<void> getData() async {
    final url = 'https://api.themoviedb.org/3/trending/movie/week?api_key=9478d83ca04bd6ee25b942dd7a0ad777';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> responseData = json.decode(response.body);
    setState(() {
      searched_movies = responseData['results'];
    });
  }


  void onTabTapped(int index) {
    if (index==0) Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen()));
    if (index==2) Navigator.of(context).push(MaterialPageRoute(builder: (_) => Recommendation()));
    if(index==3) Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieList()));
    if(index==4) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 1;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    text: "Search",
                    style: AppStyle.txtPoppinsBold30
                ),
                TextSpan(
                    text: ".",
                    style: AppStyle.txtPoppinsBold30Red
                )
              ]),
              textAlign: TextAlign.left
          )
      ),
        body: Column(children:[
          TextFormField(
            controller: _controller,
            onChanged: _onSearchChanged,
            style: AppStyle.txtPoppinsMedium18,
            decoration: InputDecoration(
            prefixIcon: IconButton(
                icon: Icon(Icons.search, color: ColorConstant.whiteA700,),onPressed: null),
                hintText: "Search",
                hintStyle: AppStyle.txtPoppinsMedium18Grey,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                filled: true,
                fillColor: ColorConstant.gray90001
            ),
          ),
          SizedBox(height: getVerticalSize(16)),
          Container(
            height: getVerticalSize(45),
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => GenreButton(
                    title: genres[index],
                    onSelectedGenre: handleSelectedGenre,
                ),
                separatorBuilder: (context, _) => SizedBox(width: getHorizontalSize(8)),
                itemCount: genres.length),
          ),
          SizedBox(height: getVerticalSize(16)),
          Align(
              child: Text("Search results (" + nb_movies.toString() + ")", style: AppStyle.txtPoppinsMedium18),
              alignment: Alignment.centerLeft,
          ),
          SizedBox(height: getVerticalSize(20)),
          Container(
            height: getVerticalSize(462),
              child: ListView.separated(
                  itemBuilder: (context, index) => VerticalMovieCard(item: new MovieInfo(searched_movies[index])),
                  separatorBuilder: (context, _) => SizedBox(height: getVerticalSize(16)),
                  itemCount: searched_movies.length
              )
          ),
        ]
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
}