import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'movie_details.dart';

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<dynamic> movies = [];
  List<dynamic> filteredMovies = [];
  Color mainColor = const Color(0xff3C3261);
  final TextEditingController _controller = TextEditingController();

  Future<void> getData(String value) async {
    try {
      final url =
          'https://api.themoviedb.org/3/search/movie?api_key=9478d83ca04bd6ee25b942dd7a0ad777&query=$value';

      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);
      if (responseData['results'] != null) {
        setState(() {
          movies = responseData['results'];
          filteredMovies = movies;
        });
      } else {
        print('Response data is null');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  void _onSearchChanged(String value) async {
    try {
      final url =
          'https://api.themoviedb.org/3/search/movie?api_key=9478d83ca04bd6ee25b942dd7a0ad777&query=$value';
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);
      if (responseData['results'] != null) {
        setState(() {
          movies = responseData['results'];
          filteredMovies = movies;
        });
      } else {
        print('Response data is null');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    String searchTerm = 'Avengers'; // example search term
    getData(searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: mainColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Movies',
          style: TextStyle(
            color: mainColor,
            fontFamily: 'Arvo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Add movies',
              ),
              controller: _controller,
              onChanged: _onSearchChanged,
            ),
            MovieTitle(mainColor),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMovies == null ? 0 : filteredMovies.length,
                itemBuilder: (context, i) {
                  return MaterialButton(
                    child: MovieCell(filteredMovies[i]),
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetail(filteredMovies[i]),
                        ),
                      );
                    },
                    color: Colors.white,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MovieTitle extends StatelessWidget {
  final Color mainColor;

  const MovieTitle(this.mainColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Text(
        'Historique',
        style: TextStyle(
          fontSize: 40.0,
          color: mainColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arvo',
        ),
        textAlign: TextAlign.left,
      ),
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

  List<dynamic> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    filteredMovies = movieList;
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
