import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'movie_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void navigateToMovieList() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('My top rated'),
                value: 1,
              ),
            ],
            icon: Icon(Icons.list),
            onSelected: (value) {
              // Handle menu item selection
              if (value == 1) {
                navigateToMovieList();
              }
            },
          ),
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in'),
            Text('User : ' + user.email!),
          ],
        ),
      ),
    );
  }
}