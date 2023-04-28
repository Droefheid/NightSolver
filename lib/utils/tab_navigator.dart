import 'package:flutter/material.dart';
import 'package:night_solver/screens/movie_list.dart';
import 'package:night_solver/screens/search_screen.dart';
import 'package:night_solver/utils/tab_item.dart';


class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {super.key, required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, {int materialIndex = 500}) {
    var routeBuilders = _routeBuilders(context, materialIndex: materialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            routeBuilders[TabNavigatorRoutes.detail]!(context),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {int materialIndex = 500}) {
    return {
      TabNavigatorRoutes.root: (context) => SearchScreen(),

      TabNavigatorRoutes.detail: (context) => MovieList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}