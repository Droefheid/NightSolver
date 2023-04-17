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
    // TODO CHECK null values
    this.title = movie["title"] == null ? "No title found": movie["title"];
    this.urlImage = movie["poster_path"] == null ? "https://static.vecteezy.com/system/resources/previews/005/337/799/original/icon-image-not-found-free-vector.jpg" : movies_url + movie["poster_path"];
    this.rating = movie["vote_average"] == null ? 0 : CustomRound(movie["vote_average"]/2);
    this.synopsis = movie["overview"] == null ? "No synopsis" : movie["overview"];
    this.genres = movie["genres"];
    this.id = movie["id"] == null ? "-1" : movie["id"].toString();
  }
}