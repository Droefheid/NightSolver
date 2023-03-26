import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'movie_details.dart';

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
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
            'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey'));

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
            'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$value';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Movies',
          style: TextStyle(
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
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: movies.isEmpty ? 0 : movies.length,
                itemBuilder: (context, i) {
                  return MaterialButton(
                    child: MovieCell(movies[i]),
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () async {
                      final addedMovie = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetail(movies[i]),
                        ),
                      );
                      if (addedMovie != null && addedMovie) {
                        _controller.clear();
                        await getData();
                      }
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
