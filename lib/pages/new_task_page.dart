import 'package:flutter/material.dart';
import '../db/database.dart';


class NewTaskPage extends StatefulWidget {
    @override
    State createState() => new NewTaskPageState();
}


class NewTaskPageState extends State<NewTaskPage> {

  DBHelper dbHelper = new DBHelper();
  String task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a new task 📝"),
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
      body: Container(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Please enter a search term'
                  ),
                  onChanged: (term) {task = term;},
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Add Task'),
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