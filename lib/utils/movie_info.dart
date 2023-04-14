import 'package:night_solver/utils/size_utils.dart';

class MovieInfo {
  final String movies_url = "https://image.tmdb.org/t/p/w500/";
  late String title;
  late String urlImage;
  late double rating;
  late String synopsis;
  late String id;
  late List<dynamic>? genres;
  MovieInfo(dynamic movie) {
    this.title = movie["title"];
    this.urlImage = movies_url + movie["poster_path"];
    this.rating = CustomRound(movie["vote_average"]/2);
    this.synopsis = movie["overview"];
    this.genres = movie["genres"];
    this.id = movie["id"].toString();
  }
}