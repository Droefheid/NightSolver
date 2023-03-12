import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/preference_page.dart';
import 'movie_list.dart';
import 'recommendation_movie_list.dart';

class NavBar extends StatelessWidget{
  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text('Marc Lainez'),
              accountEmail: Text('marc.lainez@uclouvain.be')),
          ListTile(
            leading: Icon(Icons.face),
            title: Text('Friends'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Salons'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Preferences())),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.movie),
            title: Text('Historique'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieList())),
          ),
          ListTile(
            leading: Icon(Icons.movie),
            title: Text('Recommendations'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecommendationMovieList())),
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
    );
  }
}