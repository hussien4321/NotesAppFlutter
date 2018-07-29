import 'package:flutter/material.dart';
import './pages/home_page.dart';
import './services/database.dart';
import './services/notifications.dart';
import './services/preferences.dart';
import './services/emoji_loader.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    _initializeServices(context);
    return new MaterialApp(
      title: '24h Tasks',
      debugShowCheckedModeBanner: false, 
      theme: new ThemeData(
        primarySwatch: Colors.orange,
        textTheme: TextTheme(
          headline: TextStyle(fontFamily: 'Quicksand', fontSize: 30.0, letterSpacing: 2.0, fontWeight: FontWeight.bold),
          display1: TextStyle(fontFamily: 'Quicksand', fontSize: 23.0, color: Colors.black),
          body1: TextStyle(fontWeight: FontWeight.w300, fontFamily: 'Quicksand'),
          body2: TextStyle(fontWeight: FontWeight.w300, fontFamily: 'Quicksand', fontSize: 20.0),
          caption: TextStyle(fontFamily: 'Quicksand', fontSize: 17.0, color: Colors.black),
          button: TextStyle(fontFamily: 'Quicksand'),
        ),
      ),
      home: HomePage(),
    );
  }

  void _initializeServices(BuildContext context) async {
    new DBHelper();
    new NotificationService();
    new Preferences();
    new EmojiLoader(context);
  }
}