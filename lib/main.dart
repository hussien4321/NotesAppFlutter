import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Notes 2.0',
      debugShowCheckedModeBanner: false, 
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Notes"),
        actions: <Widget>[
          IconButton(
            onPressed: () => print("added"),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // 10% of the width, so there are ten blinds.
            colors: [Colors.grey, Colors.white], // whitish to gray
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You currently have no notes on the app 😟',
                style: TextStyle(fontSize: 15.0),
              ),
              Padding(padding: EdgeInsets.only(top:10.0),),
              Text(
                'click the + button above to add a new note',
                style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
