import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:night_solver/screens/custom_toast.dart';

import 'movie_details.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen(
      {Key? key,
      required this.salonName,
      required this.IdList,
      required this.providers})
      : super(key: key);
  final IdList;
  final salonName;
  final providers;
  @override
  State<ResultScreen> createState() => ResultScreenSate();
}

class ResultScreenSate extends State<ResultScreen> {
  final apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
  Color mainColor = const Color(0xff3C3261);
  List<dynamic> movies = [];
  int vote = 0;
  double aventure = 0;
  double action = 0;
  double comedie = 0;
  double crime = 0;
  double drama = 0;
  double fantasy = 0;
  double horror = 0;
  double scifi = 0;

  Future<void> getData() async {
    var moviesId = [];
    for (String id in widget.IdList) {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (snapshot.data()!['movies_id'] != null) {
        moviesId.addAll(snapshot.data()!['movies_id']);
      }
      Map preferences =
          snapshot.data()!['salons'][widget.salonName]['preferences'][id];
      aventure += preferences['aventure'];
      action += preferences['action'];
      comedie += preferences['comedie'];
      crime += preferences['crime'];
      drama += preferences['drama'];
      fantasy += preferences['fantasy'];
      horror += preferences['horror'];
      scifi += preferences['scifi'];
    }
    int numberOfMembers = widget.IdList.length;
    aventure = aventure / numberOfMembers;
    action = action / numberOfMembers;
    comedie = comedie / numberOfMembers;
    crime = crime / numberOfMembers;
    drama = drama / numberOfMembers;
    fantasy = fantasy / numberOfMembers;
    horror = horror / numberOfMembers;
    scifi = scifi / numberOfMembers;

    List<dynamic> moviesData = [];
    List<dynamic> moviesDataTitles = [];
    List<dynamic> Genres = [];
    List<dynamic> RecList = [];

    if (aventure >= 50) {
      Genres.add('12');
    }
    if (action >= 50) {
      Genres.add('28');
    }
    if (comedie >= 50) {
      Genres.add('35');
    }
    if (crime >= 50) {
      Genres.add('80');
    }
    if (drama >= 50) {
      Genres.add('18');
    }
    if (fantasy >= 50) {
      Genres.add('14');
    }
    if (horror >= 50) {
      Genres.add('27');
    }
    if (scifi >= 50) {
      Genres.add('878');
    }

    //TODO Si Movies disponible dans firestore les prendre sinon effectuer tout ce qui il y a en dessous


    if (!moviesId.isEmpty) {
      for (String movieId in moviesId) {
        //get a list of recommend movies based on seen movies
        final result = await http.get(Uri.parse(
            'https://api.themoviedb.org/3/movie/$movieId/recommendations?api_key=$apiKey&language=en-US&page=1'));
        if (result.statusCode == 200) {
          final Map<String, dynamic> resultData = json.decode(result.body);
          for (int i = 0; i < resultData['results'].length; i++) {
            //check if the movie recommended has the same genre as set in the preferences
            if (resultData['results'][i]['genre_ids'].length != 0 &&
                Genres.contains(
                    resultData['results'][i]['genre_ids'][0] as int)) {
              //check if the movie recommended is not in the seen movies list
              if (!moviesId
                  .contains(resultData["results"][i]["id"].toString())) {
                RecList.add(resultData["results"][i]);
              }
            }
          }
        }
      }
      for (var Rec in RecList) {
        //get the providers list of the recommended movie
        String recId = Rec["id"].toString();
        final movieProvider = await http.get(Uri.parse(
            'https://api.themoviedb.org/3/movie/$recId/watch/providers?api_key=$apiKey'));
        if (movieProvider.statusCode == 200) {
          final Map<String, dynamic> ProviderData =
              json.decode(movieProvider.body);
          //check if the movie has any provider in Belgium
          if (ProviderData["results"]["BE"] != null &&
              ProviderData["results"]["BE"]["flatrate"] != null) {
            for (int y = 0;
                y < ProviderData["results"]["BE"]["flatrate"].length;
                y++) {
              // check if the provider is in the providers list
              if (widget.providers[ProviderData["results"]["BE"]["flatrate"][y]
                      ["provider_name"]] ==
                  1) {
                //check if movie added not in list of movie data
                if (!moviesDataTitles.contains(Rec["title"])) {
                  moviesDataTitles.add(Rec["title"]);
                  moviesData.add(Rec);
                }
                break;
              }
            }
          }
        }
      }
    }


    //TODO Save movies inside firestore


    setState(() {
      movies = moviesData;
      print(movies);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void changeVotedMovie(movie) {
    setState(() {
      vote = movie['id'];
    });
    CustomToast.showToast(context, 'your current vote is: ${movie['title']}');
  }

  void submitVotedMovie(movieID) {
    final user = FirebaseAuth.instance.currentUser!;
    for (String member in widget.IdList) {
      FirebaseFirestore.instance.collection('users').doc(member).set({
        'salons': {
          widget.salonName: {
            'votes': {user.uid: movieID}
          }
        }
      }, SetOptions(merge: true));
    }
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton.extended(
          onPressed: () {
            submitVotedMovie(vote);
          },
          label: const Text("Submit vote")),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Recomended Movies',
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
            Expanded(
              child: ListView.builder(
                cacheExtent: 0,
                itemCount: movies.isEmpty ? 1 : movies.length,
                itemBuilder: (context, i) {
                  return movies.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Slidable(
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                  backgroundColor: Colors.red,
                                  icon: Icons.favorite,
                                  label: 'vote',
                                  onPressed: (context) {
                                    changeVotedMovie(movies[i]);
                                  })
                            ],
                          ),
                          child: MaterialButton(
                            child: MovieCell(movies[i]),
                            padding: const EdgeInsets.all(0.0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetail(movies[i]),
                                ),
                              );
                            },
                            color: Colors.white,
                          ));
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
