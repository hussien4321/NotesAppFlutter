import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Reminders',
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
    return Scaffold(
      appBar: AppBar(
        title: Text("24h Reminders ⏳"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => AddNotePage()),
              );
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: fadedBackground(
        child: noItemWidget(),
      ), 
    );
  }

  Widget noItemWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You currently have no reminders on the app 😟',
            style: TextStyle(fontSize: 15.0),
          ),
          Padding(padding: EdgeInsets.only(top:10.0),),
          Text(
            'click the + button above to add a new note',
            style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget notesListView(){
    return null;
  }
}


class AddNotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Add a reminder 📝"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          )
        ],
      ),
      body: fadedBackground(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Please enter a search term'
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Add Activity'),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget fadedBackground({Widget child}) {
  return Container(
    decoration: BoxDecoration(
      gradient: new LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey, Colors.white], 
        tileMode: TileMode.repeated,
      ),
    ),
    child: child, 
  );
}