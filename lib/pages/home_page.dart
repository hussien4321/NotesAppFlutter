import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task.dart';
import '../model/todo.dart';
import '../utils/views/faded_background.dart';
import '../utils/helpers/time_functions.dart';
import '../utils/helpers/countdown.dart';
import './tasks_page.dart';

class HomePage extends StatefulWidget {
    @override
    State createState() => new HomePageState();
}


class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  DBHelper dbHelper = new DBHelper();

  List<ToDo> todos = [];
  List<AnimationController> _countdownControllers = [];
  

  @override
  void initState() {
      super.initState();
      dbSetUp();
      initializeControllers(todos);
  }

  dbSetUp() async {
    await dbHelper.initDb();  
    updateTodos();
  }

  updateTodos(){
    dbHelper.getToDos().then((res) => this.setState(() {
      if(todos != res){
        initializeControllers(res);
        todos = res;
      }
    }));
  }
  
  initializeControllers(List<ToDo> todos){
    for(int i = 0; i < todos.length; i ++){
      AnimationController temp = new AnimationController(
        vsync: this,
        duration: todos[i].startDate.add(Duration(days: 1)).difference(DateTime.now()),
      );
      _countdownControllers.add(temp);
      _countdownControllers[i].forward();
    }
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
      itemBuilder: (BuildContext context, int i) => todoBuilder(todos[i], dbHelper, i),
      itemCount: todos.length,
    );
  }

  Widget todoBuilder(ToDo todo, DBHelper dbHelper, int index){
    return Container(
      padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Opacity(
              opacity: 0.8,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: Center(
                  child: Text(
                  '👉',
                  style: TextStyle(fontSize: 15.0,),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                todo.task.icon,
                style: TextStyle(fontSize: 50.0),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    todo.task.name,
                    style: TextStyle(fontSize: 20.0,),
                  ),
                  Text(
                    TimeFunctions.getRemainingTime(todo.startDate),
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                  Countdown(
                    animation: new StepTween(
                      begin: todo.startDate.add(Duration(days: 1)).difference(DateTime.now()).inSeconds,
                      end: 0,
                    ).animate(_countdownControllers[index]),
                  ),
                ],          
              ),
            ),
            Opacity(
              opacity: 0.8,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                child: Center(
                  child: Text(
                  '👈',
                  style: TextStyle(fontSize: 15.0, color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

}