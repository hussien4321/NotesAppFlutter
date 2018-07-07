import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task.dart';
import '../model/todo.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/task_view.dart';

class TasksPage extends StatefulWidget {
    @override
    State createState() => new TasksPageState();

}

class TasksPageState extends State<TasksPage> {
  DBHelper _dbHelper = new DBHelper();

  bool _loadingPage = true;
  List<Task> _recommendedTasks = [];

  @override
  void initState() {
      super.initState();
      dbSetUp();
  }

  dbSetUp() async {
    await _dbHelper.initDb();  
    updateTodos();
  }

  updateTodos(){
    _dbHelper.getRecommendedTasks().then((res) => this.setState(() {
      _recommendedTasks = res; 
      _loadingPage = false;
    }));
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a task"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.edit),
          )
        ],
      ),
      body: fadedBackground(
        child: _loadingPage ? LoadingScreen() : _recommendedTasksView(),
      ), 
    );
  }  

  Widget _recommendedTasksView(){
    return ListView.builder(
      itemBuilder: (BuildContext context, int i) => TaskView(_recommendedTasks[i]),
      itemCount: _recommendedTasks.length,
    );

  }
}