import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key,required this.aventure, required this.action, required this.comedie, required this.crime, required this.drama, required this.fantasy,required this.horror,required this.scifi, required this.providers}) : super(key: key);
  final double aventure;
  final double action;
  final double comedie;
  final double crime;
  final double drama;
  final double fantasy;
  final double horror;
  final double scifi;
  final providers;
  @override
  State<ResultScreen> createState() => ResultScreenSate();

}

class ResultScreenSate extends State<ResultScreen> {
  final apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
  Color mainColor = const Color(0xff3C3261);
  List<dynamic> movies = [];
  Future<void> getData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance.collection('movies').doc(user.uid).get();
    List<dynamic>? moviesId = snapshot.data()!['movies_id'];
    List<dynamic> moviesData = [];
    List<dynamic> moviesDataTitels = [];
    List<dynamic> Genres = [];
    if(widget.aventure>=50){
      Genres.add(12);
    }
    if(widget.action>=50){
      Genres.add(28);
    }
    if(widget.comedie>=50){
      Genres.add(35);
    }
    if(widget.crime>=50){
      Genres.add(80);
    }
    if(widget.drama>=50){
      Genres.add(18);
    }
    if(widget.fantasy>=50){
      Genres.add(14);
    }
    if(widget.horror>=50){
      Genres.add(27);
    }
    if(widget.scifi>=50){
      Genres.add(878);
    }

    if(moviesId != null){
      for (String movieId in moviesId) {
        //get a list of recommend movies based on seen movies
        final result = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$movieId/recommendations?api_key=$apiKey&language=en-US&page=1'));
          if (result.statusCode == 200) {
            final Map<String, dynamic> resultData = json.decode(result.body);
            for(int i=0;i<resultData['results'].length;i++){
              //check if the movie recommended has the same genre as set in the preferences
              if(resultData['results'][i]['genre_ids'].length != 0 && Genres.contains(resultData['results'][i]['genre_ids'][0] as int)){
                //check if the movie recommended is not in the seen movies list
                if(!moviesId.contains(resultData["results"][i]["id"].toString())) {
                  String recId = resultData["results"][i]["id"].toString();
                  //get the providers list of the recommended movie
                  final movieProvider = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$recId/watch/providers?api_key=$apiKey'));
                  if(movieProvider.statusCode == 200){
                    final Map<String, dynamic> ProviderData = json.decode(movieProvider.body);
                    //check if the movie has any provider in Belgium
                    if(ProviderData["results"]["BE"] != null && ProviderData["results"]["BE"]["flatrate"] != null){
                      for(int y=0; y<ProviderData["results"]["BE"]["flatrate"].length;y++){
                        // check if the provider is in the providers list
                        print(ProviderData["results"]["BE"]["flatrate"][y]["provider_name"]);
                        if(widget.providers[ProviderData["results"]["BE"]["flatrate"][y]["provider_name"]] ==1){
                          //check if movie added not in list of movie data
                          if(!moviesDataTitels.contains(resultData["results"][i]["title"])){
                            moviesDataTitels.add(resultData["results"][i]["title"]);
                            moviesData.add(resultData["results"][i]);
                          }
                          break;
                        }
                      }
                    }

                  }
                }
              }
            }
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Recomended Movies',
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
            Expanded(
              child: ListView.builder(
                itemCount: movies == null ? 0 : movies.length,
                itemBuilder: (context, i) {
                  return MaterialButton(
                    child:
                    MovieCell(movies[i]),
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {},
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



