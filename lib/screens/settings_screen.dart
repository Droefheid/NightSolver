import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:night_solver/theme/theme_manager.dart';

import 'home_screen.dart';

class SettingsScreen extends StatefulWidget{
  @override
  _SettingsState createState() => _SettingsState();
}

ThemeManager _themeManager = ThemeManager();

class _SettingsState extends State<SettingsScreen> {
  static const bool _isDark = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen()))
        ),
        title: Text('Settings'),
      ),
      body: SwitchListTile(
        title: Text("Dark mode"),
        value: _themeManager.themeMode == ThemeMode.dark,
        onChanged: (newValue) {
          print("press");
          _themeManager.toggleTheme(newValue);
        },
      ),

    );
  }
}