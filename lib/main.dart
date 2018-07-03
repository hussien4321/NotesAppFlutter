import 'package:flutter/material.dart';
import './db/database.dart';
import './model/todo.dart';

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

class NotesPage extends StatefulWidget {
    @override
    State createState() => new NotesPageState();
}


class NotesPageState extends State<NotesPage> {
  DBHelper dbHelper = new DBHelper();

  List<ToDo> todos = [];

  @override
  void initState() {
      super.initState();
      dbSetUp();
  }

  dbSetUp() async {
    await dbHelper.initDb();  
    dbHelper.getToDos().then((res) => this.setState(() {todos = res;}));
  }
  
  @override
  Widget build(BuildContext context) {
    dbSetUp();
    return Scaffold(
      appBar: AppBar(
        title: Text("24h ToDos ⏳"),
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
        child: todos.isEmpty ? noItemWidget() : notesListView(todos, dbHelper),
      ), 
    );
  }

  Widget noItemWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You currently have no task to do at the moment 👍',
            style: TextStyle(fontSize: 15.0),
          ),
          Padding(padding: EdgeInsets.only(top:10.0),),
          Text(
            'press + button above to add a new task',
            style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget notesListView(List<ToDo> todos, DBHelper dbHelper){
    
    return ListView.builder(
      itemBuilder: (BuildContext context, int i) => todoBuilder(todos[i], dbHelper),
      itemCount: todos.length,
    );
  }

  Widget todoBuilder(ToDo todo, DBHelper dbHelper){
    return Container(
      padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    todo.name,
                    style: TextStyle(fontSize: 20.0,),
                  ),
                  Text(
                    todo.deadline.toString().substring(0,19),
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                ],          
              ),
            ),
            Checkbox(
              value: todo.status,
              onChanged: (newStatus) {
                dbHelper.completeToDo(todo);
                //UPDATE TODOS CODE
              },
            ),
          ],
        ),
    );
  }

}


class AddNotePage extends StatefulWidget {
    @override
    State createState() => new AddNotePageState();
}

class AddNotePageState extends State<AddNotePage> {

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
                  onChanged: (term) {task = term;},
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      dbHelper.addToDoItem(new ToDo(task));
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