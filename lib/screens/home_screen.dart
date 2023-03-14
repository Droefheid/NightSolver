import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/NavBar.dart';
import 'package:night_solver/screens/movie_details.dart';
import 'package:night_solver/screens/new_salon_screen.dart';
import 'package:night_solver/screens/preference_page.dart';
import 'package:http/http.dart' as http;

import 'movie_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text("search");
  String searchValue = "";
  List<dynamic> movies = [];
  final controller = ScrollController();
  void signOut(){
    FirebaseAuth.instance.signOut();
  }

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
  void dispose() {
    controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final String movies_url = "https://image.tmdb.org/t/p/w500/";
    return Scaffold(
      //backgroundColor: Colors.black,
        drawer: NavBar(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Center(
            child: customSearchBar,
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      leading: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 28,
                      ),
                      title: TextField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Type in movie name...',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (
                                (value) => setState(() => searchValue = value)
                        ),
                      ),
                    );                } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Search a movie');
                  }
                });
              },
              icon: customIcon,
            ),
          ],
        ),
        body: GridView.builder(
          controller: controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
              mainAxisSpacing: 3,
            childAspectRatio: 0.7
          ),
            itemCount: movies == null ? 0 : movies.length,
          itemBuilder: (context, index) {
            //return  Image(image: new NetworkImage(movies_url+movies[index]["poster_path"]));
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetail(movies[index]))),
              child: Image.network(movies_url + movies[index]["poster_path"]),
            );
          }
        ),
      bottomSheet: Container(
        width: double.infinity,
        child: ElevatedButton(
          child: Text("Create new room"),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewSalon())),
        ),
      ),
    );
  }
}
