import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../theme/app_style.dart';
import '../utils/color_constant.dart';
import '../utils/constants.dart';
import '../utils/custom_widgets.dart';
import '../utils/genre_utils.dart';
import '../utils/movie_info.dart';
import '../utils/size_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
  List<dynamic> searched_movies = [];
  final List<String> _selectedGenres = ["ALL"];
  bool no_result = false;
  int nb_movies = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void _filterMoviesByGenre() async {
    List<int> selectedGenreIds = _selectedGenres
        .map((genre) => genreToId(genre))
        .where((id) => id != -1)
        .toList();

    if (!selectedGenreIds.isEmpty) {
      String genreIds = selectedGenreIds.join(',');

      String url = 'https://api.themoviedb.org/3/discover/movie?api_key=' +
          Constants.theMovieDb +
          '&with_genres=${genreIds}';

      try {
        final response = await http.get(Uri.parse(url));
        final responseData = json.decode(response.body);
        if (responseData['results'] != null) {
          final user = FirebaseAuth.instance.currentUser!;
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          List<dynamic>? moviesId = snapshot.data()!['movies_id'];

          List<dynamic> filteredMoviesData = [];
          List<Future<Map<String, dynamic>>> futures = [];

          for (var movie in responseData['results']) {
            futures.add(http.get(Uri.parse(
                'https://api.themoviedb.org/3/movie/${movie['id']}?api_key=' +
                    Constants.theMovieDb))
                .then((response) => jsonDecode(response.body)));
          }

          List<Map<String, dynamic>> responses = await Future.wait(futures);

          for (int i = 0; i < responses.length; i++) {
            var response = responses[i];
            var movie = responseData['results'][i];
            if (moviesId != null && moviesId.contains(movie['id'].toString())) {
              final Map<String, dynamic> movieData = response;
              movieData['can_delete'] = true;
              filteredMoviesData.add(movieData);
            } else {
              final Map<String, dynamic> movieData = response;
              movieData['can_delete'] = false;
              filteredMoviesData.add(movieData);
            }
          }
          setState(() {
            searched_movies = filteredMoviesData;
            nb_movies = searched_movies.length;
          });
        } else {
          setState(() {
            searched_movies = [];
            nb_movies = 0;
          });
        }
      } catch (error) {
        print('Error occurred: $error');
      }
    }
  }


  void _onSearchChanged(String value) async {
    try {
      _selectedGenres.clear();
      _selectedGenres.add("ALL");
      if (value != '') {
        final url = 'https://api.themoviedb.org/3/search/movie?api_key=' +
            Constants.theMovieDb +
            '&query=$value';

        final response = await http.get(Uri.parse(url));
        final responseData = json.decode(response.body);
        if (responseData['results'] != null) {
          final user = FirebaseAuth.instance.currentUser!;
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          List<dynamic>? moviesId = snapshot.data()!['movies_id'];

          List<dynamic> searchedMoviesData = [];

          for (var movie in responseData['results']) {
            if (moviesId != null && moviesId.contains(movie['id'].toString())) {
              final response = await http.get(Uri.parse(
                  'https://api.themoviedb.org/3/movie/${movie['id']}?api_key=' + Constants.theMovieDb));

              if (response.statusCode == 200) {
                final Map<String, dynamic> movieData = json.decode(response.body);
                movieData['can_delete'] = true;
                searchedMoviesData.add(movieData);
              }
            } else {
              movie['can_delete'] = false;
              searchedMoviesData.add(movie);
            }
          }

          setState(() {
            searched_movies = searchedMoviesData;
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


  Future<void> getData() async {
    final url = 'https://api.themoviedb.org/3/trending/movie/week?api_key=${Constants.theMovieDb}';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> responseData = json.decode(response.body);

    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    List<dynamic>? moviesId = snapshot.data()!['movies_id'];

    if (moviesId != null) {
      for (int i = 0; i < responseData['results'].length; i++) {
        final movie = responseData['results'][i];
        if (moviesId.contains(movie['id'].toString())) {
          final response = await http.get(Uri.parse(
              'https://api.themoviedb.org/3/movie/${movie['id']}?api_key=${Constants.theMovieDb}'));
          if (response.statusCode == 200) {
            final Map<String, dynamic> movieData = json.decode(response.body);
            movieData['can_delete'] = true;
            responseData['results'][i] = movieData;
          }
        }
      }
    }
    setState(() {
      searched_movies = responseData['results'];
      nb_movies = searched_movies.length;
    });
  }


  void onTabTapped(int index) {
    if (index == 0) Navigator.pushNamed(context, '/');
    if (index==2) Navigator.pushNamed(context, '/salons');
    if (index==3) Navigator.pushNamed(context, '/friends');
    if (index==4) Navigator.pushNamed(context, '/movieList');
    if (index==5) Navigator.pushNamed(context, '/settings');

  }

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
      }
    });

    List<int> selectedGenreIds = _selectedGenres
        .map((genre) => genreToId(genre))
        .where((id) => id != -1)
        .toList();

    if (!selectedGenreIds.isEmpty && !searched_movies.isEmpty) {
      if (_controller.text == '') {
        _filterMoviesByGenre();
      } else {
        List<dynamic> filteredMovies = searched_movies
            .where((movie) =>
                selectedGenreIds.every((id) => movie['genre_ids'].contains(id)))
            .toList();

        setState(() {
          searched_movies = filteredMovies;
          nb_movies = filteredMovies.length;
          no_result = filteredMovies.isEmpty;
        });
      }
    } else {
      _onSearchChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 1;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorConstant.gray900,
        appBar: AppBar(
            backgroundColor: ColorConstant.gray900,
            leading: IconButton(
              icon: ImageIcon(AssetImage("assets/icons/back_arrow_red.png"), color: ColorConstant.red900,),
                onPressed: () => Navigator.of(context).pop()),
            title: RichText(
                text: TextSpan(children: [
                  TextSpan(text: "Search", style: AppStyle.txtPoppinsBold30),
                  TextSpan(text: ".", style: AppStyle.txtPoppinsBold30Red)
                ]),
                textAlign: TextAlign.left)),
        body: Column(children: [
          TextFormField(
            controller: _controller,
            onChanged: _onSearchChanged,
            style: AppStyle.txtPoppinsMedium18,
            cursorColor: ColorConstant.red900,
            decoration: InputDecoration(
                prefixIcon: IconButton(
                    icon: ImageIcon(AssetImage("assets/icons/search_empty.png"), color: ColorConstant.whiteA700),
                    onPressed: null),
                hintText: "Search",
                hintStyle: AppStyle.txtPoppinsMedium18GreyLight,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstant.red900),
                  borderRadius: BorderRadius.circular(10)
                ),
                fillColor: ColorConstant.gray90001),
          ),
          SizedBox(height: getVerticalSize(16)),
          Container(
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
          ),
          SizedBox(height: getVerticalSize(16)),
          Align(
            child: Text("Search results (" + nb_movies.toString() + ")",
                style: AppStyle.txtPoppinsMedium18),
            alignment: Alignment.centerLeft,
          ),
          SizedBox(height: getVerticalSize(20)),
          searched_movies.isEmpty && no_result
              ? Center(
            child: Text(
              'Sorry, no results are available.  Try to select fewer genres.',
              style: AppStyle.txtPoppinsMedium18,
            ),
          )
              : searched_movies.isEmpty
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorConstant.red900),
            ),
          ) :
          Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) => VerticalMovieCard(
                      item: new MovieInfo(searched_movies[index])),
                  separatorBuilder: (context, _) =>
                      SizedBox(height: getVerticalSize(6)),
                  itemCount: searched_movies.length)),
        ]),
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
                icon: ImageIcon(AssetImage("assets/icons/home_empty.png")),
                label: "Home"
            ),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icons/search_filled.png")),
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
        ));
  }
}
