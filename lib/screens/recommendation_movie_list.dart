import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'recommendation_movie_details.dart';

class RecommendationMovieList extends StatefulWidget {
  @override
  _RecommendationMovieListState createState() => _RecommendationMovieListState();
}

class _RecommendationMovieListState extends State<RecommendationMovieList> {
  List<dynamic> movies = [];

  Future<void> getData() async {
    final url =
        'https://api.themoviedb.org/3/movie/top_rated?api_key=9478d83ca04bd6ee25b942dd7a0ad777';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> responseData = json.decode(response.body);
    setState(() {
      movies = responseData['results'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
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
            MovieTitle(const Color(0xff000000)),
            Expanded(
              child: ListView.builder(
                itemCount: movies == null ? 0 : movies.length,
                itemBuilder: (context, i) {
                  return MaterialButton(
                    child: MovieCell(movies[i]),
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendationMovieDetail(movies[i]),
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
        'My Top Rated',
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

