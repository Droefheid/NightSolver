import 'dart:convert';
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
          setState(() {
            searched_movies = responseData['results'];
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

  Future<void> getData() async {
    final url =
        'https://api.themoviedb.org/3/trending/movie/week?api_key=9478d83ca04bd6ee25b942dd7a0ad777';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> responseData = json.decode(response.body);
    setState(() {
      searched_movies = responseData['results'];
      nb_movies = searched_movies.length;
    });
  }

  void onTabTapped(int index) {
    if (index == 0) Navigator.pushNamed(context, '/');
    if (index==2) Navigator.pushNamed(context, '/recommendation');
    if (index==3) Navigator.pushNamed(context, '/movieList');
    if (index==4) Navigator.pushNamed(context, '/settings');

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
                selectedGenreIds.any((id) => movie['genre_ids'].contains(id)))
            .toList();
        setState(() {
          searched_movies = filteredMovies;
          nb_movies = filteredMovies.length;
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
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: ColorConstant.red900),
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
            decoration: InputDecoration(
                prefixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: ColorConstant.whiteA700,
                    ),
                    onPressed: null),
                hintText: "Search",
                hintStyle: AppStyle.txtPoppinsMedium18Grey,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
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
          Container(
              height: getVerticalSize(462),
              child: ListView.separated(
                  itemBuilder: (context, index) => VerticalMovieCard(
                      item: new MovieInfo(searched_movies[index])),
                  separatorBuilder: (context, _) =>
                      SizedBox(height: getVerticalSize(16)),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(
                icon: Icon(Icons.recommend), label: "Recommendation"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark), label: "bookmark"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ));
  }
}
