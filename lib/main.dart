import 'package:flutter/material.dart';
import './pages/emoji_selector_page.dart';
import './pages/new_tabs_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '24h Tasks',
      debugShowCheckedModeBanner: false, 
      theme: new ThemeData(
        primarySwatch: Colors.orange,
        textTheme: TextTheme(
          body1: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      home: NewTabsPage(),
    );
  }
}