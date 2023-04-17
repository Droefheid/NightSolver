import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:night_solver/screens/custom_toast.dart';
import 'package:night_solver/utils/constants.dart';
import 'package:night_solver/utils/custom_widgets.dart';
import 'package:night_solver/utils/movie_info.dart';
import 'package:night_solver/utils/size_utils.dart';

import '../theme/app_style.dart';
import '../utils/color_constant.dart';
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
  Color mainColor = const Color(0xff3C3261);
  List<dynamic> movies = [];
  bool no_recommendations = false;
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
    var RecommendedList = [];
    var SeenMovies = [];
    var RecommendedMoviesAlreadySavedInFirestore = [];

    for (String id in widget.IdList) {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (snapshot.data()!['movies_id'] != null) {
        SeenMovies.addAll(snapshot.data()!['movies_id']);
      }
      if (snapshot.data()!['recommended'] != null) {
        for (var item in snapshot.data()!['recommended'].entries) {
          RecommendedList.addAll(item.value);
        }
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

      var data =
          snapshot.data()!['salons'][widget.salonName]['recommended_movies'];
      if (data != null) {
        RecommendedMoviesAlreadySavedInFirestore.addAll(data);
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

      if (RecommendedMoviesAlreadySavedInFirestore.isEmpty) {
        if (!RecommendedList.isEmpty) {
          //get a list of recommend movies based on seen movies
          for (int i = 0; i < RecommendedList.length; i++) {
            //check if the movie recommended has the same genre as set in the preferences
            if (Genres.contains(RecommendedList[i]["genre"])) {
              //check if the movie recommended is not in the seen movies list
              if (!SeenMovies.contains(RecommendedList[i]["id"])) {
                RecList.add(RecommendedList[i]["id"]);
              }
            }
          }
        }
        for (var Rec in RecList) {
          //get the providers list of the recommended movie
          final movieProvider = await http.get(Uri.parse(
              'https://api.themoviedb.org/3/movie/$Rec/watch/providers?api_key='+Constants.theMovieDb));
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
                if (widget.providers[ProviderData["results"]["BE"]["flatrate"]
                        [y]["provider_name"]] ==
                    1) {
                  //check if movie added not in list of movie data
                  if (!moviesDataTitles.contains(Rec)) {
                    moviesDataTitles.add(Rec);
                    final finalRec = await http.get(Uri.parse(
                        'https://api.themoviedb.org/3/movie/$Rec?api_key='+Constants.theMovieDb));
                    if (finalRec.statusCode == 200) {
                      final Map<String, dynamic> finalRecCard =
                          json.decode(finalRec.body);
                      moviesData.add(finalRecCard);
                    }
                  }
                  break;
                }
              }
            }
          }
        }

        for (String member in widget.IdList) {
          FirebaseFirestore.instance.collection('users').doc(member).set({
            'salons': {
              widget.salonName: {'recommended_movies': moviesData}
            }
          }, SetOptions(merge: true));
        }
      } else {
        moviesData = RecommendedMoviesAlreadySavedInFirestore;
      }

      if (moviesData.isEmpty) {
        setState(() {
          no_recommendations = true;
        });
      } else {
        setState(() {
          movies = moviesData;
        });
      }
    }
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
      backgroundColor: ColorConstant.gray900,
      floatingActionButton: new FloatingActionButton.extended(
          onPressed: () {
            submitVotedMovie(vote);
          },
          label: Text("Submit vote", style: AppStyle.txtPoppinsMedium18Grey,),
        backgroundColor: ColorConstant.red900,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar:  AppBar(
          backgroundColor: ColorConstant.gray900,
          leading: IconButton(
            icon: ImageIcon(AssetImage("assets/icons/back_arrow_red.png"), color: ColorConstant.red900,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Recommended Movies",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: movies.isEmpty && no_recommendations
                  ? Center(
                child: Text(
                  'Sorry, no recommendations are available.',
                  style: AppStyle.txtPoppinsMedium18,
                ),
              )
                  : movies.isEmpty
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : ListView.separated(
                separatorBuilder: (context, _) => SizedBox(height: getVerticalSize(16)),
                cacheExtent: 0,
                itemCount: movies.length,
                itemBuilder: (context, i) {
                  return Slidable(
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                              backgroundColor: ColorConstant.gray800,
                              borderRadius: BorderRadius.circular(16),
                              icon: Icons.favorite,
                              foregroundColor: ColorConstant.redA700,
                              label: 'vote',
                              onPressed: (context) {
                                changeVotedMovie(movies[i]);
                              }
                          )
                        ],
                      ),
                      child: MaterialButton(
                        child: VerticalMovieCard(item: new MovieInfo(movies[i])),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetail(item: new MovieInfo(movies[i])),
                            ),
                          );
                        },
                      )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
