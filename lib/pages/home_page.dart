import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/todo.dart';
import '../utils/views/faded_background.dart';
import './tasks_page.dart';

class HomePage extends StatefulWidget {
    @override
    State createState() => new HomePageState();
}


class HomePageState extends State<HomePage> {
  DBHelper dbHelper = new DBHelper();

  List<ToDo> todos = [];

  @override
  void initState() {
      super.initState();
      dbSetUp();
  }

  dbSetUp() async {
    await dbHelper.initDb();  
    updateTodos();
  }

  updateTodos(){
    dbHelper.getToDos().then((res) => this.setState(() {todos = res;}));
  }
  
  @override
  Widget build(BuildContext context) {
    updateTodos();
    return Scaffold(
      appBar: AppBar(
        title: Text("24h To-Dos ⏳"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => TasksPage()),
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
                    'TODO NAME',
                    style: TextStyle(fontSize: 20.0,),
                  ),
                  Text(
                    'todo.deadline.toString().substring(0,19)',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                ],          
              ),
            ),
            Checkbox(
              value: todo.success,
              onChanged: (newStatus) {
                dbHelper.completeToDo(todo);
              },
            ),
          ],
        ),
    );
  }

}