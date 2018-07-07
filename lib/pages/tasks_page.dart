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

  bool _isEditMode = false;
  DBHelper _dbHelper = new DBHelper();

  bool _loadingPage = true;
  List<Task> _tasks = [];

  @override
  void initState() {
      super.initState();
      _isEditMode = false;
      dbSetUp();
  }

  dbSetUp() async {
    await _dbHelper.initDb();  
    updateTodos();
  }

  updateTodos(){
    _dbHelper.getAllTasks().then((res) => this.setState(() {
      _tasks = res; 
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
              setState(() {
               _isEditMode = _isEditMode == false;               
              });
            },
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
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
      itemBuilder: (BuildContext context, int i) => TaskView(_tasks[i], _isEditMode),
      itemCount: _tasks.length,
    );

  }
}