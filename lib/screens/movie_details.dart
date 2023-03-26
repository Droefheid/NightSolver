import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieDetail extends StatefulWidget {
  final movie;
  final bool canDelete;

  var image_url = 'https://image.tmdb.org/t/p/w500/';
  var apiKey = '9478d83ca04bd6ee25b942dd7a0ad777';
  Map<String, dynamic> providers = {};

  MovieDetail(this.movie) : canDelete = movie['can_delete'] == true;

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  Color mainColor = const Color(0xffffffff);

  Future addMovie(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    docRef.set({
      'movies_id': FieldValue.arrayUnion([widget.movie['id'].toString()]),
    }, SetOptions(merge: true));

    Fluttertoast.showToast(
      msg: "Movie added to watched list",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
    );

    // Navigate back to the previous screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context, true);
  }

  Future deleteMovie(BuildContext context, String movieId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    docRef.update({
      'movies_id': FieldValue.arrayRemove([movieId]),
    });

    // Show toast message
    Fluttertoast.showToast(
      msg: "Movie removed from watched list",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
    );

    // Navigate back to the previous screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context, true);
  }

  Future<void> getWatchProviders() async {
    var url =
        'https://api.themoviedb.org/3/movie/${widget.movie['id']}/watch/providers?api_key=${widget.apiKey}';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        widget.providers = data['results'];
      });
    } else {
      throw Exception('Failed to load providers');
    }
  }

  Widget buildProviderList() {
    if (widget.providers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'No providers available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
        ],
      );
    }

    List<Widget> providerWidgets = [];
    Set<String> addedProviders = Set();

    widget.providers.forEach((key, value) {
      if (value['rent'] != null && value['rent'].isNotEmpty) {
        value['rent'].forEach((rentValue) {
          if (rentValue['provider_name'] != null && !addedProviders.contains(rentValue['provider_name'])) {
            addedProviders.add(rentValue['provider_name']);
            providerWidgets.add(
              Image.network(
                'https://image.tmdb.org/t/p/w92${rentValue['logo_path']}',
                width: 60,
              ),
            );
          }
        });
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Providers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: providerWidgets.map((widget) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: widget,
              );
            }).toList(),
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    getWatchProviders();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.movie['title']),
      ),
      body: new Stack(fit: StackFit.expand, children: [
        new Image.network(
          widget.movie['poster_path'] != null
              ? widget.image_url + widget.movie['poster_path']
              : 'https://via.placeholder.com/500x750.png?text=No+Image+Available',
          fit: BoxFit.cover,
        ),
        new BackdropFilter(
          filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: new Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        new SingleChildScrollView(
          child: new Container(
            margin: const EdgeInsets.all(20.0),
            child: new Column(
              children: <Widget>[
                new Container(
                  alignment: Alignment.center,
                  child: new Container(
                    width: 400.0,
                    height: 400.0,
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(10.0),
                      image: new DecorationImage(
                          image: new NetworkImage(
                              widget.image_url + widget.movie['poster_path']),
                          fit: BoxFit.cover),
                      boxShadow: [
                        new BoxShadow(
                            color: Colors.black,
                            blurRadius: 20.0,
                            offset: new Offset(0.0, 10.0))
                      ]),
                ),
                new Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 0.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text(
                          widget.movie['title'],
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontFamily: 'Arvo'),
                        ),
                      ),
                      new Text(
                        '${widget.movie['vote_average']}/10',
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontFamily: 'Arvo'),
                      ),
                    ],
                  ),
                ),
                new Text(widget.movie['overview'],
                    style:
                        new TextStyle(color: Colors.white, fontFamily: 'Arvo')),
                buildProviderList(),
                new Padding(padding: const EdgeInsets.all(10.0)),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    widget.canDelete
                        ? // Render delete button only if user has permission
                        new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new GestureDetector(
                              onTap: () {
                                deleteMovie(
                                    context, widget.movie['id'].toString());
                              },
                              child: new Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: new Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          )
                        : new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new GestureDetector(
                              onTap: () {
                                addMovie(context);
                              },
                              child: new Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: new Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
